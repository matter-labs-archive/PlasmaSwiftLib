//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class Transaction {
    
    public var txType: BigUInt
    public var inputs: Array<TransactionInput>
    public var outputs: Array<TransactionOutput>
    public var data: Data
    public var transaction: [AnyObject]
    
    public init?(txType: BigUInt, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>){
        guard txType.bitWidth <= Constants.txTypeMaxWidth else {return nil}
        guard inputs.count <= Constants.inputsArrayMax else {return nil}
        guard outputs.count <= Constants.outputsArrayMax else {return nil}
        
        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
        
        var inputsData: [AnyObject] = []
        for input in inputs {
            let inputData = [input.blockNumber, input.txNumberInBlock, input.outputNumberInTx, input.amount] as [AnyObject]
            inputsData.append(inputData as AnyObject)
        }
        
        var outputsData: [AnyObject] = []
        for output in outputs {
            let outputData = [output.outputNumberInTx, output.receiverEthereumAddressInData, output.amount] as [AnyObject]
            outputsData.append(outputData as AnyObject)
        }
        
        let transaction = [txType, inputsData, outputsData] as [AnyObject]
        self.transaction = transaction
        guard let data = RLP.encode(transaction) else {return nil}
        self.data = data
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        //tx
        guard let txTypeData = dataArray[0]?.data else {return nil}
        guard let inputsData = dataArray[1] else {return nil}
        guard let outputsData = dataArray[2] else {return nil}
        
        //inputs
        guard let inputCount = inputsData.count else {return nil}
        guard let inputData1 = inputsData[0] else {return nil}
        guard let blockNumberData1In = inputData1[0]?.data else {return nil}
        guard let txNumberInBlockData1In = inputData1[1]?.data else {return nil}
        guard let outputNumberInTxData1In = inputData1[2]?.data else {return nil}
        guard let amountData1In = inputData1[3]?.data else {return nil}
        
        let blockNumber1In = BigUInt(blockNumberData1In)
        let txNumberInBlock1In = BigUInt(txNumberInBlockData1In)
        let outputNumberInTx1In = BigUInt(outputNumberInTxData1In)
        let amount1In = BigUInt(amountData1In)
        
        let transactionInput1 = TransactionInput(blockNumber: blockNumber1In,
                                                 txNumberInBlock: txNumberInBlock1In,
                                                 outputNumberInTx: outputNumberInTx1In,
                                                 amount: amount1In)
        
        let inputData2 = inputsData[1]
        let blockNumberData2In = inputData2?[0]?.data
        let txNumberInBlockData2In = inputData2?[1]?.data
        let outputNumberInTxData2In = inputData2?[2]?.data
        let amountData2In = inputData2?[3]?.data
        
        let blockNumber2In = inputCount == 2 ? BigUInt(blockNumberData2In!) : nil
        let txNumberInBlock2In = inputCount == 2 ? BigUInt(txNumberInBlockData2In!) : nil
        let outputNumberInTx2In = inputCount == 2 ? BigUInt(outputNumberInTxData2In!) : nil
        let amount2In = inputCount == 2 ? BigUInt(amountData2In!) : nil
        
        let transactionInput2 = inputCount == 2 ? TransactionInput(blockNumber: blockNumber2In!,
                                                                   txNumberInBlock: txNumberInBlock2In!,
                                                                   outputNumberInTx: outputNumberInTx2In!,
                                                                   amount: amount2In!) : nil
        
        //outputs
        guard let outputCount = outputsData.count else {return nil}
        guard let outputData1 = outputsData[0] else {return nil}
        guard let outputNumberInTxData1Out = outputData1[0]?.data else {return nil}
        guard let receiverEthereumAddressInData1Out = outputData1[1]?.data else {return nil}
        guard let amountData1Out = outputData1[2]?.data else {return nil}
        
        let outputNumberInTx1Out = BigUInt(outputNumberInTxData1Out)
        guard let receiverEthereumAddress1Out = EthereumAddress(receiverEthereumAddressInData1Out) else {return nil}
        let amount1Out = BigUInt(amountData1Out)
        
        let transactionOutput1 = TransactionOutput(outputNumberInTx: outputNumberInTx1Out,
                                                   receiverEthereumAddress: receiverEthereumAddress1Out,
                                                   amount: amount1Out)
        
        let outputData2 = outputsData[1]
        let outputNumberInTxData2Out = outputData2?[0]?.data
        let receiverEthereumAddressInData2Out = outputData2?[1]?.data
        let amountData2Out = outputData2?[2]?.data
        
        let outputNumberInTx2Out = outputCount > 1 ? BigUInt(outputNumberInTxData2Out!) : nil
        let receiverEthereumAddress2Out = outputCount > 1 ? EthereumAddress(receiverEthereumAddressInData2Out!) : nil
        let amount2Out = outputCount > 1 ? BigUInt(amountData2Out!) : nil
        
        let transactionOutput2 = outputCount > 1 ? TransactionOutput(outputNumberInTx: outputNumberInTx2Out!,
                                                                     receiverEthereumAddress: receiverEthereumAddress2Out!,
                                                                     amount: amount2Out!) : nil
        
        let outputData3 = outputsData[2]
        let outputNumberInTxData3Out = outputData3?[0]?.data
        let receiverEthereumAddressInData3Out = outputData3?[1]?.data
        let amountData3Out = outputData3?[2]?.data
        
        let outputNumberInTx3Out = outputCount == 3 ? BigUInt(outputNumberInTxData3Out!) : nil
        let receiverEthereumAddress3Out = outputCount == 3 ? EthereumAddress(receiverEthereumAddressInData3Out!) : nil
        let amount3Out = outputCount == 3 ? BigUInt(amountData3Out!) : nil
        
        let transactionOutput3 = outputCount == 3 ? TransactionOutput(outputNumberInTx: outputNumberInTx3Out!,
                                                                      receiverEthereumAddress: receiverEthereumAddress3Out!,
                                                                      amount: amount3Out!) : nil
        
        //
        let txType = BigUInt(txTypeData)
        let inputs = inputCount == 2 ? [transactionInput1, transactionInput2] : [transactionInput1]
        var outputs: Array<TransactionOutput> = []
        outputs.append(transactionOutput1!)
        if outputCount >= 2 {
            outputs.append(transactionOutput2!)
        }
        if outputCount == 3 {
            outputs.append(transactionOutput3!)
        }

        self.data = data
        self.txType = txType
        self.inputs = inputs as! Array<TransactionInput>
        self.outputs = outputs as! Array<TransactionOutput>
        self.transaction = [txType, inputsData, outputsData] as [AnyObject]
    }
}
