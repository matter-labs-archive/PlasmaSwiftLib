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
    let testHelpers = TestHelpers()
    
    func testBlockHeader() {
        do {
            let blockHeader = try testHelpers.formBlockHeaderForBlock()
            let data = try blockHeader.serialize()
            let parsedBlockHeader = try BlockHeader(data: data)
            blockHeader.printElements()
            parsedBlockHeader.printElements()
            XCTAssert(blockHeader == parsedBlockHeader)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testBlock() {
        do {
            let blockHeader = try testHelpers.formBlockHeaderForBlock()
            let signedTransactions = try testHelpers.formSignedTransactionsForBlock()
            let block = Block(blockHeader: blockHeader, signedTransactions: signedTransactions)
            let data = block.data
            let parsedBlock = try Block(data: data)
            XCTAssert(parsedBlock == block)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
