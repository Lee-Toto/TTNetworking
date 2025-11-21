//
//  EncryptionPlugin.swift
//  TTNetworking
//
//  Created by Lee-Toto on 2024/7/4.
//

import CryptoSwift
public struct EncryptionPlugin: PluginType {
    
    
    var appKey: String
    var appSecret: String
    
    
    public init(appKey: String, appSecret: String) {
        self.appKey = appKey
        self.appSecret = appSecret
    }
    
    public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        guard var realTarget = target as? TTTarget else { return request }
        if let netarget = realTarget as? MultiTarget {
            realTarget = netarget.target as! TTTarget
        }
        var request = request
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let method = realTarget.method.rawValue.uppercased()
        let path = realTarget.path
        
        var parameterString = ""
        if let parameters = realTarget.parameter {
            if realTarget.method == .post, realTarget.encoding is JSONEncoding {
                let data = request.httpBody ?? Data()
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                parameterString = "json=\(jsonString)"
            } else {
                let parameter = parameters.mapValues { value in
                    if let boolValue = value as? Bool {
                        return boolValue ? "1" : "0" // 将布尔值转换为 "1" 和 "0"
                    }
                    return "\(value)" // 其他类型直接转为字符串
                }.filter { !$0.value.isEmpty }
                parameterString = parameter.keys.sorted(by: <).reduce("") { $0.appending("\($1.lowercased())=\(parameter[$1] ?? "")") }
            }
        }
        
        var str = "123"
        
        // App信息
        let deviceName = UIDevice.current.name
        let sysVersion = UIDevice.current.systemVersion
        let agent = "deviceName/\(deviceName) sysVersion/\(sysVersion)"
        let userAgent = agent.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? agent
        
        
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"]
        let appInfo = ["appVersion"    :   version,
                       "appType"       :   "iOS",
                       "osVersion"     :   UIDevice.current.systemVersion]
        var headers = ["User-Agent"      :   userAgent,
                       "deviceSN" : "cIOS",
                       "device" : "cIOS",
                       "platform" : "3",]
        
        if let tmpHeader = request.allHTTPHeaderFields {
            tmpHeader.forEach { key, value in
                headers.updateValue(value, forKey: key)
            }
        }
        request.allHTTPHeaderFields = headers
        return request
    }
}
