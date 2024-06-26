import Dependencies

class ModelInstructionsService {

    func generateDailyMealsInstructions(for newMeal: String, meals: [MealViewModel]) async -> String {
        var instruction = ""
        meals.forEach { meal in
            instruction.append(" Meal: \(meal.name), ingredients:")

            meal.items.forEach { ingredient in
                instruction.append(" \(ingredient.serving_size_g) g of \(ingredient.name),")
            }
        }

        return Strings.nutritionSearchInstructions1.formatted((instruction.isEmpty ? "none" : instruction), newMeal)
    }

    func generateChatsInstructions(for meals: [MealViewModel]) -> String {
        let formattedMeals = format(meals: meals)

        var instruction = ""

        formattedMeals.keys.forEach { day in
            guard let dailyMeals = formattedMeals[day] else { return }

            let dayString: String
            switch day {
            case 0:
                dayString = "Today:"
            case -1:
                dayString = "Yesterday:"
            default:
                dayString = "\(abs(day)) days ago:"
            }
            instruction.append(dayString)

            dailyMeals.forEach { meal in
                instruction.append(" Meal: \(meal.name), ingredients:")

                meal.items.forEach { ingredient in
                    instruction.append(" \(ingredient.serving_size_g) g of \(ingredient.name),")
                }
            }

            instruction.removeLast()
            instruction.append(";")
        }

        if !instruction.isEmpty {
            instruction.removeLast()
        }

        return Strings.nutritionChatInstructions1.formatted(instruction)

    }

    private func format(meals: [MealViewModel]) -> [Int: [MealViewModel]] {
        var mealsForDaysAgo: [Int: [MealViewModel]] = [:]
        meals.forEach { meal in
            let daysAgo = meal.date.distance(from: .now, only: .day)

            guard var meals = mealsForDaysAgo[daysAgo] else {
                mealsForDaysAgo[daysAgo] = [meal]
                return
            }

            meals.append(meal)
            mealsForDaysAgo[daysAgo] = meals
        }

        return mealsForDaysAgo
    }

}

extension ModelInstructionsService: DependencyKey {

    static var liveValue: ModelInstructionsService {
        ModelInstructionsService()
    }

}

extension DependencyValues {

    var modelInstructionsService: ModelInstructionsService {
        get { self[ModelInstructionsService.self] }
        set { self[ModelInstructionsService.self] = newValue }
    }

}
