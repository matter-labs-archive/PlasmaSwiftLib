//
//  PlasmaContractOperations.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 16.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

extension Web3Service {
    
    public func startExitPlasma(transaction: SignedTransaction,
                                proof: Data,
                                blockNumber: BigUInt,
                                outputNumber: BigUInt,
                                password: String? = nil) throws -> TransactionSendingResult {
        print(transaction.data.toHexString())
        print(proof.toHexString())
        print(blockNumber)
        print(outputNumber)
        do {
            let txWithdraw = try preparePlasmaContractReadTx(method: .withdrawCollateral,
                                                             value: 0,
                                                             parameters: [AnyObject](),
                                                             extraData: Data())
            let withdrawCollateral = try callPlasmaContractTx(transaction: txWithdraw)
            guard let withdrawCollateralBigUInt = withdrawCollateral.first?.value as? BigUInt else {throw StructureErrors.wrongData}
            print("collateral: \(withdrawCollateralBigUInt)")
            let txData = try transaction.serialize()
            let bN = UInt32(blockNumber)
            let oN = UInt8(outputNumber)
            let txHex = [UInt8](txData)
            let proofHex = [UInt8](proof)
            let parameters = [bN,
                              oN,
                              txHex,
                              proofHex] as [AnyObject]
            let txStartExit = try preparePlasmaContractWriteTx(method: .startExit,
                                                               value: withdrawCollateralBigUInt,
                                                               parameters: parameters,
                                                               extraData: Data())
            let startExitOptions = txStartExit.transactionOptions
//            let gas = try txStartExit.estimateGas(transactionOptions: startExitOptions)
//            startExitOptions.gasPrice = .manual(gas)
            let result = try sendPlasmaContractTx(transaction: txStartExit,
                                                  options: startExitOptions,
                                                  password: password)
            return result
        } catch {
            throw NetErrors.cantCreateRequest
        }
    }
    
    public func withdrawUTXO(utxo: PlasmaUTXOs,
                             onTestnet: Bool,
                             password: String? = nil) throws -> TransactionSendingResult {
        let block = try PlasmaService().getBlock(onTestnet: true, number: utxo.blockNumber)
        do {
            let parsedBlock = try Block(data: block)
            let proofData = try parsedBlock.getProofForTransactionByNumber(txNumber: utxo.transactionNumber)
//            guard let merkleTree = parsedBlock.merkleTree else {throw StructureErrors.wrongData}
//            guard let merkleRoot = merkleTree.merkleRoot else {throw StructureErrors.wrongData}
//            guard parsedBlock.blockHeader.merkleRootOfTheTxTree == merkleRoot else {throw StructureErrors.wrongData}
//            let included = PaddabbleTree.verifyBinaryProof(content: TreeContent(proofData.tx.data),
//                                                           proof: proofData.proof,
//                                                           expectedRoot: merkleRoot)
//            guard included == true else {throw StructureErrors.wrongData}
            
            let result = try self.startExitPlasma(transaction: proofData.tx,
                                                  proof: proofData.proof,
                                                  blockNumber: utxo.blockNumber,
                                                  outputNumber: utxo.outputNumber, password: password)
            return result
        } catch {
            throw StructureErrors.wrongData
        }
    }
}
