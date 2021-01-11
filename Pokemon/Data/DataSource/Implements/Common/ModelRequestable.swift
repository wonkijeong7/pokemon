//
//  ModelRequestable.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift

protocol ModelRequestable {
    var jsonRequester: JsonRequestable { get }
    
    func request<ResponseModel: Decodable>(url: URL, responseType: ResponseModel.Type) -> Single<ResponseModel>
}

extension ModelRequestable {
    func request<ResponseModel: Decodable>(url: URL, responseType: ResponseModel.Type) -> Single<ResponseModel> {
        return jsonRequester.request(url: url)
            .map {
                let serialized = try JSONSerialization.data(withJSONObject: $0, options: [])
                
                return try JSONDecoder().decode(ResponseModel.self, from: serialized)
            }
    }
}
