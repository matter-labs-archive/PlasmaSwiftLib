//
//  ViewController.swift
//  PlasmaSwiftLibExample
//
//  Created by Anton Grigorev on 25.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import UIKit
import PlasmaSwiftLib
import EthereumAddress

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var utxos: [ListUTXOsModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getUTXOs()
    }

    func getUTXOs() {
        guard let address = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4") else {return}
        ServiceUTXO().getListUTXOs(for: address, onTestnet: true) { (result) in
            switch result {
            case .Success(let utxos):
                DispatchQueue.main.async { [weak self] in
                    self?.utxos = utxos
                    self?.tableView.reloadData()
                }
            case .Error(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let alert = self?.alert(title: "Cant load UTXOs", message: "Error: \(error.localizedDescription). Please, contact antongrigorjev2010@gmail.com") else {return}
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func sendToMyself(from utxo: ListUTXOsModel) {
        guard let address = EthereumAddress("0x6891dc3962e710f0ff711b9c6acc26133fd35cb4") else {return}
        let privKey = Data(hex: "36775b4bafc4d906c9035903785fcdb4f0e9e7b5d6f6f1a4b001bb5a4396c391")
        guard let input = utxo.toTransactionInput() else {return}
        let inputs = [input]
        guard let output = TransactionOutput(outputNumberInTx: 0, receiverEthereumAddress: address, amount: input.amount) else {return}
        let outputs = [output]
        guard let transaction = Transaction(txType: .split, inputs: inputs, outputs: outputs) else {return}
        guard let signedTransaction = transaction.sign(privateKey: privKey) else {return}
        ServiceUTXO().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
            switch result {
            case .Success:
                DispatchQueue.main.async { [weak self] in
                    guard let alert = self?.alert(title: "Successfully sent transaction", message: nil) else {return}
                    self?.present(alert, animated: true, completion: nil)
                }
            case .Error(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let alert = self?.alert(title: "Cant load UTXOs", message: "Error: \(error.localizedDescription). Please, contact antongrigorjev2010@gmail.com") else {return}
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func alert(title: String, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        return alert
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return utxos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "UTXO")
        cell.textLabel?.text = String(utxos[indexPath.row].value)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sendToMyself(from: utxos[indexPath.row])
    }

}
