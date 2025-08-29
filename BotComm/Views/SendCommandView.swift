//
//  SendCommandView.swift
//  RobotController
//
//  Created by Bill Snook on 6/28/23.
//

import SwiftUI

struct SendCommandView: View {

    var robotComm: SenderProtocol

    @State private var commandField: String = ""

    init(_ deviceCommAgent: SenderProtocol) {
        robotComm = deviceCommAgent
    }

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

struct SendCommandView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Section() {
                SendCommandView(MockSender.shared)
            }
        }
    }
}
