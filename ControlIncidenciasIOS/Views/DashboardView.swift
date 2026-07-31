import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: RecordViewModel
    @Binding var showAddRecordSheet: Bool

    var body: some View {
        let stats = viewModel.monthlyStats
        let remainingHrs = stats.minutesRemaining / 60
        let remainingMns = stats.minutesRemaining % 60
        let usedHrs = stats.totalMinutesUsed / 60
        let usedMns = stats.totalMinutesUsed % 60
        let limitHrs = stats.limitMinutes / 60

        let progress: Double = stats.limitMinutes > 0 ?
            min(1.0, max(0.0, Double(stats.minutesRemaining) / Double(stats.limitMinutes))) : 0.0

        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Horas Disponibles")
                                .font(.headline)
                                .bold()
                            Spacer()
                            Text("Activo")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(GlassColors.successGreen.opacity(0.15))
                                .foregroundColor(GlassColors.successGreen)
                                .cornerRadius(10)
                        }

                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                                .frame(width: 170, height: 170)

                            Circle()
                                .trim(from: 0, to: CGFloat(progress))
                                .stroke(
                                    LinearGradient(
                                        colors: stats.isOverLimit ? [GlassColors.alertRed, Color.red] :
                                            (stats.minutesRemaining <= 60 ? [GlassColors.warningOrange, Color.orange] : [GlassColors.successGreen, GlassColors.samsungBlue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 170, height: 170)
                                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)

                            VStack(spacing: 2) {
                                Text("DISPONIBLES")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(stats.isOverLimit ? GlassColors.alertRed : GlassColors.successGreen)
                                    .tracking(0.8)

                                Text("\(remainingHrs)h \(remainingMns)m")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(stats.isOverLimit ? GlassColors.alertRed : .primary)

                                Text("de \(limitHrs)h mes")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Divider().opacity(0.3)

                        HStack {
                            VStack(spacing: 4) {
                                Text("Horas Usadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(usedHrs)h \(usedMns)m")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(GlassColors.samsungBlue)
                            }
                            .frame(maxWidth: .infinity)

                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 1, height: 30)

                            VStack(spacing: 4) {
                                Text("Horario Laboral")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.activeProfile.workStartTime) - \(viewModel.activeProfile.workEndTime)")
                                    .font(.headline)
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(20)
                    .glassCard()

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Resumen Anual (\(Calendar.current.component(.year, from: Date())))")
                            .font(.headline)
                            .bold()

                        HStack(spacing: 12) {
                            Image(systemName: "airplane")
                                .foregroundColor(GlassColors.successGreen)
                                .frame(width: 36, height: 36)
                                .background(GlassColors.successGreen.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("Vacaciones")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(vacationDaysCount) días")
                                    .font(.subheadline)
                                    .bold()
                            }
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(GlassColors.warningOrange)
                                .frame(width: 36, height: 36)
                                .background(GlassColors.warningOrange.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("Días Personales")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(personalDaysCount) días")
                                    .font(.subheadline)
                                    .bold()
                            }
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(GlassColors.alertRed)
                                .frame(width: 36, height: 36)
                                .background(GlassColors.alertRed.opacity(0.15))
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("Médicas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(medicalCount) incidencias")
                                    .font(.subheadline)
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .padding(20)
                    .glassCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 100)
            }
            .navigationTitle("Inicio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var vacationDaysCount: Int {
        let year = Calendar.current.component(.year, from: Date())
        return viewModel.records
            .filter { $0.type == .vacaciones && Calendar.current.component(.year, from: $0.date) == year }
            .count
    }

    private var personalDaysCount: Int {
        let year = Calendar.current.component(.year, from: Date())
        return viewModel.records
            .filter { $0.type == .diaPersonal && Calendar.current.component(.year, from: $0.date) == year }
            .count
    }

    private var medicalCount: Int {
        let year = Calendar.current.component(.year, from: Date())
        return viewModel.records
            .filter { $0.type == .incidenciaMedica && Calendar.current.component(.year, from: $0.date) == year }
            .count
    }
}
