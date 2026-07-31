import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @ObservedObject var themeManager: ThemeManager

    @State private var name: String = ""
    @State private var workStart: String = "09:00"
    @State private var workEnd: String = "14:30"
    @State private var limitHours: Int = 6

    var body: some View {
        NavigationView {
            Form {
                Section("Tema de la Aplicación") {
                    Picker("Apariencia", selection: $themeManager.currentTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

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
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = viewModel.activeProfile.name
                workStart = viewModel.activeProfile.workStartTime
                workEnd = viewModel.activeProfile.workEndTime
                limitHours = viewModel.activeProfile.monthlyLimitMinutes / 60
            }
        }
    }

    private func saveSettings() {
        viewModel.updateProfileName(name)
        viewModel.updateProfile(workStart: workStart, workEnd: workEnd, limitMins: limitHours * 60)
    }
}
