//
//  SpeedChart.swift
//  RobotController
//
//  Created by Bill Snook on 12/22/23.
//

import SwiftUI
import Charts

struct SpeedChart: View {

    private var speed: Speed

    init(_ speedIndex: Speed) {
        speed = speedIndex
    }

    var body: some View {
        Spacer()
            .frame(height: 12.0)
        Text("Left")
        Spacer()
            .frame(height: 4.0)
        Chart {
            ForEach(speed.left, id: \.self) { speedEntry in
                LineMark(
                    x: .value("Index", speedEntry.index),
                    y: .value("Min", speedEntry.index.first == "-" ? -speedEntry.value : speedEntry.value)
                )
            }
        }
        .frame(height: 120)
        .padding(EdgeInsets(top: 0.0, leading: -8.0, bottom: 0.0, trailing: -8.0))
        Spacer()
            .frame(height: 10.0)
        Text("Right")
        Spacer()
            .frame(height: 4.0)
        Chart {
            ForEach(speed.right, id: \.self) { speedEntry in
                LineMark(
                    x: .value("Index", speedEntry.index),
                    y: .value("Min", speedEntry.index.first == "-" ? -speedEntry.value : speedEntry.value)
                )
            }
        }
        .frame(height: 120)
        .padding(EdgeInsets(top: 0.0, leading: -8.0, bottom: 10.0, trailing: -8.0))
    }
}

#Preview {
    SpeedChart(Speed.shared)
}
