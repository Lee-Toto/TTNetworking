//
//  TTRequestManager.swift
//  TTNetworking_Example
//
//  Created by Lee-Toto on 2024/4/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

public protocol TTRequestManagerDelegate: NSObjectProtocol {
    
    var baseUrl: String { get }
    
    var token: String { get }
    
    var header: [String: String] { get }
    
    var refreshTokenTarget: TTTarget? { get }
    
    var expireInterval: TimeInterval { get }
        
    func errorHandle(_ target: TTTarget,error: TTError)
    
    func captchaSuccessHandle()

    func refreshTokenHandle(_ data: Any?)
}

public class TTRequestManager {
        
    public var pageSize: Int = 10
        
    public var requestTimeInterval: TimeInterval = 60
            
    public var plugins: [PluginType] = []
    
    public var enableTokenRefresh = false
        
    public weak var delegate: TTRequestManagerDelegate?
       
}

public extension TTRequestManager {
    
    static let shared = TTRequestManager()
}
