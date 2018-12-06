//
//  MatterServiceTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import EthereumAddress
import Web3swift

@testable import PlasmaSwiftLib

class PlasmaServiceTests: XCTestCase {
    
    let testHelpers = TestHelpers()

    func testGetListUTXO() {
        do {
            let utxos = try PlasmaService().getUTXOs(for: testHelpers.fromAddress, onTestnet: true)
            for utxo in utxos {
                print(utxo.value)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testSendTransaction() {
        do {
            let utxos = try PlasmaService().getUTXOs(for: testHelpers.fromAddress, onTestnet: true)
            print("UTXOs count \(utxos.count)")
            let transaction = try self.testHelpers.SplitTransaction(utxos: utxos)
            let signedTransaction = try transaction.sign(privateKey: testHelpers.privateKeyData)
            XCTAssertEqual(testHelpers.fromAddress, signedTransaction.sender)
            let result = try PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true)
            XCTAssert(result == true)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testMergeUTXOs() {
        do {
            let utxos = try PlasmaService().getUTXOs(for: testHelpers.fromAddress, onTestnet: true)
            print("UTXOs count \(utxos.count)")
            let transaction = try self.testHelpers.MergeTransaction(utxos: utxos)
            let signedTransaction = try transaction.sign(privateKey: testHelpers.privateKeyData)
            XCTAssertEqual(testHelpers.fromAddress, signedTransaction.sender)
            let result = try PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true)
            XCTAssert(result == true)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testGetBlock() {
        do {
            let block = try PlasmaService().getBlock(onTestnet: true, number: 1)
            let parsedBlock = try Block(data: block)
            XCTAssertEqual(parsedBlock.signedTransactions.first?.transaction.inputs.first?.blockNumber, 0)
            parsedBlock.blockHeader.printElements()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDeposit() {
        do {
            let tx = try testHelpers.web3.preparePlasmaContractWriteTx(method: .deposit, value: testHelpers.depositAmountString)
            let result = try testHelpers.web3.sendPlasmaContractTx(transaction: tx)
            print(result.hash)
        } catch  let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testExit() {
        do {
            let utxos = try PlasmaService().getUTXOs(for: testHelpers.fromAddress, onTestnet: true)
            for utxo in utxos {
                print("utxo: \(utxo.value)")
                print("block number: \(utxo.blockNumber)")
            }
            guard let utxo = utxos.first else {
                XCTFail(PlasmaErrors.StructureErrors.wrongData.localizedDescription)
                return
            }
            let result = try testHelpers.web3.withdrawUTXO(utxo: utxo, onTestnet: true, password: "web3swift")
            XCTAssert(result.hash != "")
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
