# Usage

<***> - input object

## Transaction

#### Form input

```swift
do {
    let amountIn: BigUInt = 1000000000000000000 // 1 ETH
    let input = try TransactionInput(blockNumber: <blockNum>,
				     txNumberInBlock: <txNum>,
				     outputNumberInTx: <outNum>,
				     amount: amountIn)
} catch let error {
    print(error.localizedDescription)
}
```

#### Form output

```swift
do {
    guard let address = EthereumAddress(<Ethereum address>) else {return}
    let amount: BigUInt = 1000000000000000000 // 1 ETH
    let output = try TransactionOutput(outputNumberInTx: <outNum>,
                                       receiverEthereumAddress: address,
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
    let privKey = Data(hex: <Private key>)
    let signedTransaction = try transaction.sign(privateKey: privKey)
} catch let error {
    print(error.localizedDescription)
}
```

## UTXOs listing

#### Get UTXOs list for Ethereum address

```swift
guard let address = EthereumAddress(<Ethereum address>) else {return}
do {
    let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: <Bool flag for using Rinkeby network>)
    for utxo in utxos {
	print(utxo.value)
    }
} catch let error {
    print(error.localizedDescription)
}
```

## Blocks

#### Get last written block, print its headers and check if transactions count is equal in Block header and in Block transactions array

```swift
do {
    let block = try PlasmaService().getBlock(onTestnet: <Bool flag for using Rinkeby network>, number: <blockNum>)
    let parsedBlock = try Block(data: block)
    parsedBlock.blockHeader.printElements() // Print all block header data
    print(parsedBlock.signedTransactions.count == parsedBlock.blockHeader.numberOfTxInBlock) // Should be true
} catch let error {
    print(error.localizedDescription)
}
```

## Send transaction in Plasma

#### Send raw transaction (Split example)

```swift
let privKey = Data(hex: <Your private key>)
guard let address = EthereumAddress(<Your Ethereum address>) else {return}
do {
    let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: <Bool flag for using Rinkeby network>)
    print("UTXOs count \(utxos.count)")
    let transaction = try self.testHelpers.UTXOsToTransaction(utxos: utxos, address: address, txType: .split) // split is the transaction type. You can also use null/fund/merge
    let signedTransaction = try transaction.sign(privateKey: privKey)
    let result = try PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: <Bool flag for using Rinkeby network>)
} catch let error {
    print(error.localizedDescription)
}
```

## Send transaction to Plasma Contract

#### Send raw transaction (Put deposit example)
```swift
let amount: BigUInt = 1000000000000000000 // 1 ETH
guard let address = EthereumAddress(<Your Ethereum address>) else {return}
let privKey = <Your private key>
do {
    let text = privKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let data = Data.fromHex(text) else {return}
    guard let keystore = try EthereumKeystoreV3(privateKey: data, password: "web3swift") else {return}
    let keystoreManager = KeystoreManager([keystore])
    let web3 = Web3Service(web3: Web3.InfuraRinkebyWeb3(), keystoreManager: keystoreManager, fromAddress: address) // or InfuraMainnetWeb3
    let tx = try web3.preparePlasmaContractWriteTx(method: .deposit, value: amount, parameters: [AnyObject](), extraData: Data())
    let result = try web3.sendPlasmaContractTx(transaction: tx)
    print(result.hash)
} catch  let error {
    print(error.localizedDescription)
}
```

#### Withdraw for chosen utxo

```swift
guard let address = EthereumAddress(<Your Ethereum address>) else {return}
let privKey = <Your private key>
do {
    let utxos = try PlasmaService().getUTXOs(for: address, onTestnet: true)
    for utxo in utxos {
	print("utxo: \(utxo.value)")
	print("block number: \(utxo.blockNumber)")
    }
    guard let utxo = utxos.first else {return} // you should choose utxo by urself

    let text = privKey.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let data = Data.fromHex(text) else {return}
    guard let keystore = try EthereumKeystoreV3(privateKey: data, password: "web3swift") else {return}
    let keystoreManager = KeystoreManager([keystore])
    let web3 = Web3Service(web3: Web3.InfuraRinkebyWeb3(), keystoreManager: keystoreManager, fromAddress: address) // or InfuraMainnetWeb3
    let result = try web3.withdrawUTXO(utxo: utxo, onTestnet: true, password: "web3swift")
    print(result.hash)
} catch let error {
    print(error.localizedDescription)
}
```

## Outputs management

#### Merge outputs for fixed amount of one output

```swift
do {
    let fixedAmount: BigUInt = 1000000000000000000 // 1 ETH
    let inputs = [TransactionInput]()
    let outputs = [TransactionOutput]()
    let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs) // split is the transaction type. You can also use null/fund/merge
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
    let tx = try Transaction(txType: .split, inputs: inputs, outputs: outputs) // split is the transaction type. You can also use null/fund/merge
    let newTx = try tx.mergeOutputs(forMaxNumber: fixedNumber)
} catch let error {
    print(error.localizedDescription)
}
```

