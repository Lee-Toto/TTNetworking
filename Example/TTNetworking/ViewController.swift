//
//  ViewController.swift
//  TTNetworking
//
//  Created by Lee-Toto on 11/21/2025.
//  Copyright (c) 2025 Lee-Toto. All rights reserved.
//

import UIKit
@_exported import SmartCodable
@_exported import TTNetworking
@_exported import RxSwift
@_exported import NSObject_Rx

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DemoService.getDefaultCodeDemo("").request.subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
        
        DemoService.getJSONEncodingDemo("").request.mapObject(DemoSmartCodableModel.self).subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
        
        DemoService.postNoParam.request.mapPageList(DemoSmartCodableModel.self).subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
        
        DemoService.postDefaultCodeDemo("").request.mapString().subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
        
        DemoService.postURLEncodingDemo("").request.mapStringList().subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
        
        DemoService.getNoParam.request.mapList(DemoSmartCodableModel.self).subscribe(onSuccess: { [weak self] (model) in
            guard let self = self else { return }
            
        }, onFailure: { (error) in
            
        }).disposed(by: rx.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

