# Usage

## Transaction

#### Form input

```swift
do {
    let blockNumberIn: BigUInt = 10
    let txNumberInBlockIn: BigUInt = 1
    let outputNumberInTxIn: BigUInt = 3
    let amountIn: BigUInt = 1000000000000000000 // 1 ETH
    let input = try TransactionInput(blockNumber: blockNumberIn,
				     txNumberInBlock: txNumberInBlockIn,
				     outputNumberInTx: outputNumberInTxIn,
				     amount: amountIn)
} catch let error {
    print(error.localizedDescription)
}
```

#### Form output

```swift
do {
    let outputNumberInTx: BigUInt = 10
    let receiverEthereumAddress: EthereumAddress = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4")!
    let amount: BigUInt = 1000000000000000000 // 1 ETH
    let output = try TransactionOutput(outputNumberInTx: outputNumberInTx,
                                        receiverEthereumAddress: receiverEthereumAddress,
					amount: amount)
} catch let error {
    print(error.localizedDescription)
}
```

#### Form transaction and sign it

```swift
do {
    let txType = Transaction.TransactionType.split //or null/fund/merge
    let inputs = [TransactionInput]()
    let outputs = [TransactionOutput]()
    let transaction = try Transaction(txType: txType, inputs: inputs, outputs: outputs)
    let privKey = Data(hex: "<Private key>")
    let signedTransaction = try transaction.sign(privateKey: privKey)
} catch let error {
    print(error.localizedDescription)
}
```

## UTXOs listing

#### Get UTXOs list for Ethereum address

```swift
guard let ethAddress = EthereumAddress("<Ethereum address>") else {return}
PlasmaService().getUTXOs(for: ethAddress,
                         onTestnet: '<Bool flag for using Rinkeby network>') { (result) in
    switch result {
    case .Success(let utxos):
	DispatchQueue.main.async {
	    print(utxos.first?.value)
	}
    case .Error(let error):
	DispatchQueue.main.async {
	    print(error.localizedDescription)
	}
    }
}
```

## Send transaction

#### Send raw transaction

```swift
ServiceUTXO().sendRawTX(transaction: signedTransaction,
	                onTestnet: '<Bool flag for using Rinkeby network>') { (result) in
    switch result {
    case .Success(let accepted):
	DispatchQueue.main.async {
	    print(accepted)
	}
    case .Error(let error):
	DispatchQueue.main.async {
	    print(error.localizedDescription)
	}
    }
}
```

## Outputs management

#### Merge outputs for fixed amount of one output

```swift
do {
    let fixedAmount: BigUInt = 1000000000000000000 // 1 ETH
    let inputs = [TransactionInput]()
    let outputs = [TransactionOutput]()
    let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs)
    let newTx = try tx.mergeOutputs(untilMaxAmount: fixedAmount)
} catch let error {
    print(error.localizedDescription)
}
```


#### Merge outputs for fixed number of outputs

```swift
do {
    let fixedNumber: BigUInt = 2
    let inputs = [TransactionInput]()
    let outputs = [TransactionOutput]()
    let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs)
    let newTx = try tx.mergeOutputs(forMaxNumber: fixedNumber)
} catch let error {
    print(error.localizedDescription)
}
```

