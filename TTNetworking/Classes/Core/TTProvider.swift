//
//  TTProvider.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/4/26.
//

import Foundation
import Alamofire
import RxRelay

protocol CapthaViewDelegate {
    func showCaptchaView( single:@escaping (Result<Any?, Swift.Error>) -> Void)
}
extension CapthaViewDelegate {
    func showCaptchaView( single:@escaping (Result<Any?, Swift.Error>) -> Void) {}
}

extension TTProvider: CapthaViewDelegate {}


public let provider = TTProvider<MultiTarget>(requestClosure: { endpoint, done in
    guard var request = try? endpoint.urlRequest() else { return }
    request.timeoutInterval = TTRequestManager.shared.requestTimeInterval
    done(.success(request))
}, plugins: TTRequestManager.shared.plugins)


struct Token {
    /// 保证单次刷新
    static let lock = NSRecursiveLock()
    /// 是否正在刷新
    static let refreshStatus = BehaviorRelay(value: false)
}


public final class TTProvider<Target: TTTarget>: MoyaProvider<Target> {
    
    let disposeBag = DisposeBag()
    
    var captcha = ""
        
    public func tokenVerify(_ target: Target, callbackQueue: DispatchQueue? = nil) -> Single<Any?> {
        guard !((TTRequestManager.shared.delegate?.token ?? "").isEmpty), let refreshTokenTarget = TTRequestManager.shared.delegate?.refreshTokenTarget else { return fetchData(target, callbackQueue: callbackQueue) }
        return Token.refreshStatus.distinctUntilChanged().filter({!$0}).first().flatMap { _ in
            return self.fetchData(target, callbackQueue: callbackQueue)
        }.flatMap { data in
            Token.lock.lock()
            defer {
                Token.lock.unlock()
            }
            let expireInterval = TTRequestManager.shared.delegate?.expireInterval ?? 0
            let timeInterval = Date().timeIntervalSince1970
            let shouldRefreshToken = timeInterval > expireInterval
            if shouldRefreshToken {
                if !Token.refreshStatus.value {
                    Token.refreshStatus.accept(true)
                    return self.fetchData(MultiTarget.target(refreshTokenTarget) as! Target).flatMap { data in
                        TTRequestManager.shared.delegate?.refreshTokenHandle(data)
                        Token.refreshStatus.accept(false)
                        return self.fetchData(target, callbackQueue: callbackQueue)
                    }
                }
                return self.tokenVerify(target, callbackQueue: callbackQueue)
            }
            return Single.just(data)
        }
    }
 
    
   public func fetchData(_ target: Target, callbackQueue: DispatchQueue? = nil) -> Single<Any?> {
       guard NetworkReachabilityManager.default?.isReachable == true else { return Single.error(TTError.noNetwork)}
       return Single.create { [weak self] single in
            let cancellableToken = self?.request(target, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    guard let jsonModel = try? JSONDecoder().decode(ResponseModel.self, from: response.data) else {
                        single(.failure(TTError.jsonError))
                        return
                    }
                    if jsonModel.code == ResponseCode.success.rawValue {
                        single(.success(jsonModel.data))
                    } else if jsonModel.code == ResponseCode.needCaptcha.rawValue {
                        self?.showCaptchaView(single: single)
                    } else if jsonModel.code == ResponseCode.unauthorized.rawValue {
                        single(.failure(TTError.unauthorized))
                    } else {
                        single(.failure(TTError.customer(jsonModel.code, jsonModel.msg, jsonModel.data)))
                    }
                    return
                case .failure(_):
                    single(.failure(TTError.serverError))
                    return
                }
            }

            return Disposables.create {
                cancellableToken?.cancel()
            }
       }
    }

    public func handleError(_ target: Target, callbackQueue: DispatchQueue? = nil) -> Single<Any?> {
        var service: Single<Any?>!
        if TTRequestManager.shared.enableTokenRefresh {
            service = tokenVerify(target, callbackQueue: callbackQueue)
        }else {
            service = fetchData(target, callbackQueue: callbackQueue)
        }
        return service.retry(when: { error in
            return error.flatMap { error in
                guard let error = error as? TTError, error == .needCaptcha else { return Single<Any>.error(error)}
                return Single.just(error)
            }
        }).do(onSuccess: {[weak self] _ in
            self?.captcha = ""
        }, onError: {[weak self] error in
            self?.captcha = ""
            guard let error = error as? TTError,let multiTarget = target as? MultiTarget, let target = multiTarget.target as? TTTarget else { return }
            TTRequestManager.shared.delegate?.errorHandle(target, error: error)
        })

    }
    
}
