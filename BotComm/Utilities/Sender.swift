//
//  Sender.swift
//  BotComm
//
//  Created by William Snook on 5/9/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import Foundation

protocol SenderProtocol {   // Used to support a mock version of sender for testing and previews

    var connectionState: ConnectionState { get set }
    var responseString: String { get set }  // StartView text view tracks and displays this string

    func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String)
    func startResponse(_ message: String)
    func updateResponse(_ message: String)

    func doBreakConnection()
    func doMakeConnection( to address: String, at port: UInt16 ) -> Bool
    func startConnection(_ hostName: String)

    @discardableResult func sendCmd( _ message: String ) -> Bool
}

/// Current expected connection state, determined by status of session with target device
enum ConnectionState: String {          // State of communication channel to device
    case connected = "Connected"            // Ready for commands, expecting responses
    case connecting = "Connecting"          // Actively looking for and waiting for connection acceptance
    case disconnecting = "Disconnecting"    // Actively disconnecting from device
    case disconnected = "Disconnected"      // Currently not accepting commands, not expecting responses
    func buttonName() -> String {
        switch self {
        case .connected: return "Disconnect"
        case .connecting: return "Connecting..."
        case .disconnecting: return "Disconnecting..."
        case .disconnected: return "Connect"
        }
    }
    func stateChanging() -> Bool {
        switch self {
        case .connected, .disconnected: false
        case .connecting, .disconnecting: true
        }
    }
}

enum ReceiveError: Error {
    case lostConnection
}

let useDatagramProtocol = true


@Observable class Sender: SenderProtocol {

    // For testing buttons, use connected, else use disconnected
    var connectionState: ConnectionState = .connected
    var responseString: String = "Started..."

    @ObservationIgnored private var socketfd: Int32 = 0
    @ObservationIgnored private var deadTime = Timer()


    public init() {}

    deinit {
        doBreakConnection()
    }

