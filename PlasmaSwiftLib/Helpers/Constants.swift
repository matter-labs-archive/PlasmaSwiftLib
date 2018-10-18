//
//  Constants.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

class Constants {
    static let bit: UInt = 8
    static let blockNumberMaxWidth: UInt = 4 * bit
    static let txNumberInBlockMaxWidth: UInt = 4 * bit
    static let outputNumberInTxMaxWidth: UInt = 1 * bit
    static let amountMaxWidth: UInt = 32 * bit
    static let receiverEthereumAddressMaxWidth: UInt = 20 * bit
    static let txTypeMaxWidth: UInt = 1 * bit
    static let inputsArrayMax: UInt = 2
    static let outputsArrayMax: UInt = 3
    static let vMaxWidth: UInt = 1 * bit
    static let rMaxWidth: UInt = 32 * bit
    static let sMaxWidth: UInt = 32 * bit
}
