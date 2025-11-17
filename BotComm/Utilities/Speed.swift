//
//  Speed.swift
//  RobotController
//
//  Created by Bill Snook on 8/5/23.
//

import Foundation
//import Combine

/// Our robot motor controller accepts speed settings of from 0 to 4096. We want a simple range of 0 to 8.
/// The robot maintains a list of speed settings to send to the motor controller to control the tread speed.
/// We use an index to give us matched speeds so both forward and backward motions are straight lines.
/// To make sure the two tread sides are moving at the same speed, we calibrate the list so both motors
/// receive the correct values to move at the same rate and the robot moves straight when needed.
/// Currently we have 8 speeds forward and 8 backwards, stored on the robot in a file it reads at startup.
/// 1 is the slowest speed for a given direction and 8 is the fastest. Our controller sends these indexes to
/// set the current speed.

//             left | right
// -8 7 6 5 4 3 2 1 0 1 2 3 4 5 6 7 8   selectedIndex   displayed index
//  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6   internalIndex   array index

let defaultSpeedArrayIndexSpace = 8
let speedArraySpeedIncrements = 256     // 256 for testing should be able to use 512 (2048 vs 4096 top end)

struct SpeedChartEntry: Identifiable, Hashable {
    var index: String
    var value: Int
    var id: String { index }
}

@Observable final class Speed {

    static let shared = Speed()

    var left = [SpeedChartEntry]()
    var right = [SpeedChartEntry]()

    var internalIndex: Int = defaultSpeedArrayIndexSpace + 1    // Default index is slowest forward speed, modified by Picker

    // These booleans are used to support the confirmation dialogs for saving and restoring robot working data to the startup file
    @ObservationIgnored var hasValidSpeedArray = false          // Not loaded initially, using fill in default
    var speedArrayHasChanged = false        // If has been changed since last loaded
//    @ObservationIgnored var speedArrayLoadSelected = false      // Action indicators for load and save speed index buttons pressed
//    @ObservationIgnored var speedArraySaveSelected = false

    @ObservationIgnored var indexSpace = defaultSpeedArrayIndexSpace    // Number of speed indexes; normally 8 but set by device
    @ObservationIgnored var selectedIndex: Int {                        // External usage, -indexSpace...indexSpace
        internalIndex - indexSpace
    }


    @ObservationIgnored @Published private var speedMessage = ""

    // Deprecated // Used by the load/save logic to show a confirmation dialog if entries are changed
//    var showLoadConfirmation: Bool = false {
//        get {
//            speedArrayHasChanged
//        }
//        set {
//            print("----    Set called on showLoadConfirmation - why? newValue is \(newValue ? "True" : "False")")
//            speedArrayHasChanged = newValue
//        }
//    }
//    var showSaveConfirmation: Bool {
//        get {
//            speedArrayHasChanged
//        }
//        set {
//            print("----    Set called on showSaveConfirmation - why? newValue is \(newValue ? "True" : "False")")
//            speedArrayHasChanged = newValue
//        }
//    }


    private init() {
        setup()
    }

    // Setup initial default speed index array - used as placeholder if no device version at setup time
    func setup(_ initialIndex: Int = 1) {     // No set speed data yet, create initial array
        guard !hasValidSpeedArray else {
            return
        }
        indexSpace = defaultSpeedArrayIndexSpace
//        print("Speed.setup, default, indexSpace == \(indexSpace)")
        internalIndex = indexSpace + initialIndex
        var left = Array(repeating: SpeedChartEntry(index: "0", value: 0), count: indexSpace * 2 + 1)
        var right = Array(repeating: SpeedChartEntry(index: "0", value: 0), count: indexSpace * 2 + 1)
        for arrayIndex in 0...(indexSpace * 2) {
            let displayIndex = arrayIndex - indexSpace
            left[arrayIndex] = SpeedChartEntry(index: String(displayIndex),
                                               value: speedArraySpeedIncrements * abs(displayIndex))
            right[arrayIndex] = SpeedChartEntry(index: String(displayIndex),
                                                value: speedArraySpeedIncrements * abs(displayIndex))
//            print("\(displayIndex): \(left[arrayIndex])  \(right[arrayIndex])")
        }
        self.left = left
        self.right = right
        hasValidSpeedArray = true
    }

