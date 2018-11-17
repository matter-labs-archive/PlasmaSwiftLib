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
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            return
        }
        do {
            let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: true)
            for utxo in utxos {
                print(utxo.value)
            }
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testSendTransaction() {
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            return
        }
        do {
            let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: true)
            print("UTXOs count \(utxos.count)")
            let transaction = try self.testHelpers.UTXOsToTransaction(utxos: utxos, address: address, txType: .split)
            let signedTransaction = try transaction.sign(privateKey: privKey)
            XCTAssertEqual(address, signedTransaction.sender)
            let result = try PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true)
            XCTAssert(result == true)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testMergeUTXOs() {
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            return
        }
        do {
            let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: true)
            print("UTXOs count \(utxos.count)")
            let transaction = try self.testHelpers.UTXOsToTransaction(utxos: utxos, address: address, txType: .merge)
            let signedTransaction = try transaction.sign(privateKey: privKey)
            XCTAssertEqual(address, signedTransaction.sender)
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
        let amount: BigUInt = 1000000000000000000
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            return
        }
        let privKey = "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5"
        do {
            let text = privKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = Data.fromHex(text) else {
                XCTFail(StructureErrors.wrongData.localizedDescription)
                return
            }
            guard let keystore = try EthereumKeystoreV3(privateKey: data, password: "web3swift") else {
                XCTFail(StructureErrors.wrongData.localizedDescription)
                return
            }
            let keystoreManager = KeystoreManager([keystore])
            let web3 = Web3Service(web3: Web3.InfuraRinkebyWeb3(), keystoreManager: keystoreManager, fromAddress: address)
            let tx = try web3.preparePlasmaContractWriteTx(method: .deposit, value: amount, parameters: [AnyObject](), extraData: Data())
            let result = try web3.sendPlasmaContractTx(transaction: tx)
            print(result.hash)
        } catch  let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testExit() {
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            return
        }
        let privKey = "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5"
        do {
            let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: true)
            for utxo in utxos {
                print("utxo: \(utxo.value)")
                print("block number: \(utxo.blockNumber)")
            }
            guard let utxo = utxos.first else {
                XCTFail(StructureErrors.wrongData.localizedDescription)
                return
            }
            
            let text = privKey.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = Data.fromHex(text) else {
                XCTFail(StructureErrors.wrongData.localizedDescription)
                return
            }
            guard let keystore = try EthereumKeystoreV3(privateKey: data, password: "web3swift") else {
                XCTFail(StructureErrors.wrongData.localizedDescription)
                return
            }
            let keystoreManager = KeystoreManager([keystore])
            let web3 = Web3Service(web3: Web3.InfuraRinkebyWeb3(), keystoreManager: keystoreManager, fromAddress: address)
            let result = try web3.withdrawUTXO(utxo: utxo, onTestnet: true, password: "web3swift")
            XCTAssert(result.hash != "")
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}
