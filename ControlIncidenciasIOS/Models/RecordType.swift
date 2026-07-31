import Foundation
import SwiftUI

enum RecordType: String, Codable, CaseIterable, Identifiable {
    case paseSalida = "PASE_SALIDA"
    case vacaciones = "VACACIONES"
    case diaPersonal = "DIA_PERSONAL"
    case incidenciaMedica = "INCIDENCIA_MEDICA"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .paseSalida: return "Pase de Salida"
        case .vacaciones: return "Vacaciones"
        case .diaPersonal: return "Día Personal"
        case .incidenciaMedica: return "Incidencia Médica"
        }
    }

    var iconName: String {
        switch self {
        case .paseSalida: return "clock.fill"
        case .vacaciones: return "airplane"
        case .diaPersonal: return "calendar.badge.clock"
        case .incidenciaMedica: return "cross.case.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .paseSalida: return Color(red: 10/255, green: 89/255, blue: 234/255)
        case .vacaciones: return Color(red: 16/255, green: 185/255, blue: 129/255)
        case .diaPersonal: return Color(red: 245/255, green: 158/255, blue: 11/255)
        case .incidenciaMedica: return Color(red: 239/255, green: 68/255, blue: 68/255)
        }
    }
}
