import Foundation

struct MockUserContext {

    let role: String
    let primaryGoal: String
    let industry: String
    let contentFormats: [String]
    let tonePreferences: [String]
    let targetAudience: [String]
    let platforms: [String]
    let displayName: String
    let shortBio: String

    static let testUser = MockUserContext(
        role: "Final year CS student building an iOS app",
        primaryGoal: "Build a strong personal brand to attract internships and early users",
        industry: "Technology / Startups",
        contentFormats: ["Storytelling", "Educational", "Behind-the-scenes"],
        tonePreferences: ["Authentic", "Clear", "Thoughtful"],
        targetAudience: ["Students", "Developers", "Early founders"],
        platforms: ["LinkedIn", "Twitter"],
        displayName: "Anushka",
        shortBio: "CS student building an app to help people grow their personal brand"
    )
}
