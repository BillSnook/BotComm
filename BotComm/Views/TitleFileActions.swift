//
//  TitleFileActions.swift
//  RobotController
//
//  Created by Bill Snook on 7/15/23.
//

import SwiftUI

struct TitleFileActions: View {
    let title: String       // Control title, presented between the buttons

    @State var speed = speedIndex

    var robotComm: SenderProtocol

    init(_ deviceCommAgent: SenderProtocol, title: String) {
        robotComm = deviceCommAgent
        self.title = title
    }

    var body: some View {
        HStack {
            Button("Load", role: speed.speedArrayHasChanged ? .destructive : .cancel) {
                print("Loading speed index file")
                speed.speedArrayLoadSelected = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                "This will reload the speed index entries from the device",
                isPresented: $speed.showLoadConfirmation)
            {
                Button("Reload from the device", role: .destructive) {
                    print("Reloading device index entries")
                    loadFile()
                    speed.speedArrayHasChanged = false
                    speed.speedArrayLoadSelected = false
                }
                Button("Cancel", role: .cancel) {
                    print("Cancelled loading device index entries")
                    speed.speedArrayLoadSelected = false
                }
            } message: {
                Text("This will replace any unsaved changes with the current device set of entries.\nYou cannot undo this action.")
            }

            Spacer()
            Text(title)
                .font(.headline)
//                .fontWeight(.semibold)
            Spacer()
            Button("Save", role: speed.speedArrayHasChanged ? .destructive : .cancel) {
                print("Saving speed index file changes")
                speed.speedArraySaveSelected = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                "This will save the speed index entries to the device and override existing entries",
                isPresented: $speed.showSaveConfirmation)
            {
                Button("Save on the device", role: .destructive) {
                    print("Saving device index entries")
                    saveFile()
                    speed.speedArrayHasChanged = false
                    speed.speedArraySaveSelected = false
                }
                Button("Cancel", role: .cancel) {
                    print("Cancelled saving device index entries")
                    speed.speedArraySaveSelected = false
                }
            } message: {
                Text("This will save any changes to the current device.\nYou cannot undo this action.")
            }
        }
    }

    private func loadFile() {
        robotComm.sendCmd("D")  // Request speed file data from device
    }

    private func saveFile() {
        robotComm.sendCmd("d")  // Send speed file data to device to save locally
    }
}

struct TitleFileActions_Previews: PreviewProvider {
    static var previews: some View {
        TitleFileActions(MockSender.shared, title: "Alignment")
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
    }
}
