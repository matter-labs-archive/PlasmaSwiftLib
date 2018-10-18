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

    func testInput() {
        let blockNumber: BigUInt = 10
        let txNumberInBlock: BigUInt = 1
        let outputNumberInTx: BigUInt = 1
        let amount: BigUInt = 500000000000000
        let input1 = TransactionInput(blockNumber: blockNumber, txNumberInBlock: txNumberInBlock, outputNumberInTx: outputNumberInTx, amount: amount)
        guard let data = input1?.data else {return}
        let input2 = TransactionInput(data: data)
        XCTAssert(blockNumber == input2?.blockNumber)
        XCTAssert(txNumberInBlock == input2?.txNumberInBlock)
        XCTAssert(outputNumberInTx == input2?.outputNumberInTx)
        XCTAssert(amount == input2?.amount)
    }

}