    // Called from connect button in ConnectView to connect or disconnect to selected robot device
    func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String) {
        print("Sender, requested \(connectionRequest.rawValue) in connection state \(connectionState.rawValue)")
        switch (connectionRequest, connectionState) {
        case (.connect, .connected):
            startResponse("WARNING - already connected")
        case (.connect, .disconnected):
            startConnection(hostName)
        case (.disconnect, .connected):
            doBreakConnection()
        default:
            startResponse("Warning - invalid request received: \(connectionRequest.rawValue) in connection state \(connectionState.rawValue)")
        }
    }

    func startResponse(_ message: String) {
        responseString = message
    }

    func updateResponse(_ message: String) {    // With message received from device

        print(">> \(message)")
        //        switch message.first {
        //        case "C", "D":
        //            print(">> Got speed index file from device:\n\(message)")
        //            Speed.shared.setup(message)
        //        case "T":
        //            responseString += "\n----    Got Camera data, todo    ----\n" + message
        //        default:
        responseString += "\n" + message
        //        }
    }

    public func doBreakConnection() {
        startResponse("OK - disconnecting")
        sendCmd( "#" )               // Sign off device
        connectionState = .disconnecting
        DispatchQueue.global( qos: .userInitiated ).async { [self] in
            usleep( 1000000 )
            deadTime.invalidate()       // Stop sending keep-alive

            if socketfd != 0 {
//                if useDatagramProtocol {
//                    print(" Using Datagram Protocol, already connected on socket \(socketfd)\n")
//                    updateResponse(" Already connected on socket \(socketfd)\n")
//                } else {
                    close( socketfd )
                    socketfd = 0
//                }
            }
            connectionState = .disconnected
        }
    }

    func startConnection(_ hostName: String) {
        connectionState = .connecting
        startResponse("OK - connecting")
        DispatchQueue.global( qos: .userInitiated ).async { [self] in
            let connectResult = doMakeConnection( to: hostName, at: 5555 )
            if connectResult {
                connectionState = .connected
                updateResponse("  Connected to host \(hostName)")
                sendCmd( "@" )
            } else {
                connectionState = .disconnected
                updateResponse("  Failed to connect to host \(hostName)")
            }
        }
    }

    public func doMakeConnection( to address: String, at port: UInt16 ) -> Bool {
        //        updateResponse(" Connect to \(address) at port \(port) using \(useDatagramProtocol ? "UDP" : "TCP")")
        if socketfd != 0 {
//            if useDatagramProtocol {
//                print(" Using Datagram Protocol, already connected on socket \(socketfd)\n")
//                updateResponse(" Already connected on socket \(socketfd)\n")
//
//                readThread()    // Loop waiting for response, exits on read error
//
//                return true
//            } else {
                close( socketfd )
                socketfd = 0
//            }
        }
        socketfd = socket( AF_INET, useDatagramProtocol ? SOCK_DGRAM : SOCK_STREAM, 0 ) // ipv4, udp or tcp

        guard let targetAddr = doLookup( name: address ) else {
            updateResponse(" Lookup failed for \(address)")
            return false
        }
        updateResponse(" Found target address: \(targetAddr), connecting...")

        let result = doConnect( targetAddr, port: port )
        guard result >= 0 else {
            updateResponse(" Connect failed for \(targetAddr), port \(port), error: \(result)")
            return false
        }
        updateResponse(" Connected on socket \(socketfd) on our port \(port) to host address \(address): (\(targetAddr))\n")

        readThread()    // Loop waiting for response, exits on read error

        return true
    }

    func doLookup( name: String ) -> String? {
        var hints = addrinfo(
            ai_flags: AI_PASSIVE,       // Assign the address of my local host to the socket structures
            ai_family: AF_INET,      	// IPv4
            ai_socktype: SOCK_STREAM,   // UDP -- SOCK_STREAM for TCP - Either seem to work here
            ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil )
        var servinfo: UnsafeMutablePointer<addrinfo>? = nil		// For the result from the getaddrinfo
        let status = getaddrinfo( name + ".local", "5555", &hints, &servinfo)
        guard status == 0 else {
            //			let stat = strerror( errno )
            updateResponse(" Address lookup failed for \(name), status: \(status)") // , error: \(String(describing: stat))")
            return nil
        }

        var target: String?
        var info = servinfo
        while info != nil {					// Check for addresses - typically there is only one ipv4 address
            var ipAddressString = [CChar]( repeating: 0, count: Int(INET_ADDRSTRLEN) )
            let sockAddrIn = info!.pointee.ai_addr.withMemoryRebound( to: sockaddr_in.self, capacity: 1 ) { $0 }
            var ipaddr_raw = sockAddrIn.pointee.sin_addr.s_addr
            inet_ntop( info!.pointee.ai_family, &ipaddr_raw, &ipAddressString, socklen_t(INET_ADDRSTRLEN))
            let ipaddrstr = String( cString: &ipAddressString )
            if strlen( ipaddrstr ) < 16 {	// Valid IPV4 address string
                target = ipaddrstr
                break						// Get first valid IPV4 address
            }
            updateResponse(" Got target address: \(String(describing: target))")
            info = info!.pointee.ai_next
        }
        freeaddrinfo( servinfo )
        return target
    }


    func doConnect( _ addr: String, port: UInt16 ) -> Int32 {
        var serv_addr_in = sockaddr_in( sin_len: __uint8_t(MemoryLayout< sockaddr_in >.size), sin_family: sa_family_t(AF_INET), sin_port: port.bigEndian, sin_addr: in_addr( s_addr: inet_addr(addr) ), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0) )
        let serv_addr_len = socklen_t(MemoryLayout.size( ofValue: serv_addr_in ))
        let connectResult = withUnsafeMutablePointer( to: &serv_addr_in ) {
            $0.withMemoryRebound( to: sockaddr.self, capacity: 1 ) {
                connect( socketfd, $0, serv_addr_len )
            }
        }
        if connectResult < 0 {
            let stat = String( describing: strerror( errno ) )
            updateResponse(" ERROR connecting \(connectResult), errno: \(errno), \(stat)")
            //			return connectResult
        }
        return connectResult
    }

    func readThread() {         // Start read thread, wait on incoming data
        DispatchQueue.global(qos: .userInitiated).async { [weak self] () -> Void in
            self?.getReceivedData()
        }
    }

    private func getReceivedData() {
        while socketfd != 0 {
            var readBuffer: [CChar] = [CChar](repeating: 0, count: 1024)
            var rcvLen = 0
            if useDatagramProtocol {
                rcvLen = recv(socketfd, &readBuffer, 1024, 0)
                if rcvLen <= 0 {
                    print("UNEXPECTED! Got rcvLen \(rcvLen) from UDP recv call on socket \(socketfd)")
//                    break
                }
            } else {
                rcvLen = read(socketfd, &readBuffer, 1024 )
                if rcvLen <= 0 {
                    updateResponse(" Connection lost while receiving, \(rcvLen)")
                    break
                }
            }
            print("Received data")
            let str = String( cString: readBuffer, encoding: .utf8 ) ?? "bad data"
            switch str.first {
            case "C", "D":
                print("Got speed index string: \(str)")
                Speed.shared.setup(str)
            case "@":
                print("Got status request response: \(str)")
                updateResponse(" Status: \(str)")
            default:
                print("Got unexpected string: \(str)")
            }
        }
//        updateResponse(" Read \(rcvLen) bytes from socket \(socketfd):\n-- \(str) --\n")

        // If we get here, the socket has closed due to an error which usually means a comm failure on the device/robot
        print("Exiting read thread")
    }

    @discardableResult public func sendCmd( _ message: String ) -> Bool {

        guard connectionState == .connected else {
            updateResponse(" sendCmd, connection not open while sending \(message)")
            return false
        }

        guard socketfd != 0 else {
            updateResponse(" sendCmd, socket not connected while sending \(message)")
            return false
        }

        guard !message.isEmpty else {
            updateResponse(" sendCmd, message to send is empty")
            return false
        }

        if (message.count > 2) {
            updateResponse(" sendCmd, sending the multi-character command <\(message)>")
        } else {
            if message.first == "#" {
                print("SendCmd: \(message.first ?? "!")")
            }
        }
        deadTime.invalidate()
        deadTime = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false )

        let command = message + "\0"    // For strcpy and strlen
		var writeBuffer: [CChar] = [CChar](repeating: 0, count: 1024)
		strcpy( &writeBuffer, command )
		let len = strlen( command )
        var sndLen = 0
        if useDatagramProtocol {
            sndLen = send( socketfd, &writeBuffer, Int(len), 0 )
        } else {
            sndLen = write( socketfd, &writeBuffer, Int(len) )
        }
		if ( sndLen < 0 ) {
//            updateResponse("   Connection lost while sending, \(sndLen)")
            return false
		}
		return true
	}

    @objc func timerAction() {
        sendCmd( "?" )   // Keep-alive
//        print( "?", terminator: "")
    }

//    @objc func timerStart() {
//        sendCmd( "@" )   // Trigger start
//        print( "@", terminator: "") // No newline
//    }
}
