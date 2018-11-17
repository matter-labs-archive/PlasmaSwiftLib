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
        do {
            let block = try PlasmaService().getBlock(onTestnet: true, number: 1)
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
            print("merkleTree.merkleRoot: \(merkleTree.merkleRoot!.toHexString())")
            print("blockHeader.merkleRoot : \(parsedBlock.blockHeader.merkleRootOfTheTxTree.toHexString())")
            XCTAssertTrue(parsedBlock.blockHeader.merkleRootOfTheTxTree.toHexString() == merkleTree.merkleRoot!.toHexString(), "Merkle roots should be equal")
            let proof = try parsedBlock.getProof(for: transactionForProof)
            XCTAssertEqual(proof.0, transactionForProof)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
