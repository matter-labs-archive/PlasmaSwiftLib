//
//  MatterServiceTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import secp256k1_swift
import EthereumAddress
import Web3swift

@testable import PlasmaSwiftLib

class PlasmaServiceTests: XCTestCase {
    
    let testHelpers = TestHelpers()

    func testGetListUTXO() {
        let completedGetListExpectation = expectation(description: "Completed")
        PlasmaService().getUTXOs(for: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let utxos):
                DispatchQueue.main.async {
                    for utxo in utxos {
                        print(utxo.value)
                    }
                    completedGetListExpectation.fulfill()
                }
            case .Error:
                DispatchQueue.main.async {
                    completedGetListExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testSendTransaction() {
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            completedSendExpectation.fulfill()
            return
        }
        PlasmaService().getUTXOs(for: address, onTestnet: true) { (result) in
            switch result {
            case .Success(let utxos):
                do {
                    print("UTXOs count \(utxos.count)")
                    let transaction = try self.testHelpers.UTXOsToTransaction(utxos: utxos, address: address, txType: .split)
                    let signedTransaction = try transaction.sign(privateKey: privKey)
                    XCTAssertEqual(address, signedTransaction.sender)
                    PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                        switch result {
                        case .Success(let res):
                            DispatchQueue.main.async {
                                XCTAssert(res == true)
                                completedSendExpectation.fulfill()
                            }
                        case .Error:
                            DispatchQueue.main.async {
                                completedSendExpectation.fulfill()
                            }
                        }
                    }
                } catch let error {
                    XCTFail(error.localizedDescription)
                    completedSendExpectation.fulfill()
                }
            case .Error:
                DispatchQueue.main.async {
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testMergeUTXOs() {
        
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            completedSendExpectation.fulfill()
            return
        }
        PlasmaService().getUTXOs(for: address, onTestnet: true) { (result) in
            switch result {
            case .Success(let utxos):
                do {
                    print("UTXOs count \(utxos.count)")
                    let transaction = try self.testHelpers.UTXOsToTransaction(utxos: utxos, address: address, txType: .merge)
                    let signedTransaction = try transaction.sign(privateKey: privKey)
                    XCTAssertEqual(address, signedTransaction.sender)
                    PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                        switch result {
                        case .Success(let res):
                            DispatchQueue.main.async {
                                XCTAssert(res == true)
                                completedSendExpectation.fulfill()
                            }
                        case .Error:
                            DispatchQueue.main.async {
                                completedSendExpectation.fulfill()
                            }
                        }
                    }
                } catch let error {
                    XCTFail(error.localizedDescription)
                    completedSendExpectation.fulfill()
                }
            case .Error:
                DispatchQueue.main.async {
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testGetBlock() {
        let completedSendExpectation = expectation(description: "Completed")
        PlasmaService().getBlock(onTestnet: true,
                                 number: 1) { (result) in
            switch result {
            case .Success(let block):
                DispatchQueue.main.async {
                    do {
                        let parsedBlock = try Block(data: block)
                        XCTAssertEqual(parsedBlock.signedTransactions.first?.transaction.inputs.first?.blockNumber, 0)
                        parsedBlock.blockHeader.printElements()
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
    
    func testExit() {
        let completedExpectation = expectation(description: "Completed")
        PlasmaService().getUTXOs(for: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                DispatchQueue.main.async {
                    for utxo in r {
                        print("utxo: \(utxo.value)")
                        print("block number: \(utxo.blockNumber)")
                    }
                    PlasmaService().getBlock(onTestnet: true,
                                             number: (r.first?.blockNumber)!) { (result) in
                        switch result {
                        case .Success(let block):
                            DispatchQueue.main.async {
                                do {
                                    let parsedBlock = try Block(data: block)
                                    guard let transactionForProof = parsedBlock.signedTransactions.first else {
                                        XCTFail("No tx in block")
                                        return
                                    }
                                    guard let merkleTree = parsedBlock.merkleTree else {
                                        XCTFail("Can't build merkle tree")
                                        return
                                    }
                                    print("block root: \(parsedBlock.blockHeader.merkleRootOfTheTxTree.toHexString())")
                                    print("merkle tree root: \(merkleTree.merkleRoot!.toHexString())")
                                    parsedBlock.blockHeader.printElements()
                                    XCTAssertNotNil(merkleTree.merkleRoot)
                                    
                                    let included = PaddabbleTree.verifyBinaryProof(content: SimpleContent((parsedBlock.signedTransactions.first?.data)!), proof: Data(), expectedRoot: merkleTree.merkleRoot!)
                                    print(included)
                                    
                                    XCTAssertTrue(parsedBlock.blockHeader.merkleRootOfTheTxTree.toHexString() == merkleTree.merkleRoot!.toHexString(), "Merkle roots should be equal")
                                    
                                    let proof = try parsedBlock.getProof(for: transactionForProof)
                                    XCTAssertEqual(proof.0, transactionForProof)
                                    let web3 = Web3TransactionsService(web3: Web3.InfuraRinkebyWeb3(), fromAddress: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!)
                                    let tx = try web3.startExitPlasma(transaction: parsedBlock.signedTransactions.first!,
                                                                      proof: proof.1,
                                                                      blockNumber: (r.first?.blockNumber)!,
                                                                      outputNumber: (parsedBlock.signedTransactions.first?.transaction.outputs.first?.outputNumberInTx)!, password: nil)
                                    print(tx.hash)
                                } catch {
                                    XCTFail(error.localizedDescription)
                                    completedExpectation.fulfill()
                                }
                            }
                        case .Error:
                            DispatchQueue.main.async {
                                completedExpectation.fulfill()
                            }
                        }
                    }
                }
            case .Error:
                DispatchQueue.main.async {
                    completedExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 3000, handler: nil)
    }
}
