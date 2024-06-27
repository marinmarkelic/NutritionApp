
# NutritionApp

## Overview

NutritionApp is a mobile application designed to help users track their daily nutrition intake and maintain a healthy lifestyle. By leveraging modern technologies such as HealthKit, large language models, and advanced nutritional formulas, this app provides accurate and valuable insights into daily caloric and nutrient intake.

## Features

- Daily Nutrition Tracking: Monitor your daily intake of calories, macronutrients, and micronutrients.
- HealthKit Integration: Syncs with HealthKit to fetch user characteristics and caloric expenditure.
- Nutritional Recommendations: The app uses the Mifflin-St Jeor formula to estimate your recommended daily caloric intake.
- Large Language Models: Provides personalized dietary advice and information using OpenAI's GPT 3.5 turbo.
- Data Storage: Utilizes Realm and UserDefaults for efficient data storage and retrieval.

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

# Usage

To use core features of the app you will need to obtain CalorieNinjas and OpenAI API keys and create an assistant.

## CalorieNinjas

Once you have created an account and logged in on [CalorieNinjas website](https://calorieninjas.com) head over to "My Account". You can see the API key when "Show API key" button is pressed.

<img width="2560" alt="image" src="https://github.com/marinmarkelic/NutritionApp/assets/101728747/89cdf600-fa16-4d36-87e3-5cff329b73f5">


## OpenAI

Create an OpenAI account and visit their [Platform website](platform.openai.com). To view API keys you need to be on the "Dashboard" and select the option "API keys". From there you can create a new API key by pressing "Create new secret key".

<img width="2560" alt="image" src="https://github.com/marinmarkelic/NutritionApp/assets/101728747/5b1c926f-ddf5-400d-b5bb-e230702df5dc">


The app also needs to have an assistant. On OpenAI Dashboard head to "Assistants" and press "Create". You can define a name of your choosing and pick `gpt-3.5-turbo` as the model. The assistant ID is above the name.

<img width="2560" alt="image" src="https://github.com/marinmarkelic/NutritionApp/assets/101728747/9b158b8e-5acb-4f7e-aa8d-fa555939615a">


## Installation

To be able to run the app locally you need to pull this repository and open it with Xcode.

Open `Secrets.plist`. This is a local file where all the private keys are stored. After pasting the keys, the app can now run with all its functionalities.

<img width="1318" alt="image" src="https://github.com/marinmarkelic/NutritionApp/assets/101728747/abffc026-947e-4014-b035-cebad1305d9a">
