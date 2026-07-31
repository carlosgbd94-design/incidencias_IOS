import Foundation
import Combine
import SwiftUI

struct MonthlyStats {
    var totalMinutesUsed: Int = 0
    var limitMinutes: Int = 360
    var minutesRemaining: Int {
        max(0, limitMinutes - totalMinutesUsed)
    }
    var isOverLimit: Bool {
        totalMinutesUsed > limitMinutes
    }
    var records: [RecordEntity] = []
}

class RecordViewModel: ObservableObject {
    @Published var records: [RecordEntity] = []
    @Published var activeProfile: UserProfile = UserProfile()
    @Published var filterMonth: Int = Calendar.current.component(.month, from: Date()) - 1
    @Published var filterYear: Int = Calendar.current.component(.year, from: Date())

    private let recordsStorageKey = "saved_records_ios"
    private let profileStorageKey = "saved_profile_ios"

    init() {
        loadData()
        if records.isEmpty {
            seedSampleData()
        }
    }

    func loadData() {
        if let profileData = UserDefaults.standard.data(forKey: profileStorageKey),
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            self.activeProfile = decodedProfile
        }

        if let recordsData = UserDefaults.standard.data(forKey: recordsStorageKey),
           let decodedRecords = try? JSONDecoder().decode([RecordEntity].self, from: recordsData) {
            self.records = decodedRecords
        }
    }

    func saveData() {
        if let encodedProfile = try? JSONEncoder().encode(activeProfile) {
            UserDefaults.standard.set(encodedProfile, forKey: profileStorageKey)
        }
        if let encodedRecords = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encodedRecords, forKey: recordsStorageKey)
        }
    }

    var monthlyStats: MonthlyStats {
        let calendar = Calendar.current
        let monthRecords = records.filter { record in
            let date = record.date
            let m = calendar.component(.month, from: date) - 1
            let y = calendar.component(.year, from: date)
            return m == filterMonth && y == filterYear
        }

        let used = monthRecords
            .filter { $0.type == .paseSalida }
            .reduce(0) { $0 + $1.durationMinutesCalculated }

        return MonthlyStats(
            totalMinutesUsed: used,
            limitMinutes: activeProfile.monthlyLimitMinutes,
            records: monthRecords.sorted(by: { $0.dateTimestamp > $1.dateTimestamp })
        )
    }

    func addOrUpdateRecord(_ record: RecordEntity) {
        if let idx = records.firstIndex(where: { $0.id == record.id }) {
            records[idx] = record
        } else {
            records.insert(record, at: 0)
        }
        saveData()
    }

    func deleteRecord(_ record: RecordEntity) {
        records.removeAll(where: { $0.id == record.id })
        saveData()
    }

    func updateProfileName(_ newName: String) {
        activeProfile.name = newName
        saveData()
    }

    func updateProfile(workStart: String, workEnd: String, limitMins: Int) {
        activeProfile.workStartTime = workStart
        activeProfile.workEndTime = workEnd
        activeProfile.monthlyLimitMinutes = limitMins
        saveData()
    }

    func calculateDuration(startTime: String, endTime: String, returns: Bool, workEnd: String) -> Int {
        let startMins = timeStringToMinutes(startTime)
        if returns {
            let endMins = timeStringToMinutes(endTime)
            return max(0, endMins - startMins)
        } else {
            let workEndMins = timeStringToMinutes(workEnd)
            return max(0, workEndMins - startMins)
        }
    }

    private func timeStringToMinutes(_ timeStr: String) -> Int {
        let parts = timeStr.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }

    private func seedSampleData() {
        let now = Date().timeIntervalSince1970
        let day: Double = 86400

        let sample1 = RecordEntity(
            dateTimestamp: now,
            endDateTimestamp: now,
            type: .paseSalida,
            startTime: "13:55",
            endTime: "14:30",
            returns: false,
            durationMinutesCalculated: 35,
            priority: .media,
            observations: "Me quise ir temprano",
            profileId: activeProfile.id
        )

        let sample2 = RecordEntity(
            dateTimestamp: now - (6 * day),
            endDateTimestamp: now - (6 * day),
            type: .paseSalida,
            startTime: "14:01",
            endTime: "14:30",
            returns: false,
            durationMinutesCalculated: 29,
            priority: .baja,
            observations: "Me quise ir temprano",
            profileId: activeProfile.id
        )

        let sample3 = RecordEntity(
            dateTimestamp: now - (13 * day),
            endDateTimestamp: now - (13 * day),
            type: .paseSalida,
            startTime: "14:02",
            endTime: "14:30",
            returns: false,
            durationMinutesCalculated: 28,
            priority: .baja,
            observations: "Me salí temprano con Les y Liz",
            profileId: activeProfile.id
        )

        self.records = [sample1, sample2, sample3]
        saveData()
    }
}
