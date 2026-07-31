import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = RecordViewModel()
    @State private var selectedTab: Int = 0
    @State private var showAddSheet: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: viewModel, showAddRecordSheet: $showAddSheet)
                    .tag(0)

                HistoryView(viewModel: viewModel)
                    .tag(1)

                SettingsView(viewModel: viewModel)
                    .tag(2)
            }

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
                .padding(.bottom, 75)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEditRecordView(viewModel: viewModel)
        }
    }
}
