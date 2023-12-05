import SwiftUI
import Firebase

@main
struct NutritionAIApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()  // Initialize Firebase
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
