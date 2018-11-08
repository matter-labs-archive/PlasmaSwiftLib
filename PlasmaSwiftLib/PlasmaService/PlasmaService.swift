//
//  UTXO.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Plasma. All rights reserved.
//

import Foundation
import EthereumAddress
import BigInt

public final class PlasmaService {

    public init() {}
    
    var session: URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig,
                                 delegate: nil,
                                 delegateQueue: nil)
        return session
    }

    public func getUTXOs(for address: EthereumAddress,
                         onTestnet: Bool = false,
                         completion: @escaping(Result<[PlasmaUTXOs]>) -> Void) {
        let json: [String: Any] = ["for": address.address,
                                   "blockNumber": 1,
                                   "transactionNumber": 0,
                                   "outputNumber": 0,
                                   "limit": 50]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = onTestnet ? PlasmaURLs.listUTXOsTestnet : PlasmaURLs.listUTXOsMainnet
        guard let request = request(url: url,
                                    data: jsonData,
                                    method: .post,
                                    contentType: .json) else {
            completion(Result.Error(PlasmaErrors.cantCreateRequest))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
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
    
    public func getBlock(onTestnet: Bool = false,
                         number: BigUInt,
                         completion: @escaping(Result<String>) -> Void) {
        let url = onTestnet ? PlasmaURLs.listUTXOsTestnet : PlasmaURLs.blockStorageMainnet
        guard let request = request(url: url,
                                    data: Data(),
                                    method: .get,
                                    contentType: .octet) else {
                                        completion(Result.Error(PlasmaErrors.cantCreateRequest))
                                        return
        }
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                guard let block = self.readBlock(number: number, from: tempLocalUrl) else {
                    completion(Result.Error(PlasmaErrors.noData))
                    return
                }
                completion(Result.Success(block))
            } else {
                completion(Result.Error(PlasmaErrors.badResponse))
            }
        }
        task.resume()
    }
    
    private func readBlock(number: BigUInt,
                          from url: URL) -> String? {
        do {
            let block = try String(contentsOf: url, encoding: .utf8)
            return block
        } catch {
            return nil
        }
    }

    public func sendRawTX(transaction: SignedTransaction,
                          onTestnet: Bool = false,
                          completion: @escaping(Result<Bool?>) -> Void) {
        let transactionString = transaction.data.toHexString().addHexPrefix()
        let json: [String: Any] = ["tx": transactionString]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = onTestnet ? PlasmaURLs.sendRawTXTestnet : PlasmaURLs.sendRawTXMainnet
        guard let request = request(url: url,
                                    data: jsonData,
                                    method: .post,
                                    contentType: .json) else {
            completion(Result.Error(PlasmaErrors.cantCreateRequest))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
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

    private func request(url: URL,
                         data: Data?,
                         method: Method,
                         contentType: ContentType) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.httpMethod = method.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        return request
    }

}

public enum Result<T> {
    case Success(T)
    case Error(Error)
}

public enum Method: String {
    case post = "POST"
    case get = "GET"
}

public enum ContentType: String {
    case json = "application/json"
    case octet = "application/octet-stream"
}
