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
    
    init(web3: web3, keystoreManager: KeystoreManager, fromAddress: EthereumAddress) {
        self.web3 = web3
        web3.addKeystoreManager(keystoreManager)
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
    
    public func preparePlasmaContractWriteTx(method: PlasmaContractMethod = .deposit,
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
    
    public func preparePlasmaContractReadTx(method: PlasmaContractMethod = .withdrawCollateral,
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
    
    public func sendPlasmaContractTx(transaction: WriteTransaction,
                                     options: TransactionOptions? = nil,
                                     password: String? = nil) throws -> TransactionSendingResult {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.send(password: password ?? "web3swift", transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
    
    public func callPlasmaContractTx(transaction: ReadTransaction,
                                     options: TransactionOptions? = nil) throws -> [String: Any] {
        let options = options ?? transaction.transactionOptions
        guard let result = try? transaction.call(transactionOptions: options) else {
                throw Web3Error.processingError(desc: "Can't send transaction")
        }
        return result
    }
}