    // Set speed index array from response from device with it's speed index data
    func setup(_ message: String, _ initialIndex: Int = 1) {
        let msgParts = message.split(separator: "\n")
        let header = msgParts[0].split(separator: " ")
        guard header.count == 2 else {
            print("Invalid data from device: \(message)")
            return
        }
        // header[0] should be "D" as an identifier for this data format for index entries
        // header[1] should be the count of indexes, usually 8
        indexSpace = Int( header[1] ) ?? defaultSpeedArrayIndexSpace    // defaultSpeedArrayIndexSpace = 8
///        print("Speed.setup from device, indexSpace == \(indexSpace)")
        internalIndex = indexSpace + initialIndex
        var left = Array(repeating: SpeedChartEntry(index: "0", value: 0), count: indexSpace * 2 + 1)
        var right = Array(repeating: SpeedChartEntry(index: "0", value: 0), count: indexSpace * 2 + 1)
        // Here we update the Speed object, speed
        hasValidSpeedArray = true
        for paramString in msgParts {
            let entry = paramString.split(separator: " ")
            if entry[0] != "D" {    // Skip header
                let optIndex = Int( entry[0] )
                let optLeft = Int( entry[1] )
                let optRight = Int( entry[2] )
                if let index = optIndex, let leftValue = optLeft, let rightValue = optRight {   //  Verify valid integers
                    let walkingIndex = index + indexSpace
                    if walkingIndex >= 0 {
///                        print("\(index), walkingIndex: \(walkingIndex): \(leftValue)  \(rightValue)")
                        left[walkingIndex] = SpeedChartEntry(index: String(index),
                                                             value: leftValue)
                        right[walkingIndex] = SpeedChartEntry(index: String(index),
                                                              value: rightValue)
                    } else {
                        print("Speed.setup index error for index == \(index), internalIndex == \(internalIndex)")
                        hasValidSpeedArray = false
                    }
                } else {
                    print("Speed.setup data error for index == \(optIndex ?? 999), internalIndex == \(internalIndex)")
                    hasValidSpeedArray = false
                }
            }
        }
        self.left = left
        self.right = right
    }
/*
    Speed.setup from device, indexSpace == 8
    0, walkingIndex: 8: 0  0
    1, walkingIndex: 9: 256  256
    2, walkingIndex: 10: 512  512
    3, walkingIndex: 11: 768  768
    4, walkingIndex: 12: 800  800
    5, walkingIndex: 13: 1280  1280
    6, walkingIndex: 14: 1536  1536
    7, walkingIndex: 15: 1792  1792
    8, walkingIndex: 16: 2048  2048
    0, walkingIndex: 8: 0  0
    -1, walkingIndex: 7: 256  256
    -2, walkingIndex: 6: 512  512
    -3, walkingIndex: 5: 768  768
    -4, walkingIndex: 4: 1024  1024
    -5, walkingIndex: 3: 1280  1280
    -6, walkingIndex: 2: 1536  1536
    -7, walkingIndex: 1: 1792  1792
    -8, walkingIndex: 0: 2048  2048
    completed task work
*/

    var leftFloat: Float {
        get {
            Float(left[internalIndex].value)
        }
        set {
            left[internalIndex].value = Int(newValue)
        }
    }

    var leftString: String {
        get {
            String(left[internalIndex].value)
        }
        set {
            left[internalIndex].value = Int(newValue) ?? 0
        }
    }

    var rightFloat: Float {
        get {
            Float(right[internalIndex].value)
        }
        set {
            right[internalIndex].value = Int(newValue)
        }
    }

    var rightString: String {
        get {
            String(right[internalIndex].value)
        }
        set {
            right[internalIndex].value = Int(newValue) ?? 0
        }
    }
}

