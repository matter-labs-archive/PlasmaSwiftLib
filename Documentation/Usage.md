# Usage

## UTXOs listing

#### Get UTXOs list for Ethereum address

```swift
guard let ethAddress = EthereumAddress("<Ethereum address>") else {return}
ServiceUTXO().getListUTXOs(for: ethAddress, onTestnet: '<Bool flag for using Ropsten network>') { (result) in
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
In this example transaction inputs are formed from first UTXO you get for some Ethereum address. Used 'split' transaction type.

```swift
guard let fromEthAddress = EthereumAddress("<From Ethereum address>") else {return}
guard let toEthAddress = EthereumAddress("<To Ethereum address>") else {return}
let privKey = Data(hex: "<From private key>")
ServiceUTXO().getListUTXOs(for: fromEthAddress, onTestnet: '<Bool flag for using Ropsten network>') { (result) in
    switch result {
    case .Success(let utxos):
	guard let input = utxos[0].toTransactionInput() else {return}
	let inputs = [input]
	guard let output = TransactionOutput(outputNumberInTx: 0,
	                                 receiverEthereumAddress: toEthAddress,
					 amount: input.amount) else {return}
	let outputs = [output]
	guard let transaction = Transaction(txType: .split, inputs: inputs, outputs: outputs) else {return}
	guard let signedTransaction = transaction.sign(privateKey: privKey) else {return}
	ServiceUTXO().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
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


