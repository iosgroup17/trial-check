// --- BEGIN MODIFIED FakeLLMClient.swift ---
import Foundation

struct FakeLLMClient: LLMClient {

    func generatePostIdeas(
        prompt: String,
        completion: @escaping (Result<PostIdeasResponse, Error>) -> Void
    ) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // ✅ CORRECTED: Use the new static method on the type.
                let fakeResponse = try PostIdeasResponse.load()
                
                DispatchQueue.main.async {
                    completion(.success(fakeResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    print("FakeLLMClient Error: Failed to load PostIdeasResponse from JSON.", error)
                    completion(.failure(error))
                }
            }
        }
    }
}
