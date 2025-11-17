//
//  SpeedIndexSetup.swift
//  RobotController
//
//  Created by Bill Snook on 7/26/23.
//

import SwiftUI

struct SpeedIndexSetup: View {

    private var robotComm: SenderProtocol

    @State private var speed: Speed

    init(_ deviceCommAgent: SenderProtocol, speedIndex: Speed) {
        robotComm = deviceCommAgent
        speed = speedIndex
    }

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("Index")
                    Picker("S", selection: $speed.internalIndex) {
                        ForEach(-8..<9) { speedIdx in
                            Text("\(speedIdx)")
                                .font(.title2)
                                .fontWeight(.regular)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .position(CGPoint(x: 30.0, y: 40.0))
                    .frame(width: 80.0, height: 90.0)
                    .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                    VStack {
                        HStack {
                            Text("L")
                            Slider(value: $speed.leftFloat, in: 0...4095, step: 256,
                                   onEditingChanged: { editing in
                                if !editing {       // editing will be false when done moving slider (touch-up)
                                    sendUpdateSpeedEntry(speed)
                                }
                            })
                        }
                        HStack {
                            Text("R")
                            Slider(value: $speed.rightFloat, in: 0...4095, step: 256,
                                   onEditingChanged: { editing in
                                if !editing {       // editing will be false when done moving slider (touch-up)
                                    sendUpdateSpeedEntry(speed)
                                }
                          })
                        }
                    }
                }
                HStack {
                    Text("L")
                    TextField("0", text: $speed.leftString)
                        .multilineTextAlignment(.center)
                        .frame(width: 80.0)
                        .border(.black)
                        .onSubmit {
                            print("In onSubmit for left string update")
                            sendUpdateSpeedEntry(speed)
                        }
                    Spacer()
                    if speed.selectedIndex > 0 {
                        Text("Forward \(speed.selectedIndex)")
                            .font(.headline)
                    } else if speed.selectedIndex == 0 {
                        Text("Stopped")
                            .font(.headline)
                    } else {
                        Text("Reverse \(-speed.selectedIndex)")
                            .font(.headline)
                    }
                    Spacer()
                    TextField("1", text: $speed.rightString)
                        .multilineTextAlignment(.center)
                        .frame(width: 80.0)
                        .border(.black)
                        .onSubmit {
                            print("In onSubmit for right string update")
                            sendUpdateSpeedEntry(speed)
                        }
                    Text("R")
                }
            }
        }
    }

    private func sendUpdateSpeedEntry(_ speed: Speed) {
        let index = speed.internalIndex
//        print("In sendUpdateSpeedEntry for index \(index)")
        robotComm.sendCmd("E \(index) \(speed.left[index].value) \(speed.right[index].value)")
        speed.speedArrayHasChanged = true
    }
}

struct SpeedIndexSetup_Previews: PreviewProvider {
    static var previews: some View {
        SpeedIndexSetup(MockSender.shared, speedIndex: Speed.shared)
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
