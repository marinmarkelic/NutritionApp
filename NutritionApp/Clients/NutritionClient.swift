import Foundation
import Dependencies

// TODO: create base client that handles get, post, etc. requests and make this a class. This should only contain api keys.
struct NutritionClient {

    private let apiUrl: String = "https://api.calorieninjas.com/v1/nutrition?query="

    @Dependency(\.secretsClient) private var secretsClient

    private var apiKey: String {
        secretsClient.nutritionKey
    }

    func getNutritionalInformation(for query: String) async throws -> MealNetworkViewModel {
        guard
            let components = URLComponents(string: apiUrl + query),
            let url = components.url
        else { throw NutritionClientError.basicError }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(MealNetworkViewModel.self, from: data)
    }

}

extension NutritionClient: DependencyKey {

    static var liveValue: NutritionClient {
        NutritionClient()
    }

}

extension DependencyValues {

    var nutritionClient: NutritionClient {
        get { self[NutritionClient.self] }
        set { self[NutritionClient.self] = newValue }
    }

}

struct MealNetworkViewModel: Decodable {

    let items: [NutritionalItemNetworkViewModel]

}

struct NutritionalItemNetworkViewModel: Decodable {

    let name: String
    let calories: Float
    let serving_size_g: Float
    let fat_total_g: Float
    let fat_saturated_g: Float
    let protein_g: Float
    let sodium_mg: Float
    let potassium_mg: Float
    let cholesterol_mg: Float
    let carbohydrates_total_g: Float
    let fiber_g: Float
    let sugar_g: Float

}

enum NutritionClientError: Error {

    case basicError

}
