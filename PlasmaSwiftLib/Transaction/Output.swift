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
    
    public var outputNumberInTx: Array<UInt8>
    public var receiverEthereumAddress: EthereumAddress
    public var amount: Array<UInt8>
    public var data: Data
    
    public init?(outputNumberInTx: Array<UInt8>, receiverEthereumAddress: EthereumAddress, amount: Array<UInt8>){
        guard outputNumberInTx.count == Constants.outputNumberInTxLength else {return nil}
        let receiverEthereumAddressInBytes: [UInt8] = Array(receiverEthereumAddress.address.utf8)
        guard amount.count == Constants.amountLegth else {return nil}
    
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
        
        let dataArray = [outputNumberInTx, receiverEthereumAddressInBytes, amount] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
