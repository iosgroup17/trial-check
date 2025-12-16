//
//  ExternalLLM.swift
//  HandleApp
//
//  Created by SDC-USER on 16/12/25.
//

//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


//
//  ExternalLLMClient.swift
//  HandleApp
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

struct ExternalLLMClient: LLMClient {
    
    // 1. YOUR OPENROUTER KEY
    private let apiKey = "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"
    
    // 2. OPENROUTER ENDPOINT
    private let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    func generatePostIdeas(
        prompt: String,
        completion: @escaping (Result<PostIdeasResponse, Error>) -> Void
    ) {
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        
        // 3. REQUIRED HEADERS
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // OpenRouter requires these for rankings/logging:
        request.addValue("https://handleapp.com", forHTTPHeaderField: "HTTP-Referer") // Replace with your site (optional)
        request.addValue("HandleApp iOS", forHTTPHeaderField: "X-Title")
        
        // 4. CHOOSE YOUR MODEL
        // Good options for JSON:
        // "openai/gpt-4o" (Best instruction following)
        // "anthropic/claude-3.5-sonnet" (Best writing style)
        // "meta-llama/llama-3-70b-instruct" (Cheaper alternative)
        
        let modelName = "openai/gpt-4o-mini"

        let requestBody: [String: Any] = [
            "model": modelName,
            "max_tokens": 1500,
            "response_format": ["type": "json_object"], // Critical for stability
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that outputs strict JSON."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // 5. PERFORM REQUEST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "ExternalLLMClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async { completion(.failure(noDataError)) }
                return
            }
            
            // 6. PARSE RESPONSE
            do {
                // OpenRouter returns the same structure as OpenAI
                let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                
                guard let contentString = openAIResponse.choices.first?.message.content else {
                    throw NSError(domain: "ExternalLLMClient", code: -2, userInfo: [NSLocalizedDescriptionKey: "No content in LLM response"])
                }
                
                // 7. CLEANUP & DECODE
                // Sometimes models wrap JSON in markdown (e.g. ```json ... ```). We remove that.
                let cleanString = contentString
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let contentData = cleanString.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let postsResponse = try decoder.decode(PostIdeasResponse.self, from: contentData)
                    
                    DispatchQueue.main.async {
                        completion(.success(postsResponse))
                    }
                } else {
                    throw NSError(domain: "ExternalLLMClient", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not convert content string to data"])
                }
                
            } catch {
                print("Parsing Error:", error)
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(rawString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Helper Structs (Same as OpenAI)
private struct OpenAIResponse: Decodable {
    let choices: [OpenAIChoice]
}

private struct OpenAIChoice: Decodable {
    let message: OpenAIMessage
}

private struct OpenAIMessage: Decodable {
    let content: String
}
