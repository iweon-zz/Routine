import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selection = 0
    @State private var email = ""     // 아이디
    @State private var password = ""  // 비밀번호
    @State private var username = ""  // 이름
    
    var body: some View {
        VStack {
            Text("Routine")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            Picker(selection: $selection, label: Text("Auth Type")) {
                Text("로그인").tag(0)
                Text("회원가입").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal).padding(.bottom, 20)
            
            VStack(spacing: 15) {
                if selection == 1 {
                    TextField("닉네임", text: $username)
                        .padding().background(Color(.systemGray6)).cornerRadius(8)
                }
                TextField("아이디", text: $email)
                    .autocapitalization(.none)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                SecureField("비밀번호", text: $password)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
            }
            .padding(.horizontal)
            
            if authManager.showLoginError {
                Text(authManager.errorMessage)
                    .foregroundColor(.red).font(.caption).padding(.top, 5)
            }
            
            Spacer().frame(height: 30)
            
            Button(action: {
                if selection == 0 {
                    // 로그인 시도
                    authManager.login(id: email, pw: password)
                } else {
                    // 회원가입 시도 (이름, 아이디, 비번 전달)
                    authManager.signUp(username: email, password: password, name: username)
                }
            }) {
                Text(selection == 0 ? "로그인" : "회원가입")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.blue).cornerRadius(10)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}
