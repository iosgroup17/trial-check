//
//  LLMClient.swift
//  HandleApp
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

protocol LLMClient {
    func generatePostIdeas(
        prompt: String,
        completion: @escaping (Result<PostIdeasResponse, Error>) -> Void
    )
}
