import SwiftUI
import SwiftData

struct ResultsView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showShareSheet = false
    @State private var resultsText = ""
    
    let competition: Competition
    
    var sortedParticipants: [Participant] {
        competition.participants.sorted { $0.totalScore > $1.totalScore }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Competition Header
            VStack(alignment: .leading, spacing: 8) {
                Text(competition.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(competition.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Leaderboard
            VStack(alignment: .leading) {
                Text("Final Results")
                    .font(.headline)
                    .padding(.horizontal)
                
                List {
                    ForEach(Array(sortedParticipants.enumerated()), id: \.element.id) { index, participant in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                // Rank
                                VStack(alignment: .center) {
                                    Text("\(index + 1)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(rankColor(for: index + 1))
                                        )
                                        .foregroundColor(.white)
                                }
                                
                                // Participant Info
                                VStack(alignment: .leading) {
                                    Text(participant.fullName)
                                        .font(.headline)
                                    Text("Avg: \(String(format: "%.1f", participant.averageScore))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // Total Score
                                VStack(alignment: .trailing) {
                                    Text("\(participant.totalScore)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("points")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Round Scores
                            HStack(spacing: 8) {
                                ForEach(participant.scores.sorted { $0.roundNumber < $1.roundNumber }, id: \.id) { score in
                                    VStack(alignment: .center, spacing: 4) {
                                        Text("R\(score.roundNumber)")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        Text("\(score.points)")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: generateResultsText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [resultsText])
                }
                
                NavigationLink(destination: ParticipantRegistrationView()) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("New Competition")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Competition Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1:
            return Color.yellow
        case 2:
            return Color.gray
        case 3:
            return Color.orange
        default:
            return Color.blue
        }
    }
    
    private func generateResultsText() {
        var text = "\(competition.name)\n"
        text += "Date: \(competition.date.formatted(date: .abbreviated, time: .omitted))\n"
        text += "================\n\n"
        
        for (index, participant) in sortedParticipants.enumerated() {
            text += "\(index + 1). \(participant.fullName) - \(participant.totalScore) points\n"
            text += "   Average: \(String(format: "%.1f", participant.averageScore))\n"
            
            let sortedScores = participant.scores.sorted { $0.roundNumber < $1.roundNumber }
            for score in sortedScores {
                text += "   Round \(score.roundNumber): \(score.points)\n"
            }
            text += "\n"
        }
        
        resultsText = text
        showShareSheet = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let participant1 = Participant(firstName: "John", lastName: "Doe")
    participant1.scores = [
        Score(points: 95, roundNumber: 1),
        Score(points: 87, roundNumber: 2),
        Score(points: 92, roundNumber: 3)
    ]
    
    let participant2 = Participant(firstName: "Jane", lastName: "Smith")
    participant2.scores = [
        Score(points: 88, roundNumber: 1),
        Score(points: 91, roundNumber: 2),
        Score(points: 89, roundNumber: 3)
    ]
    
    let competition = Competition(name: "Championship 2024", date: Date())
    competition.participants = [participant1, participant2]
    
    ResultsView(competition: competition)
        .modelContainer(for: Competition.self, inMemory: true)
}
