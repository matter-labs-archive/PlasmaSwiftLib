//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import secp256k1_swift

class Transaction {
    
    private let helpers = TransactionHelpers()
    
    public var txType: BigUInt
    public var inputs: Array<TransactionInput>
    public var outputs: Array<TransactionOutput>
    public var data: Data
    public var transaction: [AnyObject]
    
    public init?(txType: BigUInt, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>){
        guard txType.bitWidth <= Constants.txTypeMaxWidth else {return nil}
        guard inputs.count <= Constants.inputsArrayMax else {return nil}
        guard outputs.count <= Constants.outputsArrayMax else {return nil}
        
        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
        
        let inputsData: [AnyObject] = helpers.inputsToAnyObjectArray(inputs: inputs)
        let outputsData: [AnyObject] = helpers.outputsToAnyObjectArray(outputs: outputs)
        
        let transaction = [txType,
                           inputsData,
                           outputsData] as [AnyObject]
        self.transaction = transaction
        guard let data = RLP.encode(transaction) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let transaction = helpers.serializeTransaction(dataArray) else {return nil}

        self.data = transaction.data
        self.txType = transaction.txType
        self.inputs = transaction.inputs
        self.outputs = transaction.outputs
        
        let inputsData = helpers.inputsToAnyObjectArray(inputs: transaction.inputs)
        let outputsData = helpers.outputsToAnyObjectArray(outputs: transaction.outputs)
        
        self.transaction = [transaction.txType,
                            inputsData,
                            outputsData] as [AnyObject]
    }
    
    public func sign(privateKey: Data, useExtraEntropy: Bool = false) -> SignedTransaction? {
        for _ in 0..<1024 {
            if let signature = signature(privateKey: privateKey, useExtraEntropy: useExtraEntropy) {
                let v = BigUInt(signature.v) + BigUInt(26)
                let r = BigUInt(Data(signature.r))
                let s = BigUInt(Data(signature.s))
                if let signedTransaction = SignedTransaction(transaction: self,
                                                          v: v,
                                                          r: r,
                                                          s: s) {return signedTransaction}
            }
        }
        return nil
    }
    
    private func signature(privateKey: Data, useExtraEntropy: Bool = false) -> SECP256K1.UnmarshaledSignature? {
        guard let hash = helpers.hashForSignature(data: self.data) else {return nil}
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else {return nil}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
            return nil
        }
        return unmarshalledSignature
    }
}

extension Transaction: Equatable {
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.txType == rhs.txType &&
            lhs.inputs == rhs.inputs &&
            lhs.outputs == rhs.outputs &&
            lhs.data == rhs.data
    }
}
