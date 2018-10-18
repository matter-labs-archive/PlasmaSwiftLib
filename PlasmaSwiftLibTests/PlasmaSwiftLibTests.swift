//
//  PlasmaSwiftLibTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt

@testable import PlasmaSwiftLib

class PlasmaSwiftLibTests: XCTestCase {

    func testBitFunctions () {
        let input = TransactionInput(blockNumber: BigUInt("10")!, txNumberInBlock: BigUInt("2")!, outputNumberInTx: BigUInt("3")!, amount: BigUInt("500000000000000")!)
    }

}
