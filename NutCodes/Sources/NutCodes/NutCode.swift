//
//  NutCode.swift
//  NutReader
//
//  Created by Frank Schmitt on 5/7/19.
//  Copyright © 2019 Nut Codes. All rights reserved.
//

import Foundation

typealias NutrientMass = (nutrient: Nutrient, mass: Mass)

public struct NutCode {
    static var version: UInt8 {
        1
    }
    
    public static func urlify(_ food: Food) -> URL {
        return URL(string: "nut://\(data(for: food).base64EncodedString())")!
    }
    
    public static func urlify(_ serving: Serving) -> URL {
        var result = data(for: serving.food)
        result.append(contentsOf: [])
        return URL(string: "nut://\(result.base64EncodedString())")!
    }
    
    public static func parse(url: URL) throws -> FoodOrServing {
        guard let scheme = url.scheme, scheme == "nut" else {
            throw NutCodeError.invalidScheme
        }

        guard let base64String = url.host else {
            throw NutCodeError.missingData
        }

        guard let data = Data(base64Encoded: base64String) else {
            throw NutCodeError.base64DecodingError
        }

        guard let version = data.first else {
            throw NutCodeError.missingVersion
        }

        guard version <= Self.version else {
            throw NutCodeError.unrecognizedVersion
        }

        return try Self.food(for: data.subdata(in: 1..<data.endIndex))
    }

    private static func food(for data: Data) throws -> FoodOrServing {
        var servingSize: Mass?

        let standardData = data.subdata(in: 0..<(Nutrient.standard.count))
        let standardNutrientMasses = try self.standardNutrients(from: standardData)

        let extendedData = data.subdata(in: (Nutrient.standard.count)..<data.endIndex)
        let extendedNutrientMasses = try self.extendedNutrients(from: extendedData, specialCodeHandler: { code, value in
            switch code {
            case 0xF0:
                servingSize = self.mass(forLinearByte: value)
                return nil
            default:
                return nil
            }

        })

        var food = Food(fat: 0, carbohydrates: 0, protein: 0)
        (standardNutrientMasses + extendedNutrientMasses).forEach { (nutrient, mass) in
            food[keyPath: nutrient.keyPath] = mass
        }

        if let servingSize = servingSize {
            return Serving(food: food, mass: servingSize)
        } else {
            return food
        }
    }

    private static func standardNutrients(from data: Data) throws -> [NutrientMass] {
        guard data.count == Nutrient.standard.count else {
            throw NutCodeError.unexpectedEndOfData
        }

        return Nutrient.standard.enumerated().map { (index, nutrient) in
            (nutrient: nutrient, mass: self.mass(forLinearByte: data[index]))
        }
    }

    private static func extendedNutrients(from data: Data, specialCodeHandler: (UInt8, UInt8) -> NutrientMass?) throws -> [NutrientMass] {
        let bytePairs = sequence(state: data.makeIterator(), next: { first in
            first.next().map { ($0, first.next()) }
        })

        return try bytePairs.compactMap { (nutrientCode, logByte) -> NutrientMass? in
            guard let logByte = logByte else {
                throw NutCodeError.unexpectedEndOfData
            }

            if let nutrient = Nutrient(rawValue: nutrientCode) {
                return (nutrient: nutrient, mass: self.mass(of: nutrient, forLogByte: logByte))
            } else {
                return specialCodeHandler(nutrientCode, logByte)
            }

        }
    }

    private static func data(for food: Food) -> Data {
        var result = Data()
        
        result.append(Self.version)
        
        result.append(contentsOf: Nutrient.standard.map { nutrient in
            return Self.linearByte(for: food[keyPath: nutrient.keyPath])
        })
        
        let extendedCodes: [[UInt8]] = Nutrient.extended.compactMap { nutrient in
            let quantity = Self.logByte(of: nutrient, for: food[keyPath: nutrient.keyPath])

            return quantity > 0 ? [nutrient.rawValue, quantity] : nil
        }
        
        result.append(contentsOf: extendedCodes.joined())
        
        return result
    }

    static func mass(forLinearByte linearByte: UInt8) -> Mass {
        return Float(linearByte)
    }

    static func linearByte(for mass: Mass) -> UInt8 {
        return UInt8(mass)
    }

