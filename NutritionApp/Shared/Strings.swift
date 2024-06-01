enum Strings: String {

    case amount
    case sex
    case male
    case female
    case age
    case height
    case weight
    case date
    case today
    case deficit
    case surplus
    case search
    case save
    case calories
    case consumed
    case target
    case burned
    case assistant
    case newChat = "New chat"
    case userSettings = "User settings"
    case howOftenDoYouWorkout = "How often do you workout?"
    case loadFromHealth = "Load from Health"
    case eatenMeals = "Eaten meals"
    case atTarget = "At target"
    case typeSomething = "Type something"
    case lookUpDesiredMeal = "Look up the desired meal to view its information"
    case writeSomethingConversation = "Write something to start a conversation"
    case anErrorOccured = "An error occured. Please try again."

    case intDividedByInt = "%d / %d"
    case intPercent = "%d%"
    case intCalories = "%d calories"
    case caloriesWithDate = " calories, %@"
    case gramsOfProtein = " grams of protein"
    case gramsOfFat = " grams of fat"
    case gramsOfCarbs = " grams of carbs"

    case fat = "Fat"
    case fatSaturated = "Saturated Fat"
    case protein = "Protein"
    case sodium = "Sodium"
    case potassium = "Potassium"
    case cholesterol = "Cholesterol"
    case carbohydrates = "Carbohydrates"
    case fiber = "Fiber"
    case sugar = "Sugar"

    case nutritionChatInstructions = "Act as a nutritionist. You will be provided with a list of meals that the user ate for the last few days. You should tell the user about how healthy their diet is and give some recommendations if it isn't. Be concise, write a few sentences for each day, be more descriptive about days with unhealthy diets. Make sure to answer any followup questions in a matter that a nutritionist would."

    case nutritionSearchInstructions = "You will be provided with a list of meals that the user ate today which could be empty and a meal that the user wants to eat. You should inform the user about the healthiness of the chosen meal. The answer should be short and consise. Do not mention the eaten meals in the reply."

}

extension Strings {

    var capitalized: String {
        self.rawValue.capitalized
    }

    func formatted(_ arguments: CVarArg...) -> String {
        return String(format: self.rawValue, arguments: arguments)
    }

}
