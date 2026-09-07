import Foundation
import SwiftData

@Model
final class Participant {
    var firstName: String
    var lastName: String
    var scores: [Score] = []
    var createdAt: Date
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = Date()
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var totalScore: Int {
        scores.reduce(0) { $0 + $1.points }
    }
    
    var averageScore: Double {
        guard !scores.isEmpty else { return 0 }
        return Double(totalScore) / Double(scores.count)
    }
}

@Model
final class Score {
    var points: Int
    var roundNumber: Int
    var timestamp: Date
    
    init(points: Int, roundNumber: Int) {
        self.points = points
        self.roundNumber = roundNumber
        self.timestamp = Date()
    }
}

@Model
final class Competition {
    var name: String
    var date: Date
    var participants: [Participant] = []
    var createdAt: Date
    
    init(name: String, date: Date) {
        self.name = name
        self.date = date
        self.createdAt = Date()
    }
    
    var sortedParticipants: [Participant] {
        participants.sorted { $0.totalScore > $1.totalScore }
    }
}
