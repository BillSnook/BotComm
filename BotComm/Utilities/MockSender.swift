//
//  MockSender.swift
//  BotComm
//
//  Created by William Snook on 8/20/25.
//  Copyright © 2025 billsnook. All rights reserved.
//

import Foundation

@Observable class MockSender: Sender {

    @ObservationIgnored var work: Task<Void, Never>?
    @ObservationIgnored var speed: Speed = Speed.shared

    public init(_ speedIndex: Speed) {
        // For testing buttons, use connected, else use disconnected
        super.init()
        speed = speedIndex
    }

    deinit {
        doBreakConnection()
    }

    // Called from connect button in ConnectView to connect or disconnect to selected robot device
    override func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String) {
        print("MockSender, requested \(connectionRequest.rawValue) in connection state \(connectionState.rawValue)")
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

    override func startResponse(_ message: String) {
        responseString = message
    }

    override func updateResponse(_ message: String) {    // With message received from device

//        print(">> \(message)")
        switch message.first {
        case "S":
            print(">> Got speed index file from device")
//            speedIndex.setup(message)
        case "T":
            responseString += "\n----    Got Camera data, todo    ----\n" + message
        default:
            responseString += "\n\(message)"
        }
    }

    override public func doBreakConnection() {
        startResponse("OK - disconnecting")
        sendCmd( "#" )               // Sign off device
        connectionState = .disconnecting
        DispatchQueue.global( qos: .userInitiated ).async {
            usleep( 1000000 )
            self.connectionState = .disconnected
        }
    }

    override func startConnection(_ hostName: String) {
        connectionState = .connecting
        startResponse("OK - connecting")
        DispatchQueue.global( qos: .userInitiated ).async {
            let connectResult = self.doMakeConnection( to: hostName, at: 5555 )
            if connectResult {
                self.connectionState = .connected
                self.updateResponse("  Connected to host \(hostName)")
                print("  Connected to host \(hostName)")
            } else {
                self.connectionState = .disconnected
                self.updateResponse("  Failed to connect to host \(hostName)")
                print("  Failed to connect to host \(hostName)")
            }
        }
    }

    override public func doMakeConnection( to address: String, at port: UInt16 ) -> Bool {
        updateResponse(" Connect to \(address) at port \(port) using \(useDatagramProtocol ? "UDP" : "TCP")")

        usleep( 1000000 )
        return true
    }


    @discardableResult override public func sendCmd( _ message: String ) -> Bool {

        guard connectionState == .connected else {
            updateResponse(" sendCmd socket not connected while sending \(message)")
            return false
        }

        guard !message.isEmpty else {
            updateResponse(" sendCmd message to send is empty")
            return false
        }

        // Handle creating responses to selected expected commands here
        let msgType = message.first
        switch msgType {
        case "C":
            print("sendCmd with \"C\", mock response - get speedIndex")
            getSpeedData()
        case "D":
            print("sendCmd with \"D\", mock response - get speedIndex")
            getSpeedData()
        case "E":
            print("sendCmd with \"E\", \(message), no response expected")
//            start()
        default:
            print("sendCmd with \(message), command not recognized")
        }


        return true
    }

   func getSpeedData() {
        work = Task {
            print("start task work")
            try? await Task.sleep(for: .seconds(2))
            let replyString = """
                D 8
                0 0 0
                1 256 256
                2 512 512
                3 768 768
                4 800 800
                5 1000 1000
                6 1536 1536
                7 1792 1792
                8 2048 2048
                0 0 0
                -1 256 256
                -2 512 512
                -3 768 768
                -4 1024 1024
                -5 1280 1280
                -6 1536 1536
                -7 1792 1792
                -8 2048 2048
                """
            speed.setup(replyString)
            print("completed task work")
            updateResponse("Mock speed data:")
            updateResponse(replyString)
        }
        print("after task work returns")
   }

//    func start() {
//        work = Task {
//            print("start task work")
//            try? await Task.sleep(for: .seconds(3))
//            self.responseString = "Hurrah"
//            print("completed task work")
//        }
//    }
}
