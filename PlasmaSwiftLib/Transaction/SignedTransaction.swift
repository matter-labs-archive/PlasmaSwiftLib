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
        
        let signedTransaction = [transaction, v, r, s] as [AnyObject]
        self.signedTransaction = signedTransaction
        guard let data = RLP.encode(signedTransaction) else {return nil}
        self.data = data
    }
    
//    public init?(data: Data) {
//        
//        guard let item = RLP.decode(data) else {return nil}
//        guard let dataArray = item[0] else {return nil}
//        
//        //signed tx
//        guard let tranactionData = dataArray[0] else {return nil}
//        guard let v = dataArray[1]?.data else {return nil}
//        guard let r = dataArray[2]?.data else {return nil}
//        guard let s = dataArray[3]?.data else {return nil}
//        
//        //tx
//        guard let txTypeData = tranactionData[0]?.data else {return nil}
//    }
}
