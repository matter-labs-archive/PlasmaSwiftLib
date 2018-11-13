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
    
    func testGetProof() {
        let completedSendExpectation = expectation(description: "Completed")
        PlasmaService().getBlock(onTestnet: true,
                                 number: 1) { (result) in
                switch result {
                case .Success(let block):
                    DispatchQueue.main.async {
                        do {
                            let parsedBlock = try Block(data: block)
                            guard let transactionForProof = parsedBlock.signedTransactions.first else {
                                XCTFail("No tx in block")
                                return
                            }
                            XCTAssertEqual(parsedBlock.signedTransactions.first?.transaction.inputs.first?.blockNumber, 0)
                            guard let merkleTree = parsedBlock.merkleTree else {
                                XCTFail("Can't build merkle tree")
                                return
                            }
                            XCTAssertNotNil(merkleTree.merkleRoot)
                            let proof = try parsedBlock.getProof(for: transactionForProof)
                            XCTAssertEqual(proof.0, transactionForProof)
                            XCTAssert(proof.1.count != 0, "proof can't be 0")
                            completedSendExpectation.fulfill()
                        } catch {
                            XCTFail(error.localizedDescription)
                            completedSendExpectation.fulfill()
                        }
                    }
                case .Error:
                    DispatchQueue.main.async {
                        completedSendExpectation.fulfill()
                    }
                }
        }
        waitForExpectations(timeout: 300, handler: nil)
    }
}
