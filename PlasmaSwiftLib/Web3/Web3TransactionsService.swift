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

public final class Web3TransactionsService {
    
    private let web3: web3
    private let fromAddress: EthereumAddress
    private let plasmaAddress: EthereumAddress
    
    init(web3: web3, fromAddress: EthereumAddress) {
        self.web3 = web3
        self.fromAddress = fromAddress
        let address = EthereumAddress(PlasmaUtils.plasmaAddress)
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
        let address = EthereumAddress(PlasmaUtils.plasmaAddress)
        precondition(address != nil)
        let contract = self.web3.contract(PlasmaUtils.plasmaABI, at: address!, abiVersion: 2)
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
                                proof: Data,
                                blockNumber: BigUInt,
                                outputNumber: BigUInt,
                                password: String? = nil) throws -> TransactionSendingResult {
        do {
            let txWithdraw = try prepareReadTxPlasma(method: .withdrawCollateral,
                                                      value: 0,
                                                      parameters: [AnyObject](),
                                                      extraData: Data())
            let withdrawCollateral = try callTxPlasma(transaction: txWithdraw)
            let withdrawCollateralString = withdrawCollateral.first?.value as? String
            let withdrawCollateralBigUInt = BigUInt(withdrawCollateralString ?? "0.0") ?? BigUInt(0.0)
            let txHex = try transaction.serialize().toHexString()
            let proofHex = proof.toHexString()
            let parameters = [blockNumber,
                              outputNumber,
                              txHex,
                              proofHex] as [AnyObject]
            let txStartExit = try prepareWriteTxPlasma(method: .startExit,
                                                       value: withdrawCollateralBigUInt,
                                                       parameters: parameters,
                                                       extraData: Data())
            var startExitOptions = txStartExit.transactionOptions
            let gas = try txStartExit.estimateGas(transactionOptions: startExitOptions)
            startExitOptions.gasPrice = .manual(gas)
            let result = try sendTxPlasma(transaction: txStartExit,
                                      options: startExitOptions,
                                      password: password)
            return result
        } catch {
            throw NetErrors.cantCreateRequest
        }
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
                             options: TransactionOptions? = nil) throws -> [String: Any] {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.call(transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
}
