//
//  MockSender.swift
//  BotComm
//
//  Created by William Snook on 5/9/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import SwiftUI
import Observation
//import Darwin.C

protocol SenderProtocol {

    var connectionState: ConnectionState { get set }
    var responseString: String { get set }

    func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String)
    func startResponse(_ message: String)
    func updateResponse(_ message: String)

    func sendData(_ message: [CChar])
    func doBreakConnection()
    func doMakeConnection( to address: String, at port: UInt16 ) -> Bool
    @discardableResult func sendCmd( _ message: String ) -> Bool
    func startConnection(_ hostName: String)
}

@Observable final class MockSender: SenderProtocol {

    static let shared = MockSender()

    // For testing buttons, use connected, else use disconnected
    var connectionState: ConnectionState = .disconnected
    var responseString: String = "Begun, it has..."

    public init() {}

    deinit {
        doBreakConnection()
    }

    // Called from connect button in ConnectView to connect or disconnect to selected robot device
    func requestConnectionStateChange(_ connectionRequest: ConnectionRequest, _ hostName: String) {
        print("MockSender, received \(connectionRequest.rawValue) in connection state \(connectionState.rawValue)")
        switch (connectionRequest, connectionState) {
        case (.connect, .connected):
            startResponse("WARNING - already connected")
        case (.connect, .disconnected):
            connectionState = .connecting
            startResponse("OK - connecting")
            startConnection(hostName)
        case (.disconnect, .connected):
            connectionState = .disconnecting
            startResponse("OK - disconnecting")       // Leave for now for diagnostic purposes
            doBreakConnection()
            startResponse("OK - disconnected")
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
        if connectionState != .disconnected {
            sendCmd( "#" )               // Sign off device
//            usleep( 1000000 )
//            deadTime.invalidate()       // Stop sending keep-alive
//            if socketfd != 0 {
//                close( socketfd )
//                socketfd = 0
//            }
            connectionState = .disconnected
        }
    }

    public func doMakeConnection( to address: String, at port: UInt16 ) -> Bool {
        updateResponse(" Connect to \(address) at port \(port) using \(useDatagramProtocol ? "UDP" : "TCP")")

//        try await Task.sleep(until: .now + .seconds(2), clock: .continuous)”
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

    func startConnection(_ hostName: String) {
        DispatchQueue.global( qos: .userInitiated ).async {
            let connectResult = self.doMakeConnection( to: hostName, at: 5555 )
            if connectResult {
                self.connectionState = .connected
                self.updateResponse(" Connected to host \(hostName)")
            } else {
                self.connectionState = .disconnected
                self.updateResponse(" Failed to connect to host \(hostName)")
            }
        }
    }

}
