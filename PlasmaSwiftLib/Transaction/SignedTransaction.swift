//
//  SignedTransaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP

class SignedTransaction {
    
    public var transaction: Transaction
    public var v: Array<UInt8>
    public var r: Array<UInt8>
    public var s: Array<UInt8>
    public var data: Data
    
    public init?(transaction: Transaction, v: Array<UInt8>, r: Array<UInt8>, s: Array<UInt8>){
        guard v.count == Constants.vLength else {return nil}
        guard r.count == Constants.rLength else {return nil}
        guard s.count == Constants.sLength else {return nil}
        
        guard v[0] == 27 || v[0] == 28 else {return nil}
        
        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
        
        let dataArray = [transaction, v, r, s] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
