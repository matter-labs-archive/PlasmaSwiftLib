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
            case .Success(let r):
                DispatchQueue.main.async {
                    for utxo in r {
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
            case .Success(let r):
                do {
                    guard r.count == 1 else {
                        print("The inputs count \(r.count) is wrong")
                        completedSendExpectation.fulfill()
                        return
                    }
                    let transaction = try self.testHelpers.UTXOsToTransaction(utxos: r, address: address, txType: .split)
                    let signedTransaction = try transaction.sign(privateKey: privKey)
                    XCTAssertEqual(address, signedTransaction.sender)
                    PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                        switch result {
                        case .Success(let r):
                            DispatchQueue.main.async {
                                XCTAssert(r == true)
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
            case .Success(let r):
                do {
                    guard r.count == 2 else {
                        print("The inputs count \(r.count) is wrong")
                        completedSendExpectation.fulfill()
                        return
                    }
                    let transaction = try self.testHelpers.UTXOsToTransaction(utxos: r, address: address, txType: .merge)
                    let signedTransaction = try transaction.sign(privateKey: privKey)
                    XCTAssertEqual(address, signedTransaction.sender)
                    PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                        switch result {
                        case .Success(let r):
                            DispatchQueue.main.async {
                                XCTAssert(r == true)
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
