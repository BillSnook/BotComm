//
//  ConnectView.swift
//  RobotController
//
//  Created by Bill Snook on 6/25/23.
//

import SwiftUI

// Button function/name
enum ConnectionRequest: String {
    case connect = "Connect"
    case disconnect = "Disconnect"
}

struct ConnectView: View {

    // Known devices using their .local network names
    enum Devices: String, CaseIterable, Identifiable {
        case camera01
        case donald
        case goofy
        case hughie
        case dewie
        case louie
        case develop00
        case develop01
        case develop40
        case develop50
        case devx
        case mockery

        var id: String { self.rawValue.capitalized }
    }
    @State private var selectedDevice: Devices = .mockery

    let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)

    // This is the Sender object and here we get updates whenever any of it's @Published object changes
    var robotComm: SenderProtocol

    var connectionRequest: ConnectionRequest

    init(_ deviceCommAgent: SenderProtocol) {
        robotComm = deviceCommAgent
        connectionRequest = robotComm.connectionState == .disconnected ? .connect : .disconnect
    }

    var body: some View {
        HStack {
            if robotComm.connectionState == .disconnected {
                Picker("Robot", selection: $selectedDevice) {
                    ForEach(Devices.allCases) { devices in
                        Text(devices.rawValue.capitalized).tag(devices)
                    }
                }
                .frame(width: 190.0, height: 0.0)
                .pickerStyle(MenuPickerStyle())
                .position(CGPoint(x: 90.0, y: 8.0))
                .padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 0.0, trailing: 0.0))

                Spacer()
                    .background(.orange)
                Button(action: {
                    connectionButtonAction()
                }) {
                    Text(robotComm.connectionState.buttonName())
                }
                .buttonStyle(.bordered)
                .background(lightGray)
                .foregroundColor(.black)
                .cornerRadius(10.0)
                Spacer()
                    .background(.orange)
            } else {
                Spacer()
                Button(action: {
                    connectionButtonAction()
                }) {
                    Text(robotComm.connectionState.buttonName())
                }
                .buttonStyle(.bordered)
                .background(robotComm.connectionState == .connecting ? .clear : lightGray)
                .foregroundColor(robotComm.connectionState == .connecting ? .gray : .black)
                .cornerRadius(10.0)
                Spacer()
                Text(selectedDevice.id)
                Spacer()
            }

        }
    }
    
    func connectionButtonAction() {
        print("\nConnectView, requesting \(connectionRequest.rawValue) in connection state \(robotComm.connectionState.rawValue)")
        if robotComm.connectionState == .disconnected {
            print("  Requesting connect to \(selectedDevice.id)")
            robotComm.requestConnectionStateChange(.connect, selectedDevice.id)
        } else {
            print("  Requesting disconnect")
            robotComm.requestConnectionStateChange(.disconnect, selectedDevice.id)
        }
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Form {
                Section() {
                    ConnectView(Sender.shared)
                }
           }
       }
    }
}
