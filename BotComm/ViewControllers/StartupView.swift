//
//  StartupView.swift
//  BotComm
//
//  Created by Bill Snook on 9/24/24.
//

import SwiftUI

let speedIndex = Speed.shared

struct StartupView: View {

    @State var robotComm: SenderProtocol = MockSender.shared    // For testing

    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .center) {
                Form {
                    Section() {
                        ConnectView( robotComm )
                    }
                    if robotComm.connectionState == .connected {
                        Section() {
                            SendCommandView( robotComm )
                        }

                        Section() {
                            HStack {
                                Button("Calibrate") {
                                    path = ["CalibrateView"]
                                    print("Calibrate nav link - path is now \(path)")
//                                    robotComm.sendCmd("D")          // Request device speedIndex data
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
                        }

                        Section() {
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
                        }

                        Section() {
                            HStack {
                                Button("Ping") {
                                    print("Send Ping - not implemented yet")
                                }
                                .buttonStyle(.bordered)

                                Spacer()
                                Button("Center") {
                                    print("Send Center - not implemented yet")
                                }
                                .buttonStyle(.bordered)

                                Spacer()
                                Button("Stop") {
                                    print("Send Stop - not implemented yet")
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
                        }

                        Section() {
                            TextEditor(text: $robotComm.responseString)
                                    .frame(height: 200.0)
//                                    .background(Color.yellow)
                                    .font(.subheadline)
                                    .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "CalibrateView":
                    Text("You selected \(value)")
//                    CalibrateView(robotComm)
                case "ControlView":
                    Text("You selected \(value)")
//                    DriveView()
                default:
                    Text("You selected \(value)")
//                    DriveView()
                }
            }
        }
        .navigationTitle("Bot Comms")
        .navigationBarTitleDisplayMode(.inline)

//        Spacer()
//        ScrollView() {
//        }
//    .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}

#Preview {
    StartupView()
}
