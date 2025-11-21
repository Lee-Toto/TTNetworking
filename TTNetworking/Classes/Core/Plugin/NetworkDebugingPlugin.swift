//
//  NetworkDebugingPlugin.swift
//  BaicTruck
//
//  Created by LeeToto on 2023/1/16.
//

import Foundation
import Moya
import Alamofire

/// 网络打印，DEBUG模式内置插件
public final class NetworkDebugingPlugin {
    
    public var openDebugRequest: Bool = true
    public var openDebugResponse: Bool = true
    
    public init() { }
    
    public init(debugRequest: Bool = true, debugResponse: Bool = true) {
        self.openDebugRequest = debugRequest
        self.openDebugResponse = debugResponse
    }
}

extension NetworkDebugingPlugin: PluginType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        printRequest(target)
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        ansysisResult(target, result)
        #endif
    }
}

extension NetworkDebugingPlugin {
    
    private func printRequest(_ target: TargetType) {
        guard openDebugRequest else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "zh_CN")
        let date = formatter.string(from: Date())
        var parameters: Parameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        if let param = parameters, param.isEmpty == false {
            print("""
                  Path: \(target.path)\n
                  ═══════════ 🎈 Request 🎈 ═══════════
                   Time: \(date)
                   URL: {{\(requestFullLink(with: target))}}
                  ═══════════════════════════════════════
                  \n
                  """)
        } else {
            print("""
                  Path: \(target.path)\n
                  ═══════════ 🎈 Request 🎈 ═══════════
                   Time: \(date) \(requestFullLink(with: target))
                   URL: {{\(requestFullLink(with: target))}}
                  ═══════════════════════════════════════
                  \n
                  """)
        }
    }
    
    private func requestFullLink(with target: TargetType) -> String {
        var parameters: Parameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        guard let parameters = parameters, !parameters.isEmpty else {
            return target.baseURL.absoluteString + target.path
        }
        let sortedParameters = parameters.sorted(by: { $0.key > $1.key })
        var paramString = "?"
        for index in sortedParameters.indices {
            paramString.append("\(sortedParameters[index].key)=\(sortedParameters[index].value)")
            if index != sortedParameters.count - 1 { paramString.append("&") }
        }
        return target.baseURL.absoluteString + target.path + "\(paramString)"
    }
}

extension NetworkDebugingPlugin {
    
    private func ansysisResult(_ target: TargetType, _ result: Result<Moya.Response, MoyaError>) {
        switch result {
        case let .success(response):
            do {
                let response = try response.filterSuccessfulStatusCodes()
                let json = try response.mapJSON()
                if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        printResponse(target, jsonString, true)
                } else {
                    print("Failed to convert JSON object to string.")    
                }
            } catch MoyaError.jsonMapping(let response) {
                let error = MoyaError.jsonMapping(response)
                printResponse(target, error.localizedDescription, false)
            } catch MoyaError.statusCode(let response) {
                let error = MoyaError.statusCode(response)
                printResponse(target, error.localizedDescription, false)
            } catch {
                printResponse(target, error.localizedDescription, false)
            }
        case let .failure(error):
            printResponse(target, error.localizedDescription, false)
        }
    }
    
    private func printResponse(_ target: TargetType, _ json: Any, _ success: Bool) {
        guard openDebugResponse else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "zh_CN")
        let date = formatter.string(from: Date())
        var parameters: Parameters? = nil
        if case .requestParameters(let parame, _) = target.task {
            parameters = parame
        }
        if let param = parameters, param.isEmpty == false {
            print("""
            Path: \(target.path)\n
            ═══════════ 🎈 Request 🎈 ═══════════
            Time: \(date)
            URL: {{\(requestFullLink(with: target))}}
            -------------------------------------
            Method: \(target.method.rawValue)
            Host: \(target.baseURL.absoluteString)
            Path: \(target.path)
            Parameters: \(param)
            ---------- 🎈 Response 🎈 ----------
            Result: \(success ? "Successed." : "Failed.")
            Response: \(json)
            ═══════════════════════════════════════
            \n
            """)
        } else {
            print("""
            Path: \(target.path)\n
            ═══════════ 🎈 Request 🎈 ═══════════
            Time: \(date)
            URL: {{\(requestFullLink(with: target))}}
            -------------------------------------
            Method: \(target.method.rawValue)
            Host: \(target.baseURL.absoluteString)
            Path: \(target.path)
            ---------- 🎈 Response 🎈 ----------
            Result: \(success ? "Successed." : "Failed.")
            Response: \(json)
            ═══════════════════════════════════════
            \n
            """)
        }
    }
}

