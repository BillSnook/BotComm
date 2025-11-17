//
//  TestSpeedSetting.swift
//  RobotController
//
//  Created by Bill Snook on 7/25/23.
//

import SwiftUI

struct TestSpeedSetting: View {

    private var robotComm: SenderProtocol

    @State private var speed: Speed

    init(_ deviceCommAgent: SenderProtocol, speedIndex: Speed) {
        robotComm = deviceCommAgent
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

struct TestSpeedSetting_Previews: PreviewProvider {
    static var previews: some View {
        TestSpeedSetting(MockSender.shared, speedIndex: Speed.shared)
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
