public final class CachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    static var maxDaysOfValidCache: Int { 7 }
    private init() { }
    static func validateDate(_ timeStamp: Date, against date: Date) -> Bool {
        guard let maxDate = calendar.date(byAdding: .day, value: maxDaysOfValidCache, to: timeStamp) else {
            return false
        }
        return date < maxDate
    }
}