    static func mass(of nutrient: Nutrient, forLogByte logByte: UInt8) -> Mass {
        let logFraction = Float(logByte) / 255.0

        return exp2(logFraction * (log2(nutrient.maximumRepresentableMass) - log2(nutrient.minimumRepresentableMass)) + log2(nutrient.minimumRepresentableMass))
    }

    static func logByte(of nutrient: Nutrient, for mass: Mass) -> UInt8 {
        if mass == 0 {
            return 0x00
        }

        let logFraction = (log2(mass) - log2(nutrient.minimumRepresentableMass)) / (log2(nutrient.maximumRepresentableMass) - log2(nutrient.minimumRepresentableMass))

        return UInt8(logFraction * 255.0)
    }
}

public enum NutCodeError: Error {
    case internalInconsistency
    case invalidScheme
    case missingData
    case base64DecodingError
    case missingVersion
    case unrecognizedVersion
    case unexpectedEndOfData
    case unrecognizedNutrientCode
}

enum Nutrient: UInt8, CaseIterable {
    case water = 0x00

    case fatTotal = 0x01
    case carbohydrates = 0x02
    case protein = 0x03
    case fiber = 0x04
    case sugar = 0x05
    case fatSaturated = 0x06
    case fatMonounsaturated = 0x07
    case fatPolyunsaturated = 0x08

    case cholesterol = 0x09
    case sugarAdded = 0x0A
    case sugarAlcohols = 0x0B

    case vitaminA = 0x20
    case thiamin = 0x21
    case riboflavin = 0x22
    case niacin = 0x23
    case pantothenicAcid = 0x24
    case vitaminB6 = 0x25
    case biotin = 0x26
    case vitaminB12 = 0x27
    case vitaminC = 0x28
    case vitaminD = 0x29
    case vitaminE = 0x2A
    case vitaminK = 0x2B
    case folate = 0x2C
    case calcium = 0x30
    case chloride = 0x31
    case iron = 0x32
    case magnesium = 0x33
    case phosphorus = 0x34
    case potassium = 0x35
    case sodium = 0x36
    case zinc = 0x37
    case chromium = 0x38
    case copper = 0x39
    case iodine = 0x3A
    case manganese = 0x3B
    case molybdenum = 0x3C
    case selenium = 0x3D
    case caffeine = 0xD0
    case choline = 0x2D
    case fluoride = 0x3E

    static var standard: [Nutrient] {
        [.fatTotal, .carbohydrates, .protein, .fiber, .sugar, .fatSaturated, .fatMonounsaturated, .fatPolyunsaturated]
    }

    static var extended: [Nutrient] {
        Array(Set(Nutrient.allCases).subtracting(Nutrient.standard))
    }

    var name: String {
        switch self {
        case .fatTotal:
            return "Total Fat"
        case .carbohydrates:
            return "Carbohydrates"
        case .protein:
            return "Protein"
        case .fiber:
            return "Fiber"
        case .sugar:
            return "Sugar"
        case .fatMonounsaturated:
            return "Monounsaturated Fat"
        case .fatPolyunsaturated:
            return "Polyunsaturated Fat"
        case .fatSaturated:
            return "Saturated Fat"
        case .cholesterol:
            return "Cholesterol"
        case .sugarAdded:
            return "Added Sugar"
        case .sugarAlcohols:
            return "Sugar Alcohols"
        case .vitaminA:
            return "Vitamin A"
        case .thiamin:
            return "Thiamin"
        case .riboflavin:
            return "Riboflavin"
        case .niacin:
            return "Niacin"
        case .pantothenicAcid:
            return "Pantothenic Acid"
        case .vitaminB6:
            return "Vitamin B6"
        case .biotin:
            return "Biotin"
        case .vitaminB12:
            return "Vitamin B12"
        case .vitaminC:
            return "Vitamin C"
        case .vitaminD:
            return "Vitamin D"
        case .vitaminE:
            return "Vitamin E"
        case .vitaminK:
            return "Vitamin K"
        case .folate:
            return "Folate"
        case .calcium:
            return "Calcium"
        case .chloride:
            return "Chloride"
        case .iron:
            return "Iron"
        case .magnesium:
            return "Magnesium"
        case .phosphorus:
            return "Phosphorus"
        case .potassium:
            return "Potassium"
        case .sodium:
            return "Sodium"
        case .zinc:
            return "Zinc"
        case .water:
            return "Water"
        case .caffeine:
            return "Caffeine"
        case .chromium:
            return "Chromium"
        case .copper:
            return "Copper"
        case .iodine:
            return "Iodine"
        case .manganese:
            return "Manganese"
        case .molybdenum:
            return "Molybdenum"
        case .selenium:
            return "Selenium"
        case .choline:
            return "Choline"
        case .fluoride:
            return "Fluoride"
        }
    }

