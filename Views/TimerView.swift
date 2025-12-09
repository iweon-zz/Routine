import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: RoutineViewModel
    
    var progress: Double {
        guard viewModel.totalTime > 0 else { return 0 }
        // 🚨 수정된 로직: 남은 시간이 아닌, 경과 시간을 기준으로 프로그레스 바를 채웁니다.
        let elapsedTime = viewModel.totalTime - viewModel.timeRemaining
        return elapsedTime / viewModel.totalTime
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text(viewModel.timerMode.title).font(.headline).padding(.top, 50).foregroundColor(.gray)
            
            ZStack {
                Circle().stroke(lineWidth: 20).opacity(0.3).foregroundColor(viewModel.timerMode.color)
                
                Circle().trim(from: 0.0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(viewModel.timerMode.color)
                    .rotationEffect(Angle(degrees: 270.0)).animation(.linear, value: progress)
                    
                VStack(spacing: 10) {
                    Text(formatTime(viewModel.timeRemaining)).font(.system(size: 60, weight: .bold, design: .rounded))
                    Text(viewModel.isTimerRunning ? "집중 중..." : "터치하여 시작").font(.caption).foregroundColor(.gray)
                }
            }
            .padding(40)
            // 탭 제스처
            .onTapGesture {
                if viewModel.isTimerRunning { viewModel.stopTimer() } else { viewModel.startTimer() }
            }
            
            HStack(spacing: 20) {
                Button(action: { viewModel.resetTimer() }) {
                    VStack { Image(systemName: "arrow.counterclockwise"); Text("초기화").font(.caption) }
                        .foregroundColor(.primary).padding().background(Color.gray.opacity(0.3)).cornerRadius(15)
                }
                // 플레이/정지 버튼
                Button(action: { if viewModel.isTimerRunning { viewModel.stopTimer() } else { viewModel.startTimer() } }) {
                    Image(systemName: viewModel.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.largeTitle).foregroundColor(.white).padding(30)
                        .background(viewModel.timerMode.color).clipShape(Circle()).shadow(radius: 10)
                }
                Button(action: { viewModel.switchMode(); viewModel.stopTimer() }) {
                    VStack { Image(systemName: "arrow.triangle.2.circlepath"); Text("전환").font(.caption) }
                        .foregroundColor(.primary).padding().background(Color.gray.opacity(0.3)).cornerRadius(15)
                }
            }
            Spacer()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAuth = AuthManager()
        let dummyVM = RoutineViewModel(authManager: dummyAuth)
        TimerView(viewModel: dummyVM)
            .environmentObject(dummyAuth)
    }
}
