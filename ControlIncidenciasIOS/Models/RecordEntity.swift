import Foundation

struct RecordEntity: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var dateTimestamp: Double
    var endDateTimestamp: Double
    var type: RecordType
    var startTime: String
    var endTime: String
    var returns: Bool
    var durationMinutesCalculated: Int
    var priority: PrioritySeverity
    var observations: String
    var profileId: String

    var date: Date {
        Date(timeIntervalSince1970: dateTimestamp)
    }

    var endDate: Date {
        Date(timeIntervalSince1970: endDateTimestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }

    var durationFormatted: String {
        if type == .paseSalida {
            let h = durationMinutesCalculated / 60
            let m = durationMinutesCalculated % 60
            if h > 0 && m > 0 {
                return "\(h)h \(m)m"
            } else if h > 0 {
                return "\(h)h"
            } else {
                return "\(m)m"
            }
        } else if type == .vacaciones {
            let calendar = Calendar.current
            let startDay = calendar.startOfDay(for: date)
            let endDay = calendar.startOfDay(for: endDate)
            let components = calendar.dateComponents([.day], from: startDay, to: endDay)
            let days = (components.day ?? 0) + 1
            return "\(days) \(days == 1 ? "día" : "días")"
        } else {
            return "1 día"
        }
    }
}
