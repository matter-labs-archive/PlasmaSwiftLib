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
    public var receiverEthereumAddressInData: Data
    public var amount: BigUInt
    public var data: Data
    public var transactionOutput: [AnyObject]
    
    public init?(outputNumberInTx: BigUInt, receiverEthereumAddress: EthereumAddress, amount: BigUInt){
        guard outputNumberInTx.bitWidth <= Constants.outputNumberInTxMaxWidth else {return nil}
        let receiverEthereumAddressInData: Data = receiverEthereumAddress.addressData
        guard amount.bitWidth <= Constants.amountMaxWidth else {return nil}
    
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
        self.receiverEthereumAddressInData = receiverEthereumAddressInData
        
        let transactionOutput = [outputNumberInTx, receiverEthereumAddressInData, amount] as [AnyObject]
        self.transactionOutput = transactionOutput
        guard let data = RLP.encode(transactionOutput) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let outputNumberInTxData = dataArray[0]?.data else {return nil}
        guard let receiverEthereumAddressData = dataArray[1]?.data else {return nil}
        guard let amountData = dataArray[2]?.data else {return nil}
        
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        let receiverEthereumAddress = EthereumAddress(receiverEthereumAddressData)
        let receiverEthereumAddressInData = receiverEthereumAddressData
        let amount = BigUInt(amountData)
        
        self.data = data
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress!
        self.amount = amount
        self.receiverEthereumAddressInData = receiverEthereumAddressInData
        self.transactionOutput = [outputNumberInTx, receiverEthereumAddressInData, amount] as [AnyObject]
    }
}

extension TransactionOutput: Equatable {
    public static func ==(lhs: TransactionOutput, rhs: TransactionOutput) -> Bool {
        return lhs.outputNumberInTx == rhs.outputNumberInTx && lhs.receiverEthereumAddress.address == rhs.receiverEthereumAddress.address && lhs.amount == rhs.amount && lhs.data == rhs.data
    }
}
