//
//  MockSender.swift
//  BotComm
//
//  Created by William Snook on 8/20/25.
//  Copyright © 2025 billsnook. All rights reserved.
//

import SwiftUI
import Observation

@Observable final class MockSender: SenderProtocol {

    static let shared = MockSender()

    var connectionState: ConnectionState = .disconnected
    var responseString: String = "Begun, it has..."

    public init() {
        // For testing buttons, use connected, else use disconnected
        connectionState = .connected
    }

    deinit {
        doBreakConnection()
    }

    // Called from connect button in ConnectView to connect or disconnect to selected robot device
    func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String) {
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

    func startResponse(_ message: String) {
        responseString = message
    }

    func updateResponse(_ message: String) {    // With message received from device

//        print(">> \(message)")
        switch message.first {
        case "S":
            print(">> Got speed index file from device")
            speedIndex.setup(message)
        case "T":
            responseString += "\n----    Got Camera data, todo    ----\n" + message
        default:
            responseString += "\n\(message)"
        }
    }
/* */
    // Here we have an array of bytes corresponding to the depth data from the tof camera
    // (with the two byte header, C0). For just one center line for now, 240 bytes.
    func sendData(_ message: [CChar]) {

        responseString = "\nGot tof camera data\n"
    }

    public func doBreakConnection() {
        startResponse("OK - disconnecting")
        sendCmd( "#" )               // Sign off device
        connectionState = .disconnecting
        DispatchQueue.global( qos: .userInitiated ).async {
            usleep( 1000000 )
            self.connectionState = .disconnected
        }
    }

    func startConnection(_ hostName: String) {
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

    public func doMakeConnection( to address: String, at port: UInt16 ) -> Bool {
        updateResponse(" Connect to \(address) at port \(port) using \(useDatagramProtocol ? "UDP" : "TCP")")

        usleep( 1000000 )
        return true
    }


    @discardableResult public func sendCmd( _ message: String ) -> Bool {

        guard connectionState == .connected else {
            updateResponse(" sendCmd socket not connected while sending \(message)")
            return false
        }

        guard !message.isEmpty else {
            updateResponse(" sendCmd message to send is empty")
            return false
        }

        // Handle creating responses to selected commands here
        switch message {

        default:
            print("sendCmd with <\(message)> command not recognized")
        }


        return true
    }
}
