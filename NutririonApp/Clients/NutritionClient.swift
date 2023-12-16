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

    enum Nutrient: String, Decodable, CaseIterable {

        case fat_total_g
        case fatSaturated_g
        case protein_g
        case sodium_mg
        case potassium_mg
        case cholesterol_mg
        case carbohydrates_total_g
        case fiber_g
        case sugar_g

    }

    let name: String
    let calories: Float
    let serving_size_g: Float
    let nutrients: [Nutrient : Float]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Float.self, forKey: .calories)
        serving_size_g = try container.decode(Float.self, forKey: .serving_size_g)

        var nutrients: [Nutrient : Float] = [:]
        for nutrient in Nutrient.allCases {
            if let value = try? container.decode(Float.self, forKey: CodingKeys(stringValue: nutrient.rawValue)!) {
                nutrients[nutrient] = value
            }
        }
        self.nutrients = nutrients
    }

    enum CodingKeys: String, CodingKey {
        case name
        case calories
        case serving_size_g
        case fat_total_g
        case fatSaturated_g
        case protein_g
        case sodium_mg
        case potassium_mg
        case cholesterol_mg
        case carbohydrates_total_g
        case fiber_g
        case sugar_g
    }

}

enum NutritionClientError: Error {

    case basicError

}
