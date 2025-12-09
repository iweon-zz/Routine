import Foundation

struct TaskItem: Identifiable, Hashable, Codable {

    var id: String
    var title: String
    var isCompleted: Bool
    var date: Date
    var subject: String
    var username: String?

    // 서버 날짜 형식 처리
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        subject = try container.decodeIfPresent(String.self, forKey: .subject) ?? "기타"
        username = try container.decodeIfPresent(String.self, forKey: .username)

        // 날짜 파싱
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsed = formatter.date(from: dateString) {
            date = parsed
            return
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let parsed = formatter.date(from: dateString) {
            date = parsed
            return
        }
        formatter.dateFormat = "yyyy-MM-dd"
        if let parsed = formatter.date(from: dateString) {
            date = parsed
            return
        }
        date = Date()
    }

    // 일반 이니셜라이저
    init(id: String = UUID().uuidString, title: String, isCompleted: Bool, date: Date, subject: String, username: String? = nil) {

        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.date = date
        self.subject = subject
        self.username = username

    }

    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, date, subject, username

    }
}
