//
//  TTError.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/4/26.
//

import Foundation

public enum ResponseCode: Int {
    case success = 200
    case unauthorized = 401
    case serverError = 500
    case needCaptcha = 100704
}

public enum TTError: Error ,Equatable{
    case jsonError
    case noNetwork
    case unauthorized
    case serverError
    case needCaptcha
    case refreshToken
    case customer(Int, String, Any?)
    
    public var code: Int {
        switch self {
        case .jsonError:
            return -1
        case .customer(let responseCode, _, _):
            return responseCode
        case .noNetwork:
            return -2
        case .serverError:
            return ResponseCode.serverError.rawValue
        case .needCaptcha:
            return ResponseCode.needCaptcha.rawValue
        case .unauthorized:
            return ResponseCode.unauthorized.rawValue
        case .refreshToken:
            return -3
        }
    }
    
    public var msg: String {
        switch self {
        case .customer(_, let msg, _):
            return msg
        default:
            return "网络不给力，请稍后重试"
        }
    }
    
    public var responseObj: Any? {
        switch self {
        case .customer(_, _, let responseObj):
            return responseObj
        default:
            return nil
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.code == rhs.code
    }
    
}

extension TTError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .jsonError:
            return "server error"
        case .customer( let code, let msg, _):
            return "code: \(code)，msg: \(msg)"
        case .noNetwork:
            return "please check your network"
        default:
            return ""
        }
    }
}
