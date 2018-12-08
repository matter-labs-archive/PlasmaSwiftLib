//
//  PlasmaCode.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08/12/2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress
import EthereumABI
import Web3swift

public struct PlasmaCode {
    public struct PlasmaParameter {
        public var type: ABI.Element.ParameterType
        public var value: AnyObject
    }
    public var txType: Transaction.TransactionType
    public var targetAddress: EthereumAddress
    public var chainID: BigUInt?
    public var amount: String?
    
    public init(_ targetAddress: EthereumAddress, txType: Transaction.TransactionType = .split) {
        self.txType = txType
        self.targetAddress = targetAddress
    }
}
