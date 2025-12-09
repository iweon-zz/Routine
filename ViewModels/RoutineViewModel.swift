import Foundation
import Combine
import SwiftUI


enum TimerMode: Sendable {
    case focus, rest
    var title: String { self == .focus ? "집중 시간" : "휴식 시간" }
    var color: Color { return self == .focus ? .mint : .orange }
    var duration: TimeInterval { self == .focus ? 25 * 60 : 5 * 60 }
}

class RoutineViewModel: ObservableObject {
    private var authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    
    // 시뮬레이터용 localhost 주소
    private let baseURL = "http://localhost:3000/api"

    // Timer & State Properties
    @Published var totalTime: TimeInterval = TimerMode.focus.duration
    @Published var timeRemaining: TimeInterval = TimerMode.focus.duration
    @Published var isTimerRunning: Bool = false
    @Published var timerMode: TimerMode = .focus
    private var timer: Timer?

    // Data Properties
    @Published var totalWeeklyFocusMinutes: Int = 0
    @Published var todayFocusMinutes: Int = 0
    @Published var weeklyRecords: [StudyRecord] = []
    @Published var tasks: [TaskItem] = []
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        // 사용자 ID 변경을 감지하여 모든 데이터 로딩 함수를 호출
        authManager.$currentUserId
            .sink { [weak self] userId in
                self?.loadAllData(for: userId)
            }
            .store(in: &cancellables)
    }
    
    // 사용자 ID를 기반으로 할 일과 통계 데이터를 모두 서버에서 불러오기
    func loadAllData(for userId: String?) {
        guard let userId = userId else {
            // 로그아웃 상태일 때 데이터 초기화
            self.totalWeeklyFocusMinutes = 0
            self.todayFocusMinutes = 0
            self.weeklyRecords = []
            self.tasks = []
            return
        }
        
        // 로그인 상태일 때 데이터 로딩 시작
        fetchTasks(for: userId)
        fetchStudyRecords(for: userId)
    }

    // [UTILITY] 데이터 포맷 및 계산

    // 분 단위를 "X시간 Y분" 형식의 문자열로 변환
    func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 { return "\(hours)시간 \(remainingMinutes)분" }
        return "\(remainingMinutes)분"
    }

    // [TIMER CORE] 타이머 작동 로직

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            Task { @MainActor in
                if strongSelf.timeRemaining > 0 {
                    strongSelf.timeRemaining -= 1
                } else {
                    // 타이머 완료 시 (집중 시간이든 휴식 시간이든)
                    strongSelf.stopTimer() // stopTimer가 기록을 처리합니다.
                    strongSelf.switchMode()
                    strongSelf.startTimer()
                }
            }
        }
    }
    
    // 집중 시간 기록 로직이 추가된 함수
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        // 타이머가 '집중 시간' 모드였고 실행 중이었다면 집중 시간 기록
        if isTimerRunning && timerMode == .focus {
            // 경과 시간 = 전체 시간 - 남은 시간
            let elapsedTime = totalTime - timeRemaining
            // 분 단위로 변환 (60으로 나눈 정수 몫)
            let focusedMinutes = Int(elapsedTime / 60)
            
            // 1분 이상 집중했을 경우에만 기록 저장
            if focusedMinutes >= 1 {
                self.saveStudyRecord(minutes: focusedMinutes)
            } else {
                print("1분 미만 집중으로 기록 저장 스킵")
            }
        }
        
        isTimerRunning = false
    }
    
    func resetTimer() {
        // stopTimer()를 호출하여 현재 집중 시간이 있다면 기록하고 타이머를 멈춥니다.
        stopTimer()
        timeRemaining = timerMode.duration
        totalTime = timerMode.duration
    }
    
    func switchMode() {
        timerMode = timerMode == .focus ? .rest : .focus
        resetTimer()
    }
    
    // [TASK] 할 일 CRUD

    // 서버에서 사용자의 할 일 목록 부르기
    private func fetchTasks(for userId: String) {
        guard let url = URL(string: "\(baseURL)/tasks?username=\(userId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { return }
                
                do {
                    let decoder = JSONDecoder()
                    // [주의] TaskItem의 커스텀 디코딩이 서버의 날짜 형식을 처리합니다.
                    let tasks = try decoder.decode([TaskItem].self, from: data)
                    self.tasks = tasks
                    print("할 일 로드 성공: \(tasks.count)개")
                } catch {
                    print("할 일 디코딩 실패: \(error)")
                }
            }
        }.resume()
    }
    
    // 새로운 할 일 서버에 저장
    func addTask(title: String, date: Date) {
        guard let userId = authManager.currentUserId else { return }
        guard let url = URL(string: "\(baseURL)/tasks") else { return }
        
        let newId = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: date) + " 12:00:00"
        
        let body: [String: Any] = [
            "id": newId,
            "title": title,
            "isCompleted": false,
            "date": dateString,
            "subject": "기타",
            "username": userId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    print("할 일 추가 성공: \(dateString)")
                    self.fetchTasks(for: userId) // 목록 새로고침
                } else {
                    print("할 일 추가 실패")
                }
            }
        }.resume()
    }

    // 할 일 완료 상태를 서버에 업데이트
    func toggleTask(task: TaskItem) {
        guard let url = URL(string: "\(baseURL)/tasks/\(task.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 로컬 UI를 먼저 업데이트하여 반응성을 높임 (낙관적 업데이트)
        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
            self.tasks[index].isCompleted.toggle()
        }
        
        let body: [String: Any] = ["isCompleted": !task.isCompleted]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request).resume()
    }

    // 서버에서 할 일 삭제
    func deleteTask(task: TaskItem) {
        guard let url = URL(string: "\(baseURL)/tasks/\(task.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.tasks.removeAll(where: { $0.id == task.id })
                    print("할 일 삭제 성공")
                }
            }
        }.resume()
    }
    
    // [STATS] 통계 기록 로직

    // 서버에서 사용자의 주간 집중 기록을 불러오기
    private func fetchStudyRecords(for userId: String) {
        guard let url = URL(string: "\(baseURL)/study_records?username=\(userId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("통계 데이터 수신 오류:", error?.localizedDescription ?? "알 수 없는 오류")
                    return
                }
                
                do {
                    // JSONSerialization을 사용해 수동 파싱
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd" // 서버가 보내는 YYYY-MM-DD 형식과 일치해야 함
                        
                        // JSON 데이터를 StudyRecord 구조체 배열로 변환
                        self.weeklyRecords = jsonArray.compactMap { dict in
                            
                            // 1. 날짜(date) 필드 파싱
                            guard let dateString = dict["date"] as? String else {
                                print("파싱 오류: date 필드 누락/형식 불일치")
                                return nil
                            }
                            
                            // 2. 집중 시간(focusMinutes) 필드 파싱 (Int 또는 String 변환 시도)
                            var focusMinutes: Int?
                            if let intMinutes = dict["focusMinutes"] as? Int {
                                focusMinutes = intMinutes
                            } else if let stringMinutes = dict["focusMinutes"] as? String,
                                      let intMinutes = Int(stringMinutes) {
                                focusMinutes = intMinutes
                            }
                            
                            guard let finalMinutes = focusMinutes else {
                                print("파싱 오류: focusMinutes 필드 누락/형식 불일치 (Int/String 모두 실패) - 응답:", dict["focusMinutes"] ?? "nil")
                                return nil
                            }
                            
                            // 3. Date 객체 생성
                            guard let date = formatter.date(from: dateString) else {
                                print("파싱 오류: 날짜 형식 (yyyy-MM-dd) 불일치로 date 객체 생성 실패 - 서버 응답:", dateString)
                                return nil
                            }
                            
                            return StudyRecord(focusMinutes: finalMinutes, date: date, username: userId)
                        }
                        
                        // 데이터 로드 후 통계 값 재계산
                        self.totalWeeklyFocusMinutes = self.weeklyRecords.reduce(0) { $0 + $1.focusMinutes }
                        let today = Calendar.current.startOfDay(for: Date())
                        self.todayFocusMinutes = self.weeklyRecords
                            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                            .reduce(0) { $0 + $1.focusMinutes }
                        
                        print("통계 로드 및 파싱 성공! 주간 기록: \(self.weeklyRecords.count)개, 오늘 집중: \(self.todayFocusMinutes)분")
                    } else {
                        print("❌ JSON 파싱 실패: 서버 응답이 JSON 배열 형식이 아님.")
                    }
                } catch {
                    print("통계 디코딩 실패 (try JSONSerialization 오류): \(error)")
                }
            }
        }.resume()
    }

    // 타이머 종료 후 집중 기록을 서버에 저장
    private func saveStudyRecord(minutes: Int) {
        guard let userId = authManager.currentUserId else { return }
        guard let url = URL(string: "\(baseURL)/study_records") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: Date())
        
        // 서버에서 필요한 필드명 (username, focus_minutes, record_date)을 사용
        let body: [String: Any] = [
            "username": userId,
            "focus_minutes": minutes,
            "record_date": dateString
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error == nil {
                    print("집중 기록 저장 성공: \(minutes)분")
                    self.fetchStudyRecords(for: userId) // 기록 갱신하여 UI 업데이트
                } else {
                    print("집중 기록 저장 실패")
                }
            }
        }.resume()
    }
}
