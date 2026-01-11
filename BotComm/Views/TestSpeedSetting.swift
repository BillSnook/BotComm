//
//  TestSpeedSetting.swift
//  RobotController
//
//  Created by Bill Snook on 7/25/23.
//

import SwiftUI

struct TestSpeedSetting: View {
    @Environment(Sender.self) private var robotComm

    @State private var speed: Speed

    init(speedIndex: Speed) {
        speed = speedIndex
    }

     var body: some View {
        HStack {
            Button("Run") {
                print("Run button action")
                robotComm.sendCmd("G \(speed.internalIndex - speed.indexSpace)")
            }
            .buttonStyle(.bordered)

            Spacer()
            Button("Stop") {
                print("Stop button action")
                robotComm.sendCmd("S")
            }
            .buttonStyle(.bordered)
            Spacer()
            Button("Return") {
                print("Return button action")
            }
            .buttonStyle(.bordered)
            .disabled(true)     // In development
        }
    }
}

#Preview {
    TestSpeedSetting(speedIndex: Speed.shared)
        .environment(MockSender(Speed.shared) as Sender)
        .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
}
