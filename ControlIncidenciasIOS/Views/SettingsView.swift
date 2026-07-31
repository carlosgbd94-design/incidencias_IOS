import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: RecordViewModel
    @ObservedObject var themeManager: ThemeManager

    @State private var name: String = ""
    @State private var workStart: Date = Date()
    @State private var workEnd: Date = Date()
    @State private var limitHours: Int = 6

    @FocusState private var isNameFocused: Bool
    @State private var hasSavedAlert: Bool = false

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

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
                        TextField("Ingresa tu nombre...", text: $name)
                            .multilineTextAlignment(.trailing)
                            .bold()
                            .focused($isNameFocused)
                            .onTapGesture {
                                if name == "Empleado" {
                                    name = ""
                                }
                            }
                    }
                }

                Section("Horario Laboral y Límite Mensual") {
                    DatePicker("Hora de Entrada", selection: $workStart, displayedComponents: .hourAndMinute)
                    DatePicker("Hora de Salida", selection: $workEnd, displayedComponents: .hourAndMinute)

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
            .onTapGesture {
                hideKeyboard()
            }
            .alert("Ajustes Guardados", isPresented: $hasSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Tus cambios de horario y perfil se han actualizado correctamente.")
            }
            .onAppear {
                name = viewModel.activeProfile.name
                limitHours = viewModel.activeProfile.monthlyLimitMinutes / 60

                let calendar = Calendar.current
                let today = Date()

                let startParts = viewModel.activeProfile.workStartTime.split(separator: ":").compactMap { Int($0) }
                if startParts.count == 2, let d = calendar.date(bySettingHour: startParts[0], minute: startParts[1], second: 0, of: today) {
                    workStart = d
                }

                let endParts = viewModel.activeProfile.workEndTime.split(separator: ":").compactMap { Int($0) }
                if endParts.count == 2, let d = calendar.date(bySettingHour: endParts[0], minute: endParts[1], second: 0, of: today) {
                    workEnd = d
                }
            }
        }
    }

    private func saveSettings() {
        hideKeyboard()

        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Empleado" : name
        let startStr = timeFormatter.string(from: workStart)
        let endStr = timeFormatter.string(from: workEnd)

        viewModel.updateProfileName(finalName)
        viewModel.updateProfile(workStart: startStr, workEnd: endStr, limitMins: limitHours * 60)

        hasSavedAlert = true
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
