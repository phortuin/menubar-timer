struct Preset: Identifiable {
    let id: String
    let title: String
    let seconds: Int
    let message: String
    /// The preset that the time's-up notification offers to start next.
    let next: String?

    static let all = [
        Preset(id: "break", title: "Start 5 min break", seconds: 5 * 60,
               message: "Back to work you fucking slacker", next: "work"),
        Preset(id: "work", title: "Start 25 min work", seconds: 25 * 60,
               message: "Slow it down motherfucker", next: "break"),
        Preset(id: "eval", title: "Start eval talk", seconds: 45 * 60,
               message: "Wrap it up!", next: nil),
    ]

    static func with(id: String?) -> Preset? {
        all.first { $0.id == id }
    }
}
