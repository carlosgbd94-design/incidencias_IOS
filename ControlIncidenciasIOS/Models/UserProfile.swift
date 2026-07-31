import Foundation

struct UserProfile: Identifiable, Codable, Equatable {
    var id: String = "default_user_profile"
    var name: String = "Empleado"
    var workStartTime: String = "09:00"
    var workEndTime: String = "14:30"
    var monthlyLimitMinutes: Int = 360
    var isActive: Bool = true
}
