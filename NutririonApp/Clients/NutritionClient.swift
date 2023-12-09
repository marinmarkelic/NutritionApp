import Foundation
import ComposableArchitecture

struct NutritionClient {

    private static let apiUrl: String = "https://api.calorieninjas.com/v1/nutrition?query="
    private static let apiKey: String = "rB4pVqCmFuAIPKYUunQSmA==qgG9oVfsqrPHsshE"

    var nutritionalItems: @Sendable (String) async throws -> NutritionalItemsInformation

}

extension NutritionClient: DependencyKey {

    static var liveValue: NutritionClient {
        NutritionClient(
            nutritionalItems: { query in
                guard 
                    let components = URLComponents(string: apiUrl + query),
                    let url = components.url
                else { throw NutritionClientError.basicError }

                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

                let (data, _) = try await URLSession.shared.data(for: request)

                return try JSONDecoder().decode(NutritionalItemsInformation.self, from: data)
            })
    }

}

extension DependencyValues {

    var nutritionClient: NutritionClient {
        get { self[NutritionClient.self] }
        set { self[NutritionClient.self] = newValue }
    }

}

struct NutritionalItemsInformation: Decodable, Equatable {

    let items: [NutritionalItemInformation]

}

struct NutritionalItemInformation: Decodable, Equatable {

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
