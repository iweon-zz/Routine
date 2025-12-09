import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: RoutineViewModel
    
    var achievementRate: String {
        let maxGoal: Double = 1500.0
        let total = Double(viewModel.totalWeeklyFocusMinutes)
        
        if total == 0 { return "0%" }
        
        let percentage = min(total / maxGoal * 100, 100)
        return String(format: "%.0f%%", percentage)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                Text("나의 성장 기록").font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Label("주간 집중 시간", systemImage: "chart.bar.fill").font(.headline).padding(.bottom, 10)
                    
                    ZStack {
                        if viewModel.weeklyRecords.isEmpty {
                            Text("이번 주 집중 기록이 없습니다.")
                                .foregroundColor(.gray)
                        }
                        
                        Chart {
                            ForEach(viewModel.weeklyRecords) { record in
                                BarMark(x: .value("날짜", record.date, unit: .day), y: .value("분", record.focusMinutes))
                                    .foregroundStyle(Color.mint.gradient)
                            }
                        }
                        .opacity(viewModel.weeklyRecords.isEmpty ? 0 : 1)
                    }
                    .frame(height: 200).environment(\.locale, Locale(identifier: "ko_KR"))
                }
                .padding().background(Color.gray.opacity(0.1)).cornerRadius(15).padding(.horizontal)
                
                HStack(spacing: 15) {
                    StatCard(
                        title: "오늘 집중",
                        value: viewModel.formatMinutes(viewModel.todayFocusMinutes),
                        icon: "clock"
                    )
                    StatCard(
                        title: "달성률",
                        value: achievementRate,
                        icon: "target"
                    )
                }.padding(.horizontal)
                
                Spacer()
            }.padding(.top)
        }
    }
}

struct StatCard: View {
    let title: String; let value: String; let icon: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon).foregroundColor(.mint)
                Spacer()
            }
            Spacer()
            Text(value).font(.title2).fontWeight(.bold)
            Text(title).font(.caption).foregroundColor(.gray)
        }
        .padding()
        .frame(height: 100).frame(maxWidth: .infinity).background(Color.gray.opacity(0.15)).cornerRadius(15)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAuth = AuthManager()
        let dummyVM = RoutineViewModel(authManager: dummyAuth)
        
        dummyVM.weeklyRecords = [
             StudyRecord(focusMinutes: 120, date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, username: "테스트유저"),
           ]
        
        return StatsView(viewModel: dummyVM)
    }
}
