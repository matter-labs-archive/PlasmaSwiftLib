//
//  Output.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP

class TransactionOutput {
    public func construct(outputNumberInTx: Array<UInt8>, receiverEthereumAddress: EthereumAddress, amount: Array<UInt8>) -> Data? {
        guard outputNumberInTx.count == Constants.outputNumberInTxLength else {return nil}
        let receiverEthereumAddressInBytes: [UInt8] = Array(receiverEthereumAddress.address.utf8)
        guard amount.count == Constants.amountLegth else {return nil}
        
        let dataArray = [outputNumberInTx, receiverEthereumAddressInBytes, amount] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        return data
    }
}
