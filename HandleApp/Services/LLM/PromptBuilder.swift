//
//  PromptBuilder.swift
//  HandleApp
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

final class PromptBuilder {

    static func buildPostIdeasPrompt(from context: MockUserContext) -> String {
        return """
        \(FinalProductionPrompt)

        USER CONTEXT:
        Role: \(context.role)
        Primary Goal: \(context.primaryGoal)
        Industry: \(context.industry)
        Preferred Content Formats: \(context.contentFormats.joined(separator: ", "))
        Tone Preferences: \(context.tonePreferences.joined(separator: ", "))
        Target Audience: \(context.targetAudience.joined(separator: ", "))

        Display Name: \(context.displayName)
        Short Bio: \(context.shortBio)
        Active Platforms: \(context.platforms.joined(separator: ", "))
        """
    }
}
