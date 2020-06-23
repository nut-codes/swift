//
//  NutCodeTests.swift
//  NutCodeTests
//
//  Created by Frank Schmitt on 6/19/20.
//  Copyright © 2020 Frank Schmitt. All rights reserved.
//

@testable import NutCode
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

    func testPrint() {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.naturalScale]

        print("| Code | Nutrient       | Minimum Representable Mass |")
        print("|------|----------------|-------------------------------:|")

        let sortedNutrients = Nutrient.allCases.sorted(by: { $0.rawValue < $1.rawValue })
        sortedNutrients.forEach { (nutrient) in
            let mrm: Measurement = {
                switch nutrient.minimumRepresentableMass {
                case 0.000000001..<0.000001:
                    return Measurement(value: Double(nutrient.minimumRepresentableMass * 1000000000), unit: Unit(symbol: "ng"))
                case 0.000001..<0.001:
                    return Measurement(value: Double(nutrient.minimumRepresentableMass * 1000000), unit: Unit(symbol: "µg"))
                case 0.001..<1:
                    return Measurement(value: Double(nutrient.minimumRepresentableMass * 1000), unit: Unit(symbol: "mg"))
                default:
                    return Measurement(value: Double(nutrient.minimumRepresentableMass), unit: Unit(symbol: "g"))
                }
            }()

            print("|\(String(format:"%02X", nutrient.rawValue))|\(nutrient.name)|\(formatter.string(from: mrm))|")
        }
    }
}
