//
//  CalibrateView.swift
//  RobotController
//
//  Created by Bill Snook on 7/17/23.
//

/*

The controller (this app) uses a small number of indexes (currently 8) to
 manage the robots speed while the robot speed controller uses 4096 steps.
The index file maps each index to a speed step to simplify speed control.
The robot defaults to a simple linear progression if no file is found but
 this does not acccount for speed differences between the tracks for the
 same settings so that needs to be calibrated. We may also want to change
the progression to give more control over faster or slower speed ranges.

The robots store a file copy of their index of speeds to read at startup
 into a working copy in main memory for use during operation.
This view allows editing this data. At entry we ask for a copy from the robot
 and display the entries textually and graphically and allow changes.
Changes when made are transmitted to the robot which updates its working copy
 and allows testing the changes using simple controls to run, stop, and return.
We also can send commands to save this current state, which includes the
 recent changes, to the file for subsequent restarts. Or to reread the file
 to overwrite our changes if desired.

    File  <-->  Robot memory  <~~ WiFi ~~>  This apps Calibrate module
      ^           ^                           ^  Uses and edits data in robot working copy, tests changes,
      |           |                              saves changes to file, restores data from file and to app
      |           |  Holds working copy, updated with changes from editing controls
      |  Read from at startup, read from with Load button command, saved to with Save Button command
*/

import SwiftUI

struct CalibrateView: View {
    @Environment(Sender.self) private var robotComm

    @State private var speed: Speed

    init() {
        speed = Speed.shared
    }

    var body: some View {
        VStack(alignment: .center) {
            SpeedFileActions(speedIndex: speed)
                .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
            Spacer()
                .frame(height: 10.0)
            SpeedIndexSetup(speedIndex: speed)
            Spacer()
                .frame(height: 20.0)
            TestSpeedSetting(speedIndex: speed)
            Spacer()
                .frame(height: 10.0)
            SpeedChart(speed)
            Spacer()
                .frame(height: 0.0)
            @Bindable var bot = robotComm
            TextEditor(text: $bot.responseString)
                    .frame(height: 100.0)
                    .font(.caption)
                    .padding(EdgeInsets(top: 4.0, leading: -10.0, bottom: 4.0, trailing: -10.0))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Track Alignment")
        .padding(EdgeInsets(top: -40.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
//        .background(.yellow)
    }
}

#Preview {
    CalibrateView()
        .environment(Sender())
}
