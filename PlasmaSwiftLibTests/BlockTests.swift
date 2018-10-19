//
//  BlockTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt

@testable import PlasmaSwiftLib

class BlockTests: XCTestCase {
    func testBlockHeader() {
        let blockNumber: BigUInt = 10
        let numberOfTxInBlock: BigUInt = 2
        let parentHash: BigUInt = 1241252535353532
        let merkleRootOfTheTxTree: BigUInt = 500000000
        let v: BigUInt = 27
        let r: BigUInt = 2
        let s: BigUInt = 124124
        guard let block1 = BlockHeader(blockNumber: blockNumber, numberOfTxInBlock: numberOfTxInBlock, parentHash: parentHash, merkleRootOfTheTxTree: merkleRootOfTheTxTree, v: v, r: r, s: s) else {return}
        let data = block1.data
        guard let block2 = BlockHeader(data: data) else {return}
        XCTAssert(block1 == block2)
    }
}
