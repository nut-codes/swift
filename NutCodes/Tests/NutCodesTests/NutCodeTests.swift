//
//  NutCodeTests.swift
//  NutCodeTests
//
//  Created by Frank Schmitt on 6/19/20.
//  Copyright © 2020 Frank Schmitt. All rights reserved.
//

@testable import NutCodes
import XCTest

class NutCodeTests: XCTestCase {
    func testQuantityByteFromMass() {
        XCTAssertEqual(NutCode.logByte(of: Nutrient.magnesium, for: 0.001), 0x00)
        XCTAssertEqual(NutCode.logByte(of: Nutrient.magnesium, for: 1.0),   0x8D)
        XCTAssertEqual(NutCode.logByte(of: Nutrient.magnesium, for: 255.0), 0xFF)

        XCTAssertEqual(NutCode.logByte(of: Nutrient.chromium, for: 0.0000001), 0x00)
        XCTAssertEqual(NutCode.logByte(of: Nutrient.chromium, for: 1.0),   0xBD)
        XCTAssertEqual(NutCode.logByte(of: Nutrient.chromium, for: 255.0), 0xFF)
    }

    func testMassFromQuantityByte() {
        XCTAssertEqual(NutCode.mass(of: Nutrient.magnesium, forLogByte: 0x00), 0.001, accuracy: 0.0001)
        XCTAssertEqual(NutCode.mass(of: Nutrient.magnesium, forLogByte: 0x8D), 1.0, accuracy: 0.1)
        XCTAssertEqual(NutCode.mass(of: Nutrient.magnesium, forLogByte: 0xFF), 255.0, accuracy: 2.55)

        XCTAssertEqual(NutCode.mass(of: Nutrient.chromium, forLogByte: 0x00), 0.0000001, accuracy: 0.0000001 / 10)
        XCTAssertEqual(NutCode.mass(of: Nutrient.chromium, forLogByte: 0xBD), 1.0, accuracy: 1.0 / 10)
        XCTAssertEqual(NutCode.mass(of: Nutrient.chromium, forLogByte: 0xFF), 255.0, accuracy: 255.0 / 10)
    }

    func testHazelnuts() throws {
        var food = Food(fat: 61.0, carbohydrates: 17.0, protein: 15.0)

        food.fatSaturated = 4.5
        food.fatPolyunsaturated = 8.0
        food.fatMonounsaturated = 46.0

        food.fiber = 10.0
        food.sugar = 4.3

        food.vitaminC = 0.006
        food.vitaminB6 = 0.000563

        food.calcium = 0.114
        food.potassium = 0.680
        food.iron = 0.0047
        food.magnesium = 0.163

        let url = NutCode.urlify(food)

        guard let decodedFood = try NutCode.parse(url: url) as? Food else {
            return XCTFail("Expected food, not serving")
        }

        XCTAssertEqual(decodedFood.fatSaturated, 4.5)
        XCTAssertEqual(decodedFood.fatPolyunsaturated, 8.0)
        XCTAssertEqual(decodedFood.fatMonounsaturated, 46.0)
        XCTAssertEqual(decodedFood.fatSaturated, 4.5)

        XCTAssertEqual(decodedFood.carbohydrates, 17.0)
        XCTAssertEqual(decodedFood.protein, 15.0)
        XCTAssertEqual(decodedFood.fiber, 10.0)
        XCTAssertEqual(decodedFood.sugar, 4.3)

        XCTAssertEqual(decodedFood.vitaminC, 0.006, accuracy: 0.006 / 10.0)
        XCTAssertEqual(decodedFood.vitaminB6, 0.000563, accuracy: 0.000563 / 10.0)
        XCTAssertEqual(decodedFood.calcium, 0.114, accuracy: 0.114 / 10.0)
        XCTAssertEqual(decodedFood.potassium, 0.680, accuracy: 0.680 / 10.0)
        XCTAssertEqual(decodedFood.iron, 0.0047, accuracy: 0.0047 / 10.0)
        XCTAssertEqual(decodedFood.magnesium, 0.163, accuracy: 0.163 / 10.0)
        XCTAssertEqual(decodedFood.vitaminC, 0.006, accuracy: 0.006 / 10.0)
        XCTAssertEqual(decodedFood.vitaminB6, 0.000563, accuracy: 0.000563 / 10.0)
    }

    static var allTests = [
        ("testMassFromQuantityByte", testMassFromQuantityByte),
        ("testMassFromQuantityByte", testMassFromQuantityByte),
        ("testHazelnuts", testHazelnuts)
    ]
}
