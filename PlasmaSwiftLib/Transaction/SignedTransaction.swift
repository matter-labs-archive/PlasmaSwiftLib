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
    
    public init?(transaction: Transaction, v: BigUInt, r: BigUInt, s: BigUInt){
        guard v.bitWidth <= Constants.vMaxWidth else {return nil}
        guard r.bitWidth <= Constants.rMaxWidth else {return nil}
        guard s.bitWidth <= Constants.sMaxWidth else {return nil}
        
        guard v == 27 || v == 28 else {return nil}
        
        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
        
        let dataArray = [transaction, v, r, s] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
