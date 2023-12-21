//
//  PayToteApp.swift
//  PayTote
//
//  Created by Rohan Sehgal on 11/19/23.
//

import SwiftUI

@main
struct PayToteApp: App {
    /// ``persistenceController`` is used to control the CoreData databases context, which is passed as an environment object to be used in the application.
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSettings())
                .environmentObject(TabSelection())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