    var keyPath: WritableKeyPath<Food, Mass> {
        switch self {
        case .fatTotal:
            return \.fatTotal
        case .carbohydrates:
            return \.carbohydrates
        case .protein:
            return \.protein
        case .fiber:
            return \.fiber
        case .sugar:
            return \.sugar
        case .fatMonounsaturated:
            return \.fatMonounsaturated
        case .fatPolyunsaturated:
            return \.fatPolyunsaturated
        case .fatSaturated:
            return \.fatSaturated
        case .water:
            return \.water
        case .cholesterol:
            return \.cholesterol
        case .sugarAdded:
            return \.sugarAdded
        case .sugarAlcohols:
            return \.sugarAlcohols
        case .vitaminA:
            return \.vitaminA
        case .thiamin:
            return \.thiamin
        case .riboflavin:
            return \.riboflavin
        case .niacin:
            return \.niacin
        case .pantothenicAcid:
            return \.pantothenicAcid
        case .vitaminB6:
            return \.vitaminB6
        case .biotin:
            return \.biotin
        case .vitaminB12:
            return \.vitaminB12
        case .vitaminC:
            return \.vitaminC
        case .vitaminD:
            return \.vitaminD
        case .vitaminE:
            return \.vitaminE
        case .vitaminK:
            return \.vitaminK
        case .folate:
            return \.folate
        case .calcium:
            return \.calcium
        case .chloride:
            return \.chloride
        case .iron:
            return \.iron
        case .magnesium:
            return \.magnesium
        case .phosphorus:
            return \.phosphorus
        case .potassium:
            return \.potassium
        case .sodium:
            return \.sodium
        case .zinc:
            return \.zinc
        case .chromium:
            return \.chromium
        case .copper:
            return \.copper
        case .iodine:
            return \.iodine
        case .manganese:
            return \.manganese
        case .molybdenum:
            return \.molybdenum
        case .selenium:
            return \.selenium
        case .caffeine:
            return \.caffeine
        case .choline:
            return \.choline
        case .fluoride:
            return \.fluoride
        }
    }

    var minimumRepresentableMass: Float {
        switch self {
        case .cholesterol:
            return 0.001
        case .vitaminA:
            return 0.000001
        case .thiamin:
            return 0.000001
        case .riboflavin:
            return 0.000001
        case .niacin:
            return 0.00001
        case .pantothenicAcid:
            return 0.0001
        case .vitaminB6:
            return 0.000001
        case .biotin:
            return 0.00001
        case .vitaminB12:
            return 0.00000001
        case .vitaminC:
            return 0.0001
        case .vitaminD:
            return 0.00000001
        case .vitaminE:
            return 0.00001
        case .vitaminK:
            return 0.0000001
        case .folate:
            return 0.000001
        case .calcium:
            return 0.001
        case .chloride:
            return 0.001
        case .iron:
            return 0.001
        case .magnesium:
            return 0.001
        case .phosphorus:
            return 0.001
        case .potassium:
            return 0.01
        case .sodium:
            return 0.001
        case .zinc:
            return 0.00001
        case .caffeine:
            return 0.001
        case .chromium:
            return 0.0000001
        case .copper:
            return 0.000001
        case .iodine:
            return 0.000001
        case .manganese:
            return 0.00001
        case .molybdenum:
            return 0.0000001
        case .selenium:
            return 0.0000001
        case .choline:
            return 0.001
        case .fluoride:
            return 0.00001
        default:
            return 1
        }
    }
    
    var maximumRepresentableMass: Float {
        255.0
    }
}
