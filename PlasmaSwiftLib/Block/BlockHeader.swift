//
//  BlockHeader.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

public struct BlockHeader {

    public var blockNumber: BigUInt
    public var numberOfTxInBlock: BigUInt
    public var parentHash: Data
    public var merkleRootOfTheTxTree: Data
    public var v: BigUInt
    public var r: Data
    public var s: Data
    public var data: Data {
        return self.serialize()
    }

    public init?(blockNumber: BigUInt, numberOfTxInBlock: BigUInt, parentHash: Data, merkleRootOfTheTxTree: Data, v: BigUInt, r: Data, s: Data) {
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {return nil}
        guard parentHash.count == parentHashByteLength else {return nil}
        guard merkleRootOfTheTxTree.count == merkleRootOfTheTxTreeByteLength else {return nil}
        guard v.bitWidth <= vMaxWidth else {return nil}
        guard r.count == rByteLength else {return nil}
        guard s.count == sByteLength else {return nil}

        guard v == 27 || v == 28 else {return nil}

        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }
    
    public init?(data: Data) {
        var max = 0
        var min = 0
        var elements = [String]()
        let dataString = data.toHexString()
        let dataStringArray = dataString.split(intoChunksOf: 2)
        print(dataString)
        print(dataStringArray)
        print(dataStringArray.count)
        
//        let array = [UInt8](data)
//        var elements = [String]()
//        var max = 0
//        var min = 0
//        print(array)
//        print(array.count)
        
        guard dataStringArray.count == Int(blockHeaderByteLength) else {return nil}
        
        for i in 0..<7 {
            var bytes = 0
            switch i {
            case 0:
                bytes = Int(blockNumberByteLength)
            case 1:
                bytes = Int(blockNumberByteLength)
            case 2:
                bytes = Int(parentHashByteLength)
            case 3:
                bytes = Int(merkleRootOfTheTxTreeByteLength)
            case 4:
                bytes = Int(vByteLength)
            case 5:
                bytes = Int(rByteLength)
            default:
                bytes = Int(sByteLength)
            }
            min = max
            max += bytes
            let elementSlice = dataStringArray[min..<max]
            let elementArray: [String] = Array(elementSlice)
            let element = elementArray.joined()
            elements.append(element)
        }
        
//        let blockNumberStringArray = (elements[0]).map {String($0)}
//        let blockNumberString = blockNumberStringArray.joined()
        guard let blockNumberDec = UInt8(elements[0], radix: 16) else {return nil}
        let blockNumber = BigUInt(blockNumberDec)
        print(blockNumber)
        
//        let numberOfTxInBlockStringArray = (elements[1]).map {String($0)}
//        let numberOfTxInBlockString = numberOfTxInBlockStringArray.joined()
        guard let numberOfTxInBlockDec = UInt8(elements[1], radix: 16) else {return nil}
        let numberOfTxInBlock = BigUInt(numberOfTxInBlockDec)
        print(numberOfTxInBlock)
        
//        let parentHashStringArray = (elements[2]).map {String(format: "%X", $0)}
//        let parentHashString = parentHashStringArray.joined().lowercased()
        let parentHash = Data(hex: elements[2])
        print(elements[2])
        
//        let merkleRootOfTheTxTreeStringArray = (elements[3]).map {String(format: "%X", $0)}
//        let merkleRootOfTheTxTreeString = merkleRootOfTheTxTreeStringArray.joined().lowercased()
        let merkleRootOfTheTxTree = Data(hex: elements[3])
        print(elements[3])
        
//        let vStringArray = (elements[4]).map {String($0)}
//        let vString = vStringArray.joined()
        guard let vDec = UInt8(elements[4], radix: 16) else {return nil}
        let v = BigUInt(vDec)
        print(v)
        
//        let rStringArray = (elements[5]).map {String(format: "%X", $0)}
//        let rString = rStringArray.joined().lowercased()
        let r = Data(hex: elements[5])
        print(elements[5])
        
//        let sStringArray = (elements[6]).map {String(format: "%X", $0)}
//        let sString = sStringArray.joined().lowercased()
        let s = Data(hex: elements[6])
        print(elements[6])

        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {return nil}
        guard parentHash.count == parentHashByteLength else {return nil}
        guard merkleRootOfTheTxTree.count == merkleRootOfTheTxTreeByteLength else {return nil}
        guard v.bitWidth <= vMaxWidth else {return nil}
        guard r.count == rByteLength else {return nil}
        guard s.count == sByteLength else {return nil}

        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }

    public func serialize() -> Data {
        var d = Data()
        let blockNumberData = self.blockNumber.serialize().setLengthLeft(blockNumberByteLength)!
        let txNumberData = self.numberOfTxInBlock.serialize().setLengthLeft(txNumberInBlockByteLength)!

        d.append(blockNumberData)
        d.append(txNumberData)
        d.append(self.merkleRootOfTheTxTree)
        d.append(self.parentHash)

        let vData = self.v.serialize().setLengthLeft(vByteLength)!
        d.append(vData)
        d.append(self.r)
        d.append(self.s)

        precondition(d.count == blockHeaderByteLength)
        return d
    }
}

extension BlockHeader: Equatable {
    public static func ==(lhs: BlockHeader, rhs: BlockHeader) -> Bool {
        return lhs.blockNumber == rhs.blockNumber &&
            lhs.numberOfTxInBlock == rhs.numberOfTxInBlock &&
            lhs.parentHash == rhs.parentHash &&
            lhs.merkleRootOfTheTxTree == rhs.merkleRootOfTheTxTree &&
            lhs.v == rhs.v &&
            lhs.r == rhs.r &&
            lhs.s == rhs.s
    }
}
