//
//  SpeedChart.swift
//  RobotController
//
//  Created by Bill Snook on 12/22/23.
//

import SwiftUI
import Charts

struct SpeedChart: View {
    var speed = speedIndex

    var body: some View {
        Text("Left")
        Chart {
            ForEach(speed.left, id: \.self) { speedEntry in
                LineMark(
                    x: .value("Index", speedEntry.index),
                    y: .value("Min", speedEntry.index.first == "-" ? -speedEntry.value : speedEntry.value)
                )
            }
        }
        .frame(height: 140)
        .padding()
        Spacer()
        Text("Right")
        Chart {
            ForEach(speed.right, id: \.self) { speedEntry in
                LineMark(
                    x: .value("Index", speedEntry.index),
                    y: .value("Min", speedEntry.index.first == "-" ? -speedEntry.value : speedEntry.value)
                )
            }
        }
        .frame(height: 140)
        .padding()
    }
}

#Preview {
    SpeedChart()
}
