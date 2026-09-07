import SwiftUI
import SwiftData

struct CompetitionSetupView: View {
    @Environment(\.modelContext) var modelContext
    @State private var competitionName = ""
    @State private var selectedDate = Date()
    @State private var roundCount = 3
    @State private var maxScore = 100
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToScoring = false
    @State private var competition: Competition?
    
    let participants: [Participant]
    
    var body: some View {
        VStack(spacing: 20) {
            // Competition Details
            VStack(spacing: 12) {
                TextField("Competition Name", text: $competitionName)
                    .textFieldStyle(.roundedBorder)
                
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Number of Rounds")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Stepper("\(roundCount)", value: $roundCount, in: 1...10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Max Score per Round")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Stepper("\(maxScore)", value: $maxScore, in: 10...500, step: 10)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Participants Summary
            VStack(alignment: .leading) {
                Text("Participants (\(participants.count))")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(participants, id: \.id) { participant in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text(participant.fullName)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // Start Button
            NavigationLink(destination: ScoringView(competition: competition ?? Competition(name: competitionName, date: selectedDate), roundCount: roundCount, maxScore: maxScore), isActive: $navigateToScoring) {
                Button(action: startCompetition) {
                    Text("Start Competition")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Competition Setup")
        .alert("Error", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func startCompetition() {
        let nameToUse = competitionName.trimmingCharacters(in: .whitespaces)
        guard !nameToUse.isEmpty else {
            alertMessage = "Please enter a competition name"
            showAlert = true
            return
        }
        
        let newCompetition = Competition(name: nameToUse, date: selectedDate)
        newCompetition.participants = participants
        
        modelContext.insert(newCompetition)
        
        do {
            try modelContext.save()
            competition = newCompetition
            navigateToScoring = true
        } catch {
            alertMessage = "Failed to start competition: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    let participant1 = Participant(firstName: "John", lastName: "Doe")
    let participant2 = Participant(firstName: "Jane", lastName: "Smith")
    
    CompetitionSetupView(participants: [participant1, participant2])
        .modelContainer(for: Competition.self, inMemory: true)
}
