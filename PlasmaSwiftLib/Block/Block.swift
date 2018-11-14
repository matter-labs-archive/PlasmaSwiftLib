//
//  Block.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

// No merkle root checking yet!

import Foundation
import SwiftRLP
import BigInt

public class Block {
    public var blockHeader: BlockHeader
    public var signedTransactions: [SignedTransaction]
    public var merkleTree: PaddabbleTree? {
        let transactions = self.signedTransactions
        var contents = [ContentProtocol]()
        for tx in transactions {
            let raw = SimpleContent(tx.data.sha3(.keccak256))
            contents.append(raw)
        }
        let paddingElement = SimpleContent(emptyTx.sha3(.keccak256))
        let tree = PaddabbleTree(contents, paddingElement)
        return tree
    }
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    public init(blockHeader: BlockHeader, signedTransactions: [SignedTransaction]) {
        self.blockHeader = blockHeader
        self.signedTransactions = signedTransactions
    }

    public init(data: Data) throws {
        guard data.count > blockHeaderByteLength else {throw StructureErrors.wrongDataCount}
        let headerData = Data(data[0 ..< blockHeaderByteLength])
        guard let blockHeader = try? BlockHeader(data: headerData) else {throw StructureErrors.wrongData}
        self.blockHeader = blockHeader

        let signedTransactionsData = Data(data[Int(blockHeaderByteLength) ..< data.count])
        guard let item = RLP.decode(signedTransactionsData) else {throw StructureErrors.wrongData}
        guard item.isList else {throw StructureErrors.isNotList}
        var signedTransactions = [SignedTransaction]()
        signedTransactions.reserveCapacity(item.count!)
        print("signed tx count: \(item.count!)")
        for i in 0 ..< item.count! {
            guard let txData = item[i]!.data else {throw StructureErrors.isNotData}
            
            guard let tx = try? SignedTransaction(data: txData) else {throw StructureErrors.wrongData}
            signedTransactions.append(tx)
        }
        self.signedTransactions = signedTransactions
    }

    public func serialize() throws -> Data {
        let headerData = self.blockHeader.data
        var txArray = [Data]()
        txArray.reserveCapacity(self.signedTransactions.count)
        for tx in self.signedTransactions {
            txArray.append(tx.data)
        }
        guard let txRLP = RLP.encode(txArray as [AnyObject]) else {throw StructureErrors.cantEncodeData}
        return headerData + txRLP
    }
    
    public func getProof(for transaction: SignedTransaction) throws -> (SignedTransaction, Data) {
        guard let tree = self.merkleTree else {throw StructureErrors.wrongData}
        for (counter, tx) in self.signedTransactions.enumerated() {
            let serializedTx = tx.data
            if serializedTx == transaction.data {
                guard let proof =  tree.makeBinaryProof(counter) else {throw StructureErrors.wrongData}
                return (tx, proof)
            }
        }
        throw StructureErrors.wrongData
    }
}

extension Block: Equatable {
    public static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.blockHeader == rhs.blockHeader &&
            lhs.signedTransactions == rhs.signedTransactions
    }
}
