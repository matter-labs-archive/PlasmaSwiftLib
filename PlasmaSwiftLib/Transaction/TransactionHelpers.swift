//
//  TransactionSerialization.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import secp256k1_swift

public struct TransactionHelpers {

    static func hashForSignature(data: Data) throws -> Data {
        let hash = try TransactionHelpers.hashPersonalMessage(data)
        return hash
    }

    static func hashPersonalMessage(_ personalMessage: Data) throws -> Data {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {throw StructureErrors.wrongData}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }

    static func publicToAddressData(_ publicKey: Data) throws -> Data {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {throw StructureErrors.wrongData}
            return try publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                throw StructureErrors.wrongData
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            throw StructureErrors.wrongDataCount
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
}
