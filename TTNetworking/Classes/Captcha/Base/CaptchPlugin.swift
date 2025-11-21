//
//  File.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/8/9.
//

import Moya


public struct CaptchPlugin: PluginType {
    
    public init() {}
    
    public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
       var request = request
        if request.method == .post && !provider.captcha.isEmpty, let body = request.httpBody {
            do {
                var parameter = try JSONSerialization.jsonObject(with: body) as? [String: Any]
                parameter?["captchaVerification"] = provider.captcha
                let data = try JSONSerialization.data(withJSONObject: parameter ?? [])
                request.httpBody = data
            } catch {}
        }
        return request
    }
}

extension TTProvider {
    func showCaptchaView(single: @escaping (Result<Any?, any Error>) -> Void) {
        CaptchaView.show { [weak self] captcha in
            guard !captcha.isEmpty  else { return single(.failure(TTError.customer(-2, "", nil))) }
            self?.captcha = captcha
            single(.failure(TTError.needCaptcha))
        }
    }
}
