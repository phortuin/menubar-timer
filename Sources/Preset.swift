struct Preset: Identifiable {
    let title: String
    let seconds: Int
    let message: String

    var id: String { title }

    static let all = [
        Preset(title: "5 min break", seconds: 5 * 60, message: "Back to work you fucking slacker"),
        Preset(title: "30 min meeting", seconds: 30 * 60, message: "Wrap it up!"),
        Preset(title: "60 min meeting", seconds: 60 * 60, message: "Wrap it up!"),
    ]
}
