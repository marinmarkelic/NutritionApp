extension Home {

    enum Action {

        case onAppear
        case onMealsUpdate(Result<[MealViewModel], Error>)

    }

}
