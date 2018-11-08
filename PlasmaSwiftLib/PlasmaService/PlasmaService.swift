//
//  UTXO.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Plasma. All rights reserved.
//

import Foundation
import EthereumAddress

public final class PlasmaService {

    public init() {}

    public func getUTXOs(for address: EthereumAddress, onTestnet: Bool = false, completion: @escaping(Result<[PlasmaUTXOs]>) -> Void) {
        let json: [String: Any] = ["for": address.address,
                                   "blockNumber": 1,
                                   "transactionNumber": 0,
                                   "outputNumber": 0,
                                   "limit": 50]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        guard let request = request(url: onTestnet ? PlasmaURLs.listUTXOsTestnet : PlasmaURLs.listUTXOsMainnet,
                                    data: jsonData) else {
            completion(Result.Error(PlasmaErrors.cantCreateRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(Result.Error(error!))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(Result.Error(PlasmaErrors.badResponse))
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(Result.Error(PlasmaErrors.badResponse))
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let utxos = responseJSON["utxos"] as? [[String: Any]] {
                    var allUTXOs = [PlasmaUTXOs]()
                    for utxo in utxos {
                        if let model = PlasmaUTXOs(json: utxo) {
                            allUTXOs.append(model)
                        }
                    }
                    completion(Result.Success(allUTXOs))
                } else {
                    completion(Result.Error(PlasmaErrors.errorInUTXOs))
                }
            } else {
                completion(Result.Error(PlasmaErrors.noData))
            }
        }

        task.resume()
    }

    public func sendRawTX(transaction: SignedTransaction, onTestnet: Bool = false, completion: @escaping(Result<Bool?>) -> Void) {
        let transactionString = transaction.data.toHexString().addHexPrefix()
        let json: [String: Any] = ["tx": transactionString]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        guard let request = request(url: onTestnet ? PlasmaURLs.sendRawTXTestnet : PlasmaURLs.sendRawTXMainnet,
                                    data: jsonData) else {
            completion(Result.Error(PlasmaErrors.cantCreateRequest))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(Result.Error(error!))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(Result.Error(PlasmaErrors.badResponse))
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(Result.Error(PlasmaErrors.badResponse))
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let accepted = responseJSON["accepted"] as? Bool {
                    completion(Result.Success(accepted))
                } else if let reason = responseJSON["reason"] as? String {
                    print(reason)
                    completion(Result.Success(false))
                }

            } else {
                completion(Result.Error(PlasmaErrors.noData))
            }
        }

        task.resume()
    }

    private func request(url: URL, data: Data?) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        return request
    }

    public enum Result<T> {
        case Success(T)
        case Error(Error)
    }

}
