//
//  AlamofireJsonRequester.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation
import RxSwift
import Alamofire

class AlamofireJsonRequester: JsonRequestable {
    var queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }

    func request(url: URL) -> Single<Any> {
        return Single.create { [queue] single -> Disposable in
            AF.request(url)
                .validate(statusCode: 200 ..< 400)
                .responseJSON(queue: queue) { response in
                    switch response.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        single(.error(error))
                    }
                }
            
            return Disposables.create()
        }
    }
}

class AlamofireDownloadRequester: DownloadRequestable {
    var queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    func download(url: URL) -> Single<Data> {
        return Single.create { [queue] single -> Disposable in
            let download = AF.download(url)
                .validate(statusCode: 200 ..< 400)
                .responseData(queue: queue) { response in
                switch response.result {
                case .success(let data):
                    single(.success(data))
                case .failure(let error):
                    single(.error(error))
                }
            }
            
            return Disposables.create {
                download.cancel()
            }
        }
    }
}
