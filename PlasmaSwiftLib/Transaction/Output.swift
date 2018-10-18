//
//  Output.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class TransactionOutput {
    
    public var outputNumberInTx: BigUInt
    public var receiverEthereumAddress: EthereumAddress
    public var amount: BigUInt
    public var data: Data
    
    public init?(outputNumberInTx: BigUInt, receiverEthereumAddress: EthereumAddress, amount: BigUInt){
        guard outputNumberInTx.bitWidth <= Constants.outputNumberInTxMaxWidth else {return nil}
        let receiverEthereumAddressInData: Data = receiverEthereumAddress.addressData
        guard amount.bitWidth <= Constants.amountMaxWidth else {return nil}
    
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
        
        let dataArray = [outputNumberInTx, receiverEthereumAddressInData, amount] as [AnyObject]
        guard let data = RLP.encode(dataArray) else {return nil}
        self.data = data
    }
}
