import Foundation
import Dependencies

// TODO: create base client that handles get, post, etc. requests and make this a class. This should only contain api keys.
struct NutritionClient {

    private let apiUrl: String = "https://api.calorieninjas.com/v1/nutrition?query="
    private let apiKey: String = "rB4pVqCmFuAIPKYUunQSmA==qgG9oVfsqrPHsshE"

    func getNutritionalInformation(for query: String) async throws -> NutritionalItemsInformation {
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

// use case should convert this to array
struct NutritionalItemsInformation: Decodable, Equatable, CustomStringConvertible {

    let items: [NutritionalItemInformation]

    var description: String {
        var calories: Float = 0
        var protein: Float = 0
        var fat: Float = 0
        var carbs: Float = 0

        items.forEach {
            calories += $0.calories
            protein += $0.nutrients[.protein_g] ?? 0
            fat += $0.nutrients[.fat_total_g] ?? 0
            carbs += $0.nutrients[.carbohydrates_total_g] ?? 0
        }

        return "\(calories)g of calories, \(protein)g of protein, \(fat)g of fat, \(carbs)g of carbs"
    }

}

// not move the decoding to view viewmodel
struct NutritionalItemInformation: Decodable, Equatable, CustomStringConvertible {

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

    var description: String {

        return "\(calories)g of calories, \(nutrients[.protein_g] ?? 0)g of protein, \(nutrients[.fat_total_g] ?? 0)g of fat, \(nutrients[.carbohydrates_total_g] ?? 0)g of carbs"

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
