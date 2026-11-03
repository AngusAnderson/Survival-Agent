import SwiftUI
import SwiftData

@main struct SurvivalAgentApp: App {
    private let container: ModelContainer
    
    init() {
        do {
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            
            container = try ModelContainer(
                for: Waypoint.self,
                configurations: configuration
            )
        } catch {
            fatalError(
                "Unable to initialise local waypoint storage: \(error)"
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
