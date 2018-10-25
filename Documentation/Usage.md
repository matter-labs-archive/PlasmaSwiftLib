# Usage

## Transaction

#### Form input

```swift
let blockNumberIn: BigUInt = 10
let txNumberInBlockIn: BigUInt = 1
let outputNumberInTxIn: BigUInt = 3
let amountIn: BigUInt = 500000000000000
guard let input1 = TransactionInput(blockNumber: blockNumberIn,
				    txNumberInBlock: txNumberInBlockIn,
				    outputNumberInTx: outputNumberInTxIn,
				    amount: amountIn) else {return nil}
```

#### Form output

```swift
let outputNumberInTxOut: BigUInt = 3
guard let receiverEthereumAddressOut: EthereumAddress = EthereumAddress("<Ethereum address>") else {return}
let amountOut: BigUInt = 300000000000000
guard let output = TransactionOutput(outputNumberInTx: outputNumberInTxOut,
				      receiverEthereumAddress: receiverEthereumAddressOut,
				      amount: amountOut) else {return nil}
```

#### Form transaction and sign it

```swift
let txType = Transaction.TransactionType.split //or null/fund/merge
let inputs = [TransactionInput]()
let outputs = [TransactionOutput]()
guard let transaction = Transaction(txType: txType, inputs: inputs, outputs: outputs) else {return}

let privKey = Data(hex: "<Private key>")
let signedTransaction = transaction.sign(privateKey: privKey)
```

## UTXOs listing

#### Get UTXOs list for Ethereum address

```swift
guard let ethAddress = EthereumAddress("<Ethereum address>") else {return}
ServiceUTXO().getListUTXOs(for: ethAddress,
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
In this example transaction inputs are formed from first UTXO you get for your Ethereum address. Used 'split' transaction type.

```swift
guard let fromEthAddress = EthereumAddress("<From Ethereum address>") else {return}
guard let toEthAddress = EthereumAddress("<To Ethereum address>") else {return}
let privKey = Data(hex: "<From private key>")
ServiceUTXO().getListUTXOs(for: fromEthAddress,
                           onTestnet: '<Bool flag for using Rinkeby network>') { (result) in
    switch result {
    case .Success(let utxos):
	guard let input = utxos[0].toTransactionInput() else {return}
	let inputs = [input]
	guard let output = TransactionOutput(outputNumberInTx: 0,
	                                     receiverEthereumAddress: toEthAddress,
					     amount: input.amount) else {return}
	let outputs = [output]
	guard let transaction = Transaction(txType: .split,
	                                    inputs: inputs,
					    outputs: outputs) else {return}
	guard let signedTransaction = transaction.sign(privateKey: privKey) else {return}
	ServiceUTXO().sendRawTX(transaction: signedTransaction,
	                        onTestnet: true) { (result) in
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
let fixedAmount: BigUInt = 10000000000
let inputs = [TransactionInput]()
let outputs = [TransactionOutput]()
guard let tx = Transaction(txType: .split, inputs: inputs, outputs: outputs) else {return}
guard let newTx = tx.mergeOutputs(untilMaxAmount: fixedAmount) else {return}
```


#### Merge outputs for fixed number of outputs

```swift
let fixedNumber: BigUInt = 2
let inputs = [TransactionInput]()
let outputs = [TransactionOutput]()
guard let tx = Transaction(txType: .split, inputs: inputs, outputs: outputs) else {return}
guard let newTx = tx.mergeOutputs(forMaxNumber: fixedNumber) else {return}
```

