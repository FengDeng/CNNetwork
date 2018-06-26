//
//  CNRequestData.swift
//  CNRequestDemo
//
//  Created by 邓锋 on 2018/6/26.
//  Copyright © 2018年 xiangzhen. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

open class CNRequestData : CNRequestBase,ObservableType{
    public func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, CNRequestData.E == O.E {
        return self.publish().asObservable().subscribe(observer)
    }
    
    public typealias E = CNResponse<Data>
    

    
    public func subscribe(success:@escaping (Data)->Void,failure:@escaping (Error)->Void)->Disposable{
        return self.observeOn(MainScheduler.instance).subscribe(onNext: { (response) in
            switch response{
            case .success(value: let value):
                success(value)
                break
            case .failure(error: let e):
                failure(e)
                break
            }
        })
    }

    
    
    
    public var hasNext = false //只有T 符合翻页时有效
    
    private var publish = ReplaySubject<CNResponse<Data>>.create(bufferSize: 1)
    
    
    //override
    
    override open func didReceiveData(responseData: Data) {
        super.didReceiveData(responseData: responseData)
        self.publish.onNext(CNResponse<Data>.success(value: responseData))
    }
    override open func receiveError(error: NSError) {
        self.hasNext = true
        self.publish.onNext(CNResponse.failure(error: error as NSError))
    }
}
