//
//  Food.swift
//  NutReader
//
//  Created by Frank Schmitt on 5/7/19.
//  Copyright © 2019 Nut Codes. All rights reserved.
//

import Foundation

public protocol FoodOrServing {}

public typealias Mass = Float

public struct Food: FoodOrServing {
    // Values are in grams
    
    // Macronutrients
    public var fatTotal: Mass = 0
    public var carbohydrates: Mass = 0
    public var protein: Mass = 0

    // Carbohydrate Detail
    public var fiber: Mass = 0
    public var sugar: Mass = 0

    // Fat Detail
    public var fatMonounsaturated: Mass = 0
    public var fatPolyunsaturated: Mass = 0
    public var fatSaturated: Mass = 0
    public var cholesterol: Mass = 0
    
    // Not in HealthKit
    public var sugarAdded: Mass = 0
    public var sugarAlcohols: Mass = 0
    public var choline: Mass = 0
    public var fluoride: Mass = 0

    // Vitamins
    public var vitaminA: Mass = 0
    public var thiamin: Mass = 0
    public var riboflavin: Mass = 0
    public var niacin: Mass = 0
    public var pantothenicAcid: Mass = 0
    public var vitaminB6: Mass = 0
    public var biotin: Mass = 0
    public var vitaminB12: Mass = 0
    public var vitaminC: Mass = 0
    public var vitaminD: Mass = 0
    public var vitaminE: Mass = 0
    public var vitaminK: Mass = 0
    public var folate: Mass = 0
    
    // Minerals
    public var calcium: Mass = 0
    public var chloride: Mass = 0
    public var iron: Mass = 0
    public var magnesium: Mass = 0
    public var phosphorus: Mass = 0
    public var potassium: Mass = 0
    public var sodium: Mass = 0
    public var zinc: Mass = 0

    // Hydration
    public var water: Mass = 0
    
    // Caffeination
    public var caffeine: Mass = 0
    
    // Ultratrace Minerals
    public var chromium: Mass = 0
    public var copper: Mass = 0
    public var iodine: Mass = 0
    public var manganese: Mass = 0
    public var molybdenum: Mass = 0
    public var selenium: Mass = 0
    
    // This value is used to normalize values of other nutrients
    // (they are stored as a fraction of the total mass), as well as to indicate a
    // serving unit where applicable (e.g. the mass of one cookie)
    public var totalMass: Mass = 100
    
    public init(fat: Mass, carbohydrates: Mass, protein: Mass) {
        self.fatTotal = fat
        self.carbohydrates = carbohydrates
        self.protein = protein
    }
}

public struct Serving: FoodOrServing {
    var food: Food
    var mass: Mass
    var servingDescription: String? = "Serving"
    var servingCount: Int? = 1
}

