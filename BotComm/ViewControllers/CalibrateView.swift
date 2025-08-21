//
//  CalibrateView.swift
//  RobotController
//
//  Created by Bill Snook on 7/17/23.
//

import SwiftUI

struct CalibrateView: View {

//    @State var speedEntryChanged = false   // Track whether any speed entry has changed
    var robotComm: SenderProtocol

    init(_ deviceCommAgent: SenderProtocol) {
        robotComm = deviceCommAgent
    }

    var body: some View {
        VStack {
            TitleFileActions(robotComm, title: "Speed Alignment")
                .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
            Spacer()
                .frame(height: 20.0)
            SpeedFileActions()
            Spacer()
                .frame(height: 10.0)
            SpeedIndexSetup()
//                .background(.green)
            Spacer()
                .frame(height: 20.0)
            TestSpeedSetting()
            Spacer()
            SpeedChart()
            Spacer()
        }
        .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}

struct CalibrateView_Previews: PreviewProvider {
    static var previews: some View {
        CalibrateView(Sender.shared)
            .previewLayout(.sizeThatFits)
    }
}
