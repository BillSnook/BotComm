//
//  StartupView.swift
//  BotComm
//
//  Created by Bill Snook on 9/24/24.
//

import SwiftUI

struct StartupView: View {
    @Environment(Sender.self) private var robotComm

    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .center) {
                Form {
                    Section() {
                       ConnectView()
                    }
                    if robotComm.connectionState != .disconnected {
                        Section() {
                            SendCommandView()
                        }

                        Section() {
                            HStack {
                                Button("Calibrate") {
                                    path = ["CalibrateView"]
                                    print("Calibrate nav link - path is now \(path)")
                                    // // Prerequest speedIndex
                                    robotComm.sendCmd("D")
                                }
                                .buttonStyle(.bordered)

                                Spacer()
                                Button("Control") {
                                    path = ["DriveView"]
                                    print("Control nav link - path is now \(path)")
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // In development

                                Spacer()
                                Button("Direct") {
                                    print("Direct control  - not finished - going nowhere")
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // In development
                            }
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))

                            HStack {
                                Button("Status") {
                                    print("Send Status Request")
                                    robotComm.sendCmd( "@" )
                                    robotComm.startResponse("\nSent Status Request\n")
                                }
                                .buttonStyle(.bordered)

                                Spacer()
                                Button("Range") {
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // In development

                                Spacer()
                                Button("Clear") {
                                    robotComm.startResponse("")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))

                            HStack {
                                Button("Ping") {
                                    print("Send Ping - not implemented yet")
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // Deprecated

                                Spacer()
                                Button("Center") {
                                    print("Send Center - not implemented yet")
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // Deprecated

                                Spacer()
                                Button("Stop") {
                                    print("Send Stop - not implemented yet")
                                }
                                .buttonStyle(.bordered)
                                .disabled(true)     // Deprecated
                            }
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
                        }

                        Section() {
                            @Bindable var bot = robotComm
                            TextEditor(text: $bot.responseString)
                                    .frame(height: 200.0)
                                    .font(.caption)
                                    .padding(EdgeInsets(top: 0.0, leading: -10.0, bottom: 0.0, trailing: -10.0))
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "CalibrateView":
//                    Text("You selected \(value)")
                    CalibrateView()
                case "ControlView":
                    Text("You selected \(value)")
//                    DriveView()
                default:
                    Text("You selected \(value)")
//                    DriveView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Bot Communication")
            .padding(EdgeInsets(top: -30.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
        }

//        Spacer()
//        ScrollView() {
//        }
//    .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}

#Preview {
    StartupView()
        .environment(MockSender() as Sender)
}
