//
//  TestSpeedSetting.swift
//  RobotController
//
//  Created by Bill Snook on 7/25/23.
//

import SwiftUI

struct TestSpeedSetting: View {
    var body: some View {
        HStack {
            Button("Run") {
                print("Run button action")
            }
            .buttonStyle(.bordered)

            Spacer()
            Button("Stop") {
                print("Stop button action")
            }
            .buttonStyle(.bordered)
            Spacer()
            Button("Return") {
                print("Return button action")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct TestSpeedSetting_Previews: PreviewProvider {
    static var previews: some View {
        TestSpeedSetting()
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
