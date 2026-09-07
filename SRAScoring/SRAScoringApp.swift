import SwiftUI
import SwiftData

@main
struct SRAScoringApp: App {
    let modelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ParticipantRegistrationView()
            }
        }
        .modelContainer(modelContainer)
    }
    
    init() {
        let schema = Schema([
            Participant.self,
            Competition.self,
            Score.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}
