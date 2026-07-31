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
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [GlassColors.samsungBlue, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: GlassColors.samsungBlue.opacity(0.4), radius: 10, x: 0, y: 5)
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
