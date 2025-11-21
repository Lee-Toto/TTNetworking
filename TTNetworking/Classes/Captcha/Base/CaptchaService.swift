//
//  CaptchaRequest.swift
//  captcha_swift
//
//  Created by kean_qi on 2020/4/30.
//  Copyright © 2020 kean_qi. All rights reserved.
//

import UIKit
import RxSwift

enum CaptchaService {
    case getCaptcha(_ type: CaptchaType)
    case checkCaptcha(_ type: CaptchaType, pointJson: String, token: String)
}

extension CaptchaService: TTTarget {
    
    var requestPath: TTPath {
        switch self {
        case .getCaptcha:
            return .post("/app-user/exterior/aj-captcha/get")
        case .checkCaptcha:
            return .post("/app-user/exterior/aj-captcha/check")
        }
    }
    
    var parameter: [String : Any]? {
        switch self {
        case .getCaptcha(let type):
            return ["captchaType":type.rawValue,
                    "distinguishSignatureVerificationMethod":"ios"]
        case let .checkCaptcha(type,pointJson,token):
            return ["pointJson": pointJson,
                    "captchaType": type.rawValue,
                    "token":token,
                    "distinguishSignatureVerificationMethod":"ios"]
        }
    }
    
    var request: Single<Any> {
        provider.fetchData(.target(self)).compactMap({$0}).asObservable().asSingle()
    }
}





