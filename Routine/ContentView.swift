import SwiftUI

struct ContentView: View {
    // RootView에서 AuthManager 전달받음
    @ObservedObject var authManager: AuthManager
    
    // 전달받은 AuthManager을 사용해 ViewModel을 초기화
    @StateObject var viewModel: RoutineViewModel
    
    // 로그아웃 하기 위해 AuthManager 환경 객체를 참조
    @EnvironmentObject var globalAuthManager: AuthManager
    @AppStorage("isDarkMode") private var isDarkMode = true

    // 이니셜라이저 (UIAppearance 코드를 클로저로 묶음)
    init(authManager: AuthManager) {
        self._authManager = ObservedObject(wrappedValue: authManager)
        self._viewModel = StateObject(wrappedValue: RoutineViewModel(authManager: authManager))
        
        // TabBar 배경색 설정 (뷰 빌더 오류 방지를 위해 클로저로 묶어 실행)
        _ = {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 닉네임 표시
            if let username = authManager.currentUsername {
                HStack {
                    Text("\(username)님 오늘도 화이팅!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            // TabView 로직
            TabView {
                TodoView(viewModel: viewModel)
                    .tabItem { Image(systemName: "checklist"); Text("할 일") }
                
                TimerView(viewModel: viewModel)
                    .tabItem { Image(systemName: "timer"); Text("집중") }
                
                StatsView(viewModel: viewModel)
                  
                    .tabItem { Image(systemName: "chart.bar.fill"); Text("통계") }
                
                VStack {    // 설정 뷰
                    Form {
                        Section(header: Text("앱 설정")) {
                            Toggle("다크 모드 활성화", isOn: $isDarkMode)
                        }
                        Section {
                            Button("로그아웃") {
                                // globalAuthManager를 통해 로그아웃 호출
                                globalAuthManager.logout()
                            }.foregroundColor(.red)
                        }
                    }
                }
                .tabItem { Image(systemName: "gearshape"); Text("설정") }
            }
            .accentColor(.mint)
        } // End VStack
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAuth = AuthManager()
        dummyAuth.currentUsername = "테스트유저"
        
        return ContentView(authManager: dummyAuth)
            .environmentObject(dummyAuth)
    }
}
