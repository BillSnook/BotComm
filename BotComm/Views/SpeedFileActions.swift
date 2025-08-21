//
//  SpeedFileActions.swift
//  RobotController
//
//  Created by Bill Snook on 7/25/23.
//

import SwiftUI

struct SpeedFileActions: View {
    @State private var presentDialog = false
    var body: some View {
        HStack {
            Button("Fill Index") {
                print("Fill button action to fill forward entries")
            }
            .buttonStyle(.bordered)

//            Spacer()
//            Button("Reset") {
//                print("Reset button action to set default speed index entry settings")
//                presentDialog = true
//            }
//            .buttonStyle(.bordered)
////            .confirmationDialog(
////                "This will return the speed index entries to their default settings",
////                isPresented: $presentDialog)
////            {
////                Button("Reset to initial unmodified state", role: .destructive) {
////                    print("Resetting to default state")
////                    resetSpeedModel()
////
////                }
////            } message: {
////                Text("This will replace any unsaved changes with the default initial set of entries.\nYou cannot undo this action.")
////            }

            Spacer()
            Button("Fill Reverse") {
                print("Fill Reverse button action to fill reverse entries")
            }
            .buttonStyle(.bordered)
        }
    }

    func resetSpeedModel() {
        speedIndex.setup()
    }
}

struct SpeedFileActions_Previews: PreviewProvider {
    static var previews: some View {
        SpeedFileActions()
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
