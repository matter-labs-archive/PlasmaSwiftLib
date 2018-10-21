//
//  UTXO.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

class serviceUTXO {
    public func getListUTXOs(for publicKey: EthereumAddress, completion: @escaping(Result<ListUTXOsModel?>) -> Void) {
        let json: [String: Any] = ["for": publicKey.address,
                                   "blockNumber": 1,
                                   "transactionNumber": 0,
                                   "outputNumber": 0,
                                   "limit": 50]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        guard let request = request(data: jsonData) else {
            completion(Result.Error(MatterErrors.cantCreateRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(Result.Error(error!))
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let utxos = responseJSON["utxos"] as? [String : Any] {
                    if let listUTXOs = ListUTXOsModel(json: utxos) {
                        completion(Result.Success(listUTXOs))
                    }
                }
            }
            completion(Result.Error(MatterErrors.noData))
        }
        
        task.resume()
    }
    
    
    private func request(data: Data?) -> URLRequest? {
        let url = URLs.listUTXOsMainnet
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
    
    enum Result<T> {
        case Success(T)
        case Error(Error)
    }
}


