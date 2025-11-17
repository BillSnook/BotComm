//
//  SpeedFileActions.swift
//  RobotController
//
//  Created by Bill Snook on 7/15/23.
//

import SwiftUI

struct SpeedFileActions: View {
    public var saveStatus: String       // Control status display, presented between the buttons

    private var robotComm: SenderProtocol

    @State private var speed: Speed
    @State private var loadConfirmationDialog = false
    @State private var saveConfirmationDialog = false

    init(_ deviceCommAgent: SenderProtocol, speedIndex: Speed, saveStatus: String = "") {
        robotComm = deviceCommAgent
        speed = speedIndex
        self.saveStatus = saveStatus
        speed.speedArrayHasChanged = false      // Not set on entry to not trigger confirmation dialog
    }

    var body: some View {
        HStack {
            Button("Revert", role: .destructive) {
                print("Loading robots saved speed index file")
                loadConfirmationDialog = true
            }
            .buttonStyle(.bordered)
            .disabled(!speed.speedArrayHasChanged)
            .confirmationDialog(
                "This will reload the speed index entries from the device",
                isPresented: $loadConfirmationDialog)
            {
                Button("Reload from the device", role: .destructive) {
                    print("Reloading device index entries")
                    loadFile()
                    speed.speedArrayHasChanged = false
                }
//                Button("Cancel", role: .cancel) {
//                    print("Cancelled loading device index entries")
//                }
            } message: {
                Text("This will replace any unsaved changes with the saved set of entries.\nYou cannot undo this action.")
            }

            Spacer()
            Text(speed.speedArrayHasChanged ? "Changes not saved" : "No changes yet")
                .font(.subheadline)
//                .fontWeight(.semibold)

            Spacer()
            Button("Save", role: .destructive) {
                print("Saving speed index file changes")
                saveConfirmationDialog = true
            }
            .buttonStyle(.bordered)
            .disabled(!speed.speedArrayHasChanged)
            .confirmationDialog(
                "This will save the speed index entries to the device and override existing entries",
                isPresented: $saveConfirmationDialog)
            {
                Button("Save on the device", role: .destructive) {
                    print("Saving device index entries")
                    saveFile()
                    speed.speedArrayHasChanged = false
                }
//                Button("Cancel", role: .cancel) {
//                    print("Cancelled saving device index entries")
//                }
            } message: {
                Text("This will save any changes to the current device.\nYou cannot undo this action.")
            }
        }
    }

    private func loadFile() {
        robotComm.sendCmd("C")  // Request speed file data from device disk file
    }

    private func saveFile() {
        robotComm.sendCmd("W")  // Send speed file data to device to save as local startup speed index file
    }
}

struct SpeedFileActions_Previews: PreviewProvider {
    static var previews: some View {
        SpeedFileActions(MockSender.shared, speedIndex: Speed.shared, saveStatus: "Preview")
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
