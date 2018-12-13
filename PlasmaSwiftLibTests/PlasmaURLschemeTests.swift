//
//  PlasmaURLschemeTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 08/12/2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import EthereumAddress

@testable import PlasmaSwiftLib

class PlasmaURLschemeTests: XCTestCase {

    func testURL() {
        let url = URL(string: "plasma:0x0A8dF54352eB4Eb6b18d0057B15009732EfB351c/split?chainId=4&value=0.3")!
        guard let parsed = PlasmaParser.parse(url.absoluteString) else {
            XCTFail("Failed input test with error: \(PlasmaErrors.StructureErrors.wrongData)")
            return
        }
        XCTAssert(parsed.amount == "0.3")
        XCTAssert(parsed.chainID == 4)
        XCTAssert(parsed.targetAddress == EthereumAddress("0x0A8dF54352eB4Eb6b18d0057B15009732EfB351c")!)
        XCTAssert(parsed.txType == .split)
    }
}
