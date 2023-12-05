import Foundation

struct OpenAIService {
    // Your OpenAI API key
    private let apiKey = "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"

    // Function to make a request to OpenAI Vision API
    func analyzeImage(with url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "gpt-4-vision-preview")!) // Replace with actual OpenAI Vision API endpoint
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["image": url.absoluteString]
        guard let httpBody = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(NSError(domain: "JSONError", code: -1, userInfo: nil)))
            return
        }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "ResponseError", code: -2, userInfo: nil)))
                return
            }

            completion(.success(responseString))
        }.resume()
    }
}
