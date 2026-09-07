import SwiftUI
import SwiftData

struct ScoringView: View {
    @Environment(\.modelContext) var modelContext
    @State private var currentRound = 1
    @State private var scores: [String: Int] = [:]
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToResults = false
    
    let competition: Competition
    let roundCount: Int
    let maxScore: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Round Indicator
            HStack {
                Text("Round \(currentRound) of \(roundCount)")
                    .font(.headline)
                Spacer()
                ProgressView(value: Double(currentRound), total: Double(roundCount))
                    .frame(width: 100)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Scoring List
            List {
                ForEach(competition.participants, id: \.id) { participant in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(participant.fullName)
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            TextField("Score", value: Binding(
                                get: { scores[participant.id?.uuidString ?? ""] ?? 0 },
                                set: { newValue in
                                    let clampedValue = min(max(newValue, 0), maxScore)
                                    scores[participant.id?.uuidString ?? ""] = clampedValue
                                }
                            ), format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            Text("/ \(maxScore)")
                                .foregroundColor(.gray)
                            
                            Stepper(
                                value: Binding(
                                    get: { scores[participant.id?.uuidString ?? ""] ?? 0 },
                                    set: { newValue in
                                        let clampedValue = min(max(newValue, 0), maxScore)
                                        scores[participant.id?.uuidString ?? ""] = clampedValue
                                    }
                                ),
                                in: 0...maxScore
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                if currentRound > 1 {
                    Button(action: previousRound) {
                        Text("Previous")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if currentRound < roundCount {
                    Button(action: nextRound) {
                        Text("Next Round")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    NavigationLink(destination: ResultsView(competition: competition), isActive: $navigateToResults) {
                        Button(action: finishCompetition) {
                            Text("Finish & View Results")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Score Entry")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear(perform: loadScores)
    }
    
    private func loadScores() {
        // Load scores for current round from participants
        for participant in competition.participants {
            let id = participant.id?.uuidString ?? ""
            let roundScores = participant.scores.filter { $0.roundNumber == currentRound }
            if let score = roundScores.first {
                scores[id] = score.points
            } else {
                scores[id] = 0
            }
        }
    }
    
    private func saveRound() {
        for participant in competition.participants {
            let id = participant.id?.uuidString ?? ""
            let score = scores[id] ?? 0
            
            // Check if score for this round exists
            if let existingScore = participant.scores.first(where: { $0.roundNumber == currentRound }) {
                existingScore.points = score
            } else {
                let newScore = Score(points: score, roundNumber: currentRound)
                participant.scores.append(newScore)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            alertMessage = "Failed to save scores: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func nextRound() {
        saveRound()
        currentRound += 1
        scores.removeAll()
        loadScores()
    }
    
    private func previousRound() {
        saveRound()
        currentRound -= 1
        scores.removeAll()
        loadScores()
    }
    
    private func finishCompetition() {
        saveRound()
        navigateToResults = true
    }
}

#Preview {
    let participant1 = Participant(firstName: "John", lastName: "Doe")
    let participant2 = Participant(firstName: "Jane", lastName: "Smith")
    let competition = Competition(name: "Test Competition", date: Date())
    competition.participants = [participant1, participant2]
    
    ScoringView(competition: competition, roundCount: 3, maxScore: 100)
        .modelContainer(for: Competition.self, inMemory: true)
}
