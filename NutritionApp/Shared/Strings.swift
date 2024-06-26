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
    case yesterday
    case deficit
    case surplus
    case search
    case save
    case calories
    case consumed
    case target
    case burned
    case assistant
    case history
    case legend
    case newChat = "New chat"
    case userSettings = "User settings"
    case howOftenDoYouWorkout = "How often do you workout?"
    case loadFromHealth = "Load from Health"
    case eatenMeals = "Eaten meals"
    case atTarget = "At target"
    case typeSomething = "Type something"
    case enterAMeal = "Enter a meal to start your nutritional journey"
    case lookUpDesiredMeal = "Look up the desired meal to view its information"
    case writeSomethingConversation = "Write something to start a conversation"
    case anErrorOccured = "An error occured. Please try again."

    case intDividedByInt = "%d / %d"
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

    case nutritionChatInstructions = "Act as a nutritionist. You will be provided with a list of meals that the user ate for the last few days. You should tell the user about how healthy their diet is and give some recommendations if it isn't. Be concise, write a few sentences for each day, be more descriptive about days with unhealthy diets. Make sure to answer any followup questions in a matter that a nutritionist would. No yapping"

    case nutritionChatInstructions1 =
"""
    ### Instructions ###
    You’re a nutritionist. You will be provided with a list of meals that the user ate for the last few days. You should tell the user about how healthy their diet is and give some recommendations if it isn't. Make sure to answer any followup questions in a matter that a nutritionist would. No yapping.

    ### Provided data ###
    Consumed meals: %@
"""

    case nutritionSearchInstructions = "You will be provided with a list of meals that the user ate today which could be empty and a meal that the user wants to eat. You should inform the user about the healthiness of the chosen meal with the consideration of the previous meals that the user ate that day. The answer should be consise and short for healthy meals and longer for unhealthy ones with an explanation. You cannot mention the consumed meals in the reply and also take into account the weight of the meal when determining the healthiness."
    case nutritionSearchInstructions1 =
"""
    ### Instructions ###
    Your task is to evaluate the healthiness of a meal that the user wants to eat. Keep the answers short for healthy meals and more descriptive for unhealthy ones.
    I'm going to tip $1000 if you don't mention consumed meals or the serving size.

    ### Guidelines ###
    1. Determine the healthiness of a meal based on its name.
    2. Consider the serving size and its impact on health. Small quantities of otherwise unhealthy foods may have a negligible impact.
    3. Prioritize providing feedback that helps the user make informed dietary choices.
    4. Combine the information and return it in a friendly manner.

    ### Examples ###
    New meal: "50g of sugar"
    This meal is unhealthy due to high sugar content.

    New meal: "tea"
    This meal is healthy, providing hydration and antioxidants.

    New meal: "20kg of meat"
    This meal is unhealthy due to excessive quantity, which can lead to various health issues.

    ### Provided data ###
    Consumed meals: %@
    New meal: %@
"""

}

extension Strings {

    var capitalized: String {
        self.rawValue.capitalized
    }

    func formatted(_ arguments: CVarArg...) -> String {
        return String(format: self.rawValue, arguments: arguments)
    }

}
