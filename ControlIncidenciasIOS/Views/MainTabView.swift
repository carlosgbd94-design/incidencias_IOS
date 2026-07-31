import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = RecordViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab: Int = 0
    @State private var showAddSheet: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: viewModel, showAddRecordSheet: $showAddSheet)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Inicio")
                    }
                    .tag(0)

                HistoryView(viewModel: viewModel)
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Historial")
                    }
                    .tag(1)

                SettingsView(viewModel: viewModel, themeManager: themeManager)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Ajustes")
                    }
                    .tag(2)
            }
            .preferredColorScheme(themeManager.currentTheme.colorScheme)

            HStack {
                Spacer()
                Button(action: { showAddSheet = true }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        GlassColors.samsungBlue.opacity(0.85),
                                        Color.blue.opacity(0.65)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )

                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60, height: 60)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditRecordView(viewModel: viewModel)
        }
    }
}
