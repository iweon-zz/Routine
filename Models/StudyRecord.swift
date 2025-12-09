import Foundation

// ForEach와 Chart 사용을 위해 Identifiable과 Codable을 준수

struct StudyRecord: Identifiable, Codable {

    var id = UUID()           // Identifiable 요구 사항

    let focusMinutes: Int

    // StatsView에서 참조하는 date 필드 (서버의 record_date와 매핑)

    let date: Date

    let username: String?

    var record_id: Int?

    // 서버와의 Codable 매핑

    enum CodingKeys: String, CodingKey {

        case focusMinutes
        case date = "record_date"
        case username
        case record_id
    }
}
