//
//  CustomError.swift
//  TTNetworking_Example
//
//  Created by LeeToto on 2024/8/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import TTNetworking

public enum CustomError: Error, Equatable {
    case ttError(TTError)
    case abnormalLogin
    case phoneHasBind                           // 手机号已绑定
    case WechatNotBind                          // 未绑定微信号
    case WechatNotSame                          // 校验失败，绑定微信不一致
    
    public var code: Int {
        switch self {
        case .ttError(let error):
            return error.code
        case .abnormalLogin:
            /// 异常登录
            return 100116
        case .phoneHasBind:
            /// 手机号已绑定
            return 100205
        case .WechatNotBind:
            // 未绑定微信号
            return 100208
        case .WechatNotSame:
            // 校验失败，绑定微信不一致
            return 100209
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.code == rhs.code
    }
}

extension CustomError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .ttError(let error):
            return error.debugDescription
        default:
            return ""
        }
    }
}
