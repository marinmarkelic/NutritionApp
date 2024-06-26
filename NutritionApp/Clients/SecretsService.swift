import Foundation
import Dependencies

struct SecretsService {

    var nutritionKey: String {
        guard let apiKey = secrets["NutritionApiKey"] as? String else {
            print("Error - Entry not found in Secrets.plist")
            return ""
        }

        return apiKey
    }

    var openAIKey: String {
        guard let apiKey = secrets["OpenAIKey"] as? String else {
            print("Error - Entry not found in Secrets.plist")
            return ""
        }

        return apiKey
    }

    var nutritionAssistantId: String {
        guard let id = secrets["NutritionAssistantId"] as? String else {
            print("Error - Entry not found in Secrets.plist")
            return ""
        }

        return id
    }

    private var secrets: [String: Any] {
        guard let secretsPath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            print("Error - Secrets.plist not found")
            return [:]
        }

        guard let secrets = NSDictionary(contentsOfFile: secretsPath) as? [String: Any] else {
            print("Error - Unable to parse Secrets.plist")
            return [:]
        }

        return secrets
    }

}

extension SecretsService: DependencyKey {

    static var liveValue: SecretsService {
        SecretsService()
    }

}

extension DependencyValues {

    var secretsService: SecretsService {
        get { self[SecretsService.self] }
        set { self[SecretsService.self] = newValue }
    }

}
