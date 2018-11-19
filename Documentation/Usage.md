# Usage

<***> - input object

Plasma is working on Mainnet and Rinkeby testnet. In some methods use *bool flag to set network* you want to use. 

## UTXO

#### UTXO structure

- blockNumber: BigUInt
- transactionNumber: BigUInt
- outputNumber: BigUInt
- value: BigUInt

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

*Transaction types:*
- split - use to send funds
- merge - use to merge UTXOs
- fund
- null

*When sending funds:*
- 2 outputs:
    - TransactionOutput(outputNumberInTx: 0,
                        receiverEthereumAddress: 'destination address',
			amount: 'sending amount')
    - TransactionOutput(outputNumberInTx: 1,
                        receiverEthereumAddress: 'current address',
			amount: 'stay amount')
- 1 input:
    - form inputs array from 1 UTXO using toTransactionInput():
    ```swift
    	let input = try utxo.toTransactionInput()
    ```
    
*When merging UTXOs:*
- 2 inputs:
    - form input array from 2 UTXOs using toTransactionInput():
    ```swift
    	var inputs = [TransactionInput]()
        var mergedAmount: BigUInt = 0
        for utxo in chosenUTXOs {
            if let input = utxo.utxo.toTransactionInput() {
                inputs.append(input)
                mergedAmount += input.amount
            }
        }
    ```
- 1 output:
    - TransactionOutput(outputNumberInTx: 0,
                        receiverEthereumAddress: 'current address',
			amount: 'merged amount')

*Example:*
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

There are 3 preset Plasma Contract methods you can use in this lib:
- deposit
- WithdrawCollateral
- startExit

`WithdrawCollateral` and `startExit` are used in one action - withdraw funds from Plasma UTXO. We've build the convenient method withdrawUTXO(utxo: `PlasmaUTXOs`,
                    onTestnet: `Bool`,
                    password: `String? = nil`) for it.

You can also use any other Plasma Contract method by learning its ABI.

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

