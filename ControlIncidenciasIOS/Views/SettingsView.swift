import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @State private var name: String = ""
    @State private var workStart: String = "09:00"
    @State private var workEnd: String = "14:30"
    @State private var limitHours: Int = 6

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ajustes")
                    .font(.system(size: 32, weight: .bold))
                Text("Configuración de Perfil y Horarios")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 12)

            Form {
                Section("Información de Empleado") {
                    HStack {
                        Text("Nombre:")
                        Spacer()
                        TextField("Nombre", text: $name)
                            .multilineTextAlignment(.trailing)
                            .bold()
                    }
                }

                Section("Horario Laboral y Límite Mensual") {
                    HStack {
                        Text("Hora de Entrada")
                        Spacer()
                        TextField("09:00", text: $workStart)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numbersAndPunctuation)
                    }

                    HStack {
                        Text("Hora de Salida")
                        Spacer()
                        TextField("14:30", text: $workEnd)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numbersAndPunctuation)
                    }

                    Stepper("Límite de Pases: \(limitHours) horas/mes", value: $limitHours, in: 1...20)
                }

                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            Text("Guardar Cambios")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(GlassColors.samsungBlue)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            name = viewModel.activeProfile.name
            workStart = viewModel.activeProfile.workStartTime
            workEnd = viewModel.activeProfile.workEndTime
            limitHours = viewModel.activeProfile.monthlyLimitMinutes / 60
        }
    }

    private func saveSettings() {
        viewModel.updateProfileName(name)
        viewModel.updateProfile(workStart: workStart, workEnd: workEnd, limitMins: limitHours * 60)
    }
}
