//
//  SendCommandView.swift
//  RobotController
//
//  Created by Bill Snook on 6/28/23.
//

import SwiftUI

struct SendCommandView: View {
    @Environment(Sender.self) private var robotComm

    @State private var commandField: String = ""

    var body: some View {
        HStack {
            Button("Send") {
                print("Send sending \(commandField)")
                robotComm.sendCmd( commandField )
           }
                .buttonStyle(.bordered)
                .disabled(commandField.isEmpty)
            TextField("Type a command here", text: $commandField)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
        }
            .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
    }
}

#Preview {
    Form {
        Section() {
            SendCommandView()
                .environment(MockSender() as Sender)
        }
    }
}
