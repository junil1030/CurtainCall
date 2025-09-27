//
//  CustomObservable.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import RxSwift
import Parsely

final class CustomObservable {
    
    static func request<T: ParselyType>(_ apiRouter: APIRouter, responseType: T.Type) -> Single<T> {
        
        return Single.create { single in
            
            Task {
                do {
                    let result = try await NetworkManager.shared.request(apiRouter, responseType: responseType)
                    
                    await MainActor.run {
                        single(.success(result))
                    }
                } catch let error as NetworkError {
                    await MainActor.run {
                        single(.failure(error))
                    }
                } catch {
                    await MainActor.run {
                        single(.failure(NetworkError.unknown(error)))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
