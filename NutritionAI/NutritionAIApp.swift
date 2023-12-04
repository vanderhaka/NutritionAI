//
//  NutritionAIApp.swift
//  NutritionAI
//
//  Created by James Vanderhaak on 4/12/2023.
//

import SwiftUI

@main
struct NutritionAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
