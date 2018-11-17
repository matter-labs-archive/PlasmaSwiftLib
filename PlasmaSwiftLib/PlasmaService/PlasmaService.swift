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
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

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
                         onTestnet: Bool = false) throws -> [PlasmaUTXOs] {
        return try self.getUTXOsPromise(for: address, onTestnet: onTestnet).wait()
    }

    public func getUTXOsPromise(for address: EthereumAddress,
                                onTestnet: Bool = false) -> Promise<[PlasmaUTXOs]> {
        let returnPromise = Promise<[PlasmaUTXOs]> { (seal) in
            var allUTXOs = [PlasmaUTXOs]()
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
                seal.reject(NetErrors.cantCreateRequest)
                return
            }
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data, error == nil else {
                    seal.reject(NetErrors.noData)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    seal.reject(NetErrors.badResponse)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    seal.reject(NetErrors.badResponse)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let utxos = responseJSON["utxos"] as? [[String: Any]] {
                        for utxo in utxos {
                            do {
                                if let model = try? PlasmaUTXOs(json: utxo) {
                                    allUTXOs.append(model)
                                }
                            }
                        }
                        seal.fulfill(allUTXOs)
                    } else {
                        seal.reject(StructureErrors.cantDecodeData)
                    }
                } else {
                    seal.reject(StructureErrors.cantDecodeData)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func getBlock(onTestnet: Bool = false,
                         number: BigUInt) throws -> Data {
        return try getBlockPromise(onTestnet: onTestnet, number: number).wait()
    }
    
    public func getBlockPromise(onTestnet: Bool = false,
                                number: BigUInt) -> Promise<Data> {
        let returnPromise = Promise<Data> { (seal) in
            var url = onTestnet ? PlasmaURLs.blockStorageTestnet : PlasmaURLs.blockStorageMainnet
            let num = String(number)
            url += num
            guard let request = request(url: URL(string: url)!,
                                        data: Data(),
                                        method: .get,
                                        contentType: .octet) else {
                seal.reject(NetErrors.cantCreateRequest)
                return
            }
            session.dataTask(with: request, completionHandler: { (data, _, error) in
                guard error == nil, let block = data else {
                    seal.reject(NetErrors.noData)
                    return
                }
                seal.fulfill(block)
            }).resume()
        }
        return returnPromise
    }
    
    public func sendRawTXPromise(transaction: SignedTransaction,
                                 onTestnet: Bool = false) -> Promise<Bool> {
        let returnPromise = Promise<Bool> { (seal) in
            let transactionString = transaction.data.toHexString().addHexPrefix()
            let json: [String: Any] = ["tx": transactionString]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            let url = onTestnet ? PlasmaURLs.sendRawTXTestnet : PlasmaURLs.sendRawTXMainnet
            guard let request = request(url: url,
                                        data: jsonData,
                                        method: .post,
                                        contentType: .json) else {
                                            seal.reject(NetErrors.cantCreateRequest)
                                            return
            }
            
            session.dataTask(with: request, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    seal.reject(NetErrors.noData)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    seal.reject(NetErrors.badResponse)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    seal.reject(NetErrors.badResponse)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let accepted = responseJSON["accepted"] as? Bool {
                        seal.fulfill(accepted)
                    } else if let reason = responseJSON["reason"] as? String {
                        print(reason)
                        seal.fulfill(false)
                    }
                } else {
                    seal.reject(StructureErrors.cantDecodeData)
                }
            }).resume()
        }
        return returnPromise
    }

    public func sendRawTX(transaction: SignedTransaction,
                          onTestnet: Bool = false) throws -> Bool {
        return try sendRawTXPromise(transaction: transaction, onTestnet: onTestnet).wait()
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

public enum Method: String {
    case post = "POST"
    case get = "GET"
}

public enum ContentType: String {
    case json = "application/json"
    case octet = "application/octet-stream"
}
