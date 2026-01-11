//
//  BotCommApp.swift
//  BotComm
//
//  Created by Bill Snook on 9/24/24.
//

import SwiftUI

@main
struct BotCommApp: App {
    @State private var robotComm = Sender()     // 'source of truth', storage for this class implementation

    var body: some Scene {
        WindowGroup {
            StartupView()
                .environment(robotComm)         // Makes robotComm available to this and all it's subviews
        }
    }
}
