//
//  TransactionsService.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

class Web3TransactionsService {
    
    private let web3: web3
    private let fromAddress: EthereumAddress
    private let plasmaAddress: EthereumAddress
    
    init(web3: web3, fromAddress: EthereumAddress) {
        self.web3 = web3
        self.fromAddress = fromAddress
        let address = EthereumAddress(Utils.plasmaAddress)
        precondition(address != nil)
        self.plasmaAddress = address!
    }
    
    private lazy var defaultOptions: TransactionOptions = {
        var options = TransactionOptions.defaultOptions
        options.from = fromAddress
        options.to = plasmaAddress
        return options
    }()
    
    private lazy var plasmaContract: web3.web3contract = {
        let address = EthereumAddress(Utils.plasmaAddress)
        precondition(address != nil)
        let contract = self.web3.contract(Utils.plasmaABI, at: address!, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    public func prepareWriteTxPlasma(method: PlasmaContractMethod = .deposit,
                                value: BigUInt = 0,
                                parameters: [AnyObject] = [AnyObject](),
                                extraData: Data = Data()) throws -> WriteTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        options.value = value
        
        guard let transaction = contract.method(method.rawValue,
                                                parameters: parameters,
                                                extraData: extraData,
                                                transactionOptions: options) else {
                                            throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    public func prepareReadTxPlasma(method: PlasmaContractMethod = .withdrawCollateral,
                                value: BigUInt = 0,
                                parameters: [AnyObject] = [AnyObject](),
                                extraData: Data = Data()) throws -> ReadTransaction {
        
        let contract = plasmaContract
        var options = defaultOptions
        options.value = value
        
        guard let transaction = contract.read(method.rawValue,
                                              parameters: parameters,
                                              extraData: extraData,
                                              transactionOptions: options) else {
                                                    throw Web3Error.transactionSerializationError
        }
        return transaction
    }
    
    public func startExitPlasma(transaction: SignedTransaction,
                                proof: Proof,
                                blockNumber: BigUInt,
                                outputNumber: BigUInt,
                                password: String? = nil) -> TransactionSendingResult {
        guard let txWithdraw = try? prepareReadTxPlasma(method: .withdrawCollateral,
                                                    value: 0,
                                                    parameters: [AnyObject](),
                                                    extraData: Data()) else {return}
        guard let withdrawCollateral = try? callTxPlasma(transaction: txWithdraw) else {return}
        guard let withdrawCollateralString = withdrawCollateral.first?.value as? String else {return}
        guard let withdrawCollateralBigUInt = BigUInt(withdrawCollateralString) else {return}
        
        let txSerialized = transaction.serialize()
        //let transactionHex = txSerialized.hex
        //let proof = parsedBlock.getProof(txSerialized)
        //let binaryProof = proof.proof
        //let proofHex = proof.hex
        
        guard let txStartExit = try? prepareWriteTxPlasma(method: .startExit,
                                                     value: withdrawCollateralBigUInt,
                                                     parameters: [blockNumber,
                                                                  outputNumber,
                                                                  transactionHex,
                                                                  proofHex],
                                                     extraData: Data()) else {return}
        var startExitOptions = txStartExit.transactionOptions
        startExitOptions.value = withdrawCollateralBigUInt
    
        let gas = txStartExit.estimateGas(transactionOptions: startExitOptions)
        startExitOptions.gasPrice = gas
        
        let result = sendTxPlasma(transaction: txStartExit,
                                  options: startExitOptions,
                                  password: password)
        return result
    }
    
    
    public func sendTxPlasma(transaction: WriteTransaction,
                             options: TransactionOptions? = nil,
                             password: String? = nil) throws -> TransactionSendingResult {
        let options = options ?? transaction.transactionOptions
        guard let result = password == nil ?
            try? transaction.send() :
            try? transaction.send(password: password!, transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
    
    public func callTxPlasma(transaction: ReadTransaction,
                             options: TransactionOptions? = nil) throws -> [String : Any] {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.call(transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
}
