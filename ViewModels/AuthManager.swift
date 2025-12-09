import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUsername: String? = UserDefaults.standard.string(forKey: "currentUsername")
    @Published var currentUserId: String? = UserDefaults.standard.string(forKey: "currentUserId")
    
    @Published var showLoginError: Bool = false
    @Published var errorMessage: String = ""
    
    // 뮬레이터용 localhost 주소
    private let baseURL = "http://localhost:3000/api"

    init() {
        self.isAuthenticated = self.currentUsername != nil
    }

    //로그인 - 서버 API 호출
    func login(id: String, pw: String) {
        if id.isEmpty || pw.isEmpty {
            self.errorMessage = "아이디와 비밀번호를 입력해주세요."
            self.showLoginError = true
            return
        }
        
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["username": id, "password": pw]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "서버 연결 실패: \(error.localizedDescription)"
                    self.showLoginError = true
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "데이터를 받지 못했습니다."
                    self.showLoginError = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            let name = json["name"] as? String ?? id
                            let username = json["username"] as? String ?? id
                            
                            UserDefaults.standard.set(name, forKey: "currentUsername")
                            UserDefaults.standard.set(username, forKey: "currentUserId")
                            self.currentUsername = name
                            self.currentUserId = username
                            self.isAuthenticated = true
                            self.showLoginError = false
                            print("로그인 성공: \(name)")
                        } else {
                            self.errorMessage = json["message"] as? String ?? "로그인 실패"
                            self.showLoginError = true
                        }
                    }
                } catch {
                    self.errorMessage = "응답 처리 오류"
                    self.showLoginError = true
                }
            }
        }.resume()
    }

    // 회원가입 - 서버 API 호출
    func signUp(username: String, password: String, name: String) {
        if username.isEmpty || password.isEmpty || name.isEmpty {
            self.errorMessage = "모든 정보를 입력해주세요."
            self.showLoginError = true
            return
        }
        
        guard let url = URL(string: "\(baseURL)/signup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["username": username, "password": password, "name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "서버 연결 실패: \(error.localizedDescription)"
                    self.showLoginError = true
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "데이터를 받지 못했습니다."
                    self.showLoginError = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let success = json["success"] as? Bool, success {
                            // 회원가입 성공 후 자동 로그인
                            UserDefaults.standard.set(name, forKey: "currentUsername")
                            UserDefaults.standard.set(username, forKey: "currentUserId")
                            self.currentUsername = name
                            self.currentUserId = username
                            self.isAuthenticated = true
                            self.showLoginError = false
                            print("회원가입 성공: \(name)")
                        } else {
                            self.errorMessage = json["message"] as? String ?? "회원가입 실패"
                            self.showLoginError = true
                        }
                    }
                } catch {
                    self.errorMessage = "응답 처리 오류"
                    self.showLoginError = true
                }
            }
        }.resume()
    }
    
    // 로그아웃
    func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        self.currentUsername = nil
        self.currentUserId = nil
        self.isAuthenticated = false
        print("로그아웃 성공")
    }
}
