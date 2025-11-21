//
//  CaptchaModel.swift
//  common-captcha_Example
//
//  Created by Lee-Toto on 2024/5/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

private var captchaDelegateAssociateKey: UInt8 = 0
public extension TTRequestManager {
    weak var captchaDelegate: CaptchaViewProtocol? {
        set { objc_setAssociatedObject(self, &captchaDelegateAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { objc_getAssociatedObject(self, &captchaDelegateAssociateKey) as? CaptchaViewProtocol}
    }
}

struct CaptchaModel: Codable {
    
    var originalImageBase64: String = ""
    var jigsawImageBase64: String = ""
    var token: String = ""
    var secretKey: String = ""
    var result: Bool = false
    
}
