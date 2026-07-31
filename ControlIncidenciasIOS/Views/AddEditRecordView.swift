import SwiftUI

struct AddEditRecordView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RecordViewModel
    var editingRecord: RecordEntity? = nil

    @State private var selectedType: RecordType = .paseSalida
    @State private var recordDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var returns: Bool = false
    @State private var observations: String = ""

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var calculatedMinutes: Int {
        if selectedType != .paseSalida { return 0 }
        let startStr = timeFormatter.string(from: startTime)
        let endStr = timeFormatter.string(from: endTime)
        return viewModel.calculateDuration(
            startTime: startStr,
            endTime: endStr,
            returns: returns,
            workEnd: viewModel.activeProfile.workEndTime
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Tipo de Incidencia") {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(RecordType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Fecha y Tiempos") {
                    DatePicker("Fecha", selection: $recordDate, displayedComponents: .date)

                    if selectedType == .vacaciones {
                        DatePicker("Fecha Fin", selection: $endDate, displayedComponents: .date)
                    }

                    if selectedType == .paseSalida {
                        DatePicker("Hora de Salida", selection: $startTime, displayedComponents: .hourAndMinute)

                        Toggle("¿Regresa a trabajar?", isOn: $returns)

                        if returns {
                            DatePicker("Hora de Regreso", selection: $endTime, displayedComponents: .hourAndMinute)
                        }

                        HStack {
                            Text("Duración Calculada:")
                                .font(.subheadline)
                            Spacer()
                            let h = calculatedMinutes / 60
                            let m = calculatedMinutes % 60
                            Text("\(h)h \(m)m (\(calculatedMinutes) min)")
                                .bold()
                                .foregroundColor(GlassColors.samsungBlue)
                        }
                    }
                }

                Section("Observaciones") {
                    TextField("Escribe una breve descripción...", text: $observations)
                }
            }
            .navigationTitle(editingRecord == nil ? "Nueva Incidencia" : "Editar Incidencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveRecord()
                    }
                    .bold()
                }
            }
            .onAppear {
                if let record = editingRecord {
                    selectedType = record.type
                    recordDate = record.date
                    endDate = record.endDate
                    observations = record.observations
                    returns = record.returns

                    let today = Date()
                    let calendar = Calendar.current
                    if let startD = calendar.date(bySettingHour: hourOf(record.startTime), minute: minuteOf(record.startTime), second: 0, of: today) {
                        startTime = startD
                    }
                    if let endD = calendar.date(bySettingHour: hourOf(record.endTime), minute: minuteOf(record.endTime), second: 0, of: today) {
                        endTime = endD
                    }
                }
            }
        }
    }

    private func saveRecord() {
        let startStr = timeFormatter.string(from: startTime)
        let endStr = timeFormatter.string(from: endTime)

        var record = editingRecord ?? RecordEntity(
            dateTimestamp: recordDate.timeIntervalSince1970,
            endDateTimestamp: endDate.timeIntervalSince1970,
            type: selectedType,
            startTime: startStr,
            endTime: returns ? endStr : viewModel.activeProfile.workEndTime,
            returns: returns,
            durationMinutesCalculated: calculatedMinutes,
            observations: observations,
            profileId: viewModel.activeProfile.id
        )

        record.dateTimestamp = recordDate.timeIntervalSince1970
        record.endDateTimestamp = endDate.timeIntervalSince1970
        record.type = selectedType
        record.startTime = startStr
        record.endTime = returns ? endStr : viewModel.activeProfile.workEndTime
        record.returns = returns
        record.durationMinutesCalculated = calculatedMinutes
        record.observations = observations

        viewModel.addOrUpdateRecord(record)
        dismiss()
    }

    private func hourOf(_ timeStr: String) -> Int {
        Int(timeStr.prefix(2)) ?? 9
    }

    private func minuteOf(_ timeStr: String) -> Int {
        Int(timeStr.suffix(2)) ?? 0
    }
}
