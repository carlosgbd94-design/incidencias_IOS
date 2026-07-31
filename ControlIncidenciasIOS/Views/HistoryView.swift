import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: RecordViewModel
    @State private var searchQuery: String = ""
    @State private var selectedType: RecordType? = nil
    @State private var showMonthPicker: Bool = false
    @State private var editingRecord: RecordEntity? = nil

    private let monthNames = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    var filteredRecords: [RecordEntity] {
        viewModel.monthlyStats.records.filter { record in
            let matchesType = selectedType == nil || record.type == selectedType
            let matchesQuery = searchQuery.isEmpty ||
                record.observations.localizedCaseInsensitiveContains(searchQuery) ||
                record.type.displayName.localizedCaseInsensitiveContains(searchQuery)
            return matchesType && matchesQuery
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(GlassColors.samsungBlue)
                            TextField("Buscar en observaciones...", text: $searchQuery)
                                .font(.system(size: 14))
                            if !searchQuery.isEmpty {
                                Button(action: { searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)

                        Button(action: { showMonthPicker = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text("Mes")
                                    .bold()
                                    .font(.system(size: 13))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(GlassColors.samsungBlue.opacity(0.12))
                            .foregroundColor(GlassColors.samsungBlue)
                            .cornerRadius(20)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "Todos", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            FilterChip(label: "Pases", isSelected: selectedType == .paseSalida) {
                                selectedType = .paseSalida
                            }
                            FilterChip(label: "Vacaciones", isSelected: selectedType == .vacaciones) {
                                selectedType = .vacaciones
                            }
                            FilterChip(label: "Personales", isSelected: selectedType == .diaPersonal) {
                                selectedType = .diaPersonal
                            }
                            FilterChip(label: "Médicas", isSelected: selectedType == .incidenciaMedica) {
                                selectedType = .incidenciaMedica
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 12)

                if filteredRecords.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No hay incidencias registradas\npara este periodo.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            RecordCardRow(record: record) {
                                editingRecord = record
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteRecord(record)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Historial: \(monthNames[viewModel.filterMonth]) \(String(viewModel.filterYear))")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMonthPicker) {
                MonthPickerModal(viewModel: viewModel, isPresented: $showMonthPicker)
            }
            .sheet(item: $editingRecord) { record in
                AddEditRecordView(viewModel: viewModel, editingRecord: record)
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? GlassColors.samsungBlue : Color.secondary.opacity(0.12))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct RecordCardRow: View {
    let record: RecordEntity
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle()
                        .fill(record.type.tintColor)
                        .frame(width: 10, height: 10)

                    Text(record.type.displayName)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.primary)

                    Spacer()

                    Text(record.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("\(record.startTime) - \(record.endTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(record.durationFormatted)
                        .font(.caption)
                        .bold()
                        .foregroundColor(GlassColors.samsungBlue)
                }

                if !record.observations.isEmpty {
                    Text(record.observations)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

struct MonthPickerModal: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var isPresented: Bool

    @State private var tempMonth: Int = 0
    @State private var tempYear: Int = 2026

    private let monthNames = [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section("Año") {
                    Picker("Año", selection: $tempYear) {
                        ForEach(2024...2028, id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Mes") {
                    Picker("Mes", selection: $tempMonth) {
                        ForEach(0..<12, id: \.self) { m in
                            Text(monthNames[m]).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .navigationTitle("Seleccionar Mes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        viewModel.filterMonth = tempMonth
                        viewModel.filterYear = tempYear
                        isPresented = false
                    }
                    .bold()
                }
            }
            .onAppear {
                tempMonth = viewModel.filterMonth
                tempYear = viewModel.filterYear
            }
        }
    }
}
