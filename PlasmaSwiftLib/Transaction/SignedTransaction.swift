//
//  SignedTransaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class SignedTransaction {
    
    private let helpers = TransactionHelpers()
    
    public var transaction: Transaction
    public var v: BigUInt
    public var r: BigUInt
    public var s: BigUInt
    public var data: Data
    public var signedTransaction: [AnyObject]
    
    public init?(transaction: Transaction, v: BigUInt, r: BigUInt, s: BigUInt){
        guard v.bitWidth <= Constants.vMaxWidth else {return nil}
        guard r.bitWidth <= Constants.rMaxWidth else {return nil}
        guard s.bitWidth <= Constants.sMaxWidth else {return nil}
        
        guard v == 27 || v == 28 else {return nil}
        
        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
        
        let transactionData: [AnyObject] = helpers.transactionToAnyObject(transaction: transaction)
        
        let signedTransaction = [transactionData, v, r, s] as [AnyObject]
        self.signedTransaction = signedTransaction
        guard let data = RLP.encode(signedTransaction) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let signedTransaction = helpers.serializeSignedTransaction(dataArray) else {return nil}
        let signedTransactionArray = [signedTransaction.transaction,
                                      signedTransaction.v,
                                      signedTransaction.r,
                                      signedTransaction.s] as [AnyObject]
        
        self.data = data
        self.transaction = signedTransaction.transaction
        self.v = signedTransaction.v
        self.r = signedTransaction.r
        self.s = signedTransaction.s
        self.signedTransaction = signedTransactionArray
    }
}

extension SignedTransaction: Equatable {
    public static func ==(lhs: SignedTransaction, rhs: SignedTransaction) -> Bool {
        return lhs.transaction == rhs.transaction &&
            lhs.v == rhs.v &&
            lhs.r == rhs.r &&
            lhs.s == rhs.s
    }
}
