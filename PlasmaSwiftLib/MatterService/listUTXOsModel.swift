//
//  listUTXOs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

class ListUTXOsModel {
    public var blockNumber: BigUInt
    public var transactionNumber: BigUInt
    public var outputNumber: BigUInt
    public var value: BigUInt
    
    public init?(json: [String: Any]) {
        guard let blockNumber = json["blockNumber"] as? Int else {return nil}
        guard let transactionNumber = json["transactionNumber"] as? Int else {return nil}
        guard let outputNumber = json["outputNumber"] as? Int else {return nil}
        guard let value = json["value"] as? String else {return nil}
        
        guard let bigUIntValue = BigUInt(value) else {return nil}
        
        self.blockNumber = BigUInt(blockNumber)
        self.transactionNumber = BigUInt(transactionNumber)
        self.outputNumber = BigUInt(outputNumber)
        self.value = bigUIntValue
    }
}
