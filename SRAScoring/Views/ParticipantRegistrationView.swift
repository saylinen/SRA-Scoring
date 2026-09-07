import SwiftUI
import SwiftData

struct ParticipantRegistrationView: View {
    @Environment(\.modelContext) var modelContext
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var participants: [Participant] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Input Section
                VStack(spacing: 12) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.givenName)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.familyName)
                    
                    Button(action: addParticipant) {
                        Text("Add Participant")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(firstName.trimmingCharacters(in: .whitespaces).isEmpty || 
                              lastName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Participants List
                VStack(alignment: .leading) {
                    Text("Registered Participants (\(participants.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if participants.isEmpty {
                        Text("No participants yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(participants, id: \.id) { participant in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(participant.fullName)
                                            .font(.body)
                                        Text("Added: \(participant.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button(action: { removeParticipant(participant) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                
                Spacer()
                
                // Start Competition Button
                if !participants.isEmpty {
                    NavigationLink(destination: CompetitionSetupView(participants: participants)) {
                        Text("Start Competition")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("Register Participants")
            .onAppear(perform: loadParticipants)
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addParticipant() {
        let firstNameTrimmed = firstName.trimmingCharacters(in: .whitespaces)
        let lastNameTrimmed = lastName.trimmingCharacters(in: .whitespaces)
        
        guard !firstNameTrimmed.isEmpty, !lastNameTrimmed.isEmpty else {
            alertMessage = "Please enter both first and last name"
            showAlert = true
            return
        }
        
        let newParticipant = Participant(firstName: firstNameTrimmed, lastName: lastNameTrimmed)
        modelContext.insert(newParticipant)
        
        do {
            try modelContext.save()
            participants.append(newParticipant)
            firstName = ""
            lastName = ""
        } catch {
            alertMessage = "Failed to save participant: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func removeParticipant(_ participant: Participant) {
        modelContext.delete(participant)
        participants.removeAll { $0.id == participant.id }
        
        do {
            try modelContext.save()
        } catch {
            alertMessage = "Failed to remove participant: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func loadParticipants() {
        let descriptor = FetchDescriptor<Participant>()
        do {
            participants = try modelContext.fetch(descriptor)
        } catch {
            alertMessage = "Failed to load participants: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

#Preview {
    ParticipantRegistrationView()
        .modelContainer(for: Participant.self, inMemory: true)
}
