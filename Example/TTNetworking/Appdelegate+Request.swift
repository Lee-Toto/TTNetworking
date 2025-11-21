//
//  Appdelegate+Request.swift
//  TTNetworking_Example
//
//  Created by LeeToto on 2025/11/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import TTNetworking

extension AppDelegate {
    
    func configNetworking() {
        TTRequestManager.shared.plugins.append(contentsOf: plugins())
        TTRequestManager.shared.delegate = self
    }
    
    func plugins() -> [PluginType] {
        var pluginArray = [PluginType]()
        let loadingPlugin = NetworkActivityPlugin { change, target in
            guard change == .ended else { return }
            if let customTarget = target as? LoadingPolicyProvider {
                switch customTarget.loadingPolicy {
                case .autoHide(let shouildHide):
                    if shouildHide {
                        /*  hideLoading */
                    }
                case .manualControl:
                    break
                }
            } else {
                /*  hideLoading */
            }
        }
        let accessPlugin = AccessTokenPlugin(tokenClosure: { [weak self] target in
            guard let self = self, let target = target as? TTTarget else { return ""}
            let basicStr = "authKey:authSecert"
            let data = basicStr.data(using: .utf8)
            let baseStr = data!.base64EncodedString()
            return target.authorizationType == .basic ? baseStr : token
        })
        
        let encryptionPlugin = EncryptionPlugin.init(appKey: "123", appSecret: "12345")
        
        pluginArray.append(loadingPlugin)
        pluginArray.append(accessPlugin)
        pluginArray.append(encryptionPlugin)
        pluginArray.append(NetworkDebugingPlugin())
        return pluginArray
    }
}

extension AppDelegate: TTRequestManagerDelegate {
    
    var expireInterval: TimeInterval {
        /* 返回token的过期时间 */
        123
    }
    
    var refreshTokenTarget: (any TTNetworking.TTTarget)? {
        /* 返回刷新token的target */
        DemoService.refreshToken("token")
    }
    
    func refreshTokenHandle(_ data: Any?) {
        /* 刷新token后更新本地的token */
    }
    
    func captchaSuccessHandle() {
        /* showLoading */
    }
    
    func captchaCancelHandle() {
        /* hideLoading */
    }
    
    var baseUrl: String {
        "host"
    }
    
    var token: String {
        "token"
    }
    
    var header: [String : String] {
        [:]
    }
    
    func errorHandle(_ target: any TTNetworking.TTTarget, error: TTNetworking.TTError) {
        switch error {
        case let .customer(code, msg, _):
            if code == CustomError.abnormalLogin.code || code == CustomError.WechatNotBind.code || code == CustomError.WechatNotSame.code {
                return
            }
            if !msg.isEmpty {
                print(msg)
            }
        case .noNetwork:
            print("网络异常，请检查网络")
        case .unauthorized:
            print("您当前还未登录，请登录后再进行操作！")
        default:
            /// 服务异常
            break
        }
        
        
    }
}
