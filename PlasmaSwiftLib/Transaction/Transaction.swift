//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP

class Transaction {
    public func construct(txType: Array<UInt8>, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>) -> Data? {
        guard txType.count == Constants.txTypeLength else {return nil}
        guard inputs.count == Constants.inputsArrayLength else {return nil}
        guard outputs.count == Constants.outputsArrayLength else {return nil}
        
        let dataArray = [txType, inputs, outputs] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        return data
    }
}
