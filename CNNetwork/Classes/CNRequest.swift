//
//  CNRequest.swift
//  lecturer
//
//  Created by 邓锋 on 2018/4/26.
//  Copyright © 2018年 xiangzhen. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

public enum CNResponse<T > {
    case success(value:T)
    case failure(error:NSError)
}

open class CNRequest<T:Codable> : CNRequestBase,ObservableType{
    public func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, CNRequest.E == O.E {
        return self.publish().asObservable().subscribe(observer)
    }
    
    public func subscribe(success:@escaping (T)->Void,failure:@escaping (Error)->Void)->Disposable{
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

    public typealias E = CNResponse<T>
    
    

    public var hasNext = false //只有T 符合翻页时有效
    
    private var publish = ReplaySubject<CNResponse<T>>.create(bufferSize: 1)
    

    //override
    
    override open func didReceiveData(responseData: Data) {
        super.didReceiveData(responseData: responseData)
        //self.publish.aa()
        do {
            let decoder = JSONDecoder()
            let obj = try decoder.decode(T.self, from: responseData)
            if let obj = obj as? Nextable{
                self.hasNext = obj.hasNext
            }
            self.publish.onNext(CNResponse.success(value: obj))
        } catch  {
            self.hasNext = true
            self.publish.onNext(CNResponse.failure(error: error as NSError))
        }
    }
    override open func receiveError(error: NSError) {
        self.hasNext = true
        self.publish.onNext(CNResponse.failure(error: error as NSError))
    }
}

//翻页协议
public protocol Nextable {
   var hasNext : Bool{get}
}
public protocol Datable {
    associatedtype E
    var datas : [E] {get}
}

public typealias Pageble = Nextable & Datable & Codable
//给数组默认实现翻页协议
extension Array : Pageble {
    public typealias E = Element
    public var datas: [Element] {
        return self
    }
    public var hasNext: Bool {
        return self.count > 0
    }
}
//当API需要翻页的时候 实现下列接口
private var pageKey = "pageKey"
private var sizeKey = "sizeKey"
public extension CNRequest where T : Pageble{
    //页数
    public var page : Int{
        get{
            return (objc_getAssociatedObject(self, &pageKey) as? Int) ?? 1
        }
        set{
            self.defaultParameters["page"] = self.page
            objc_setAssociatedObject(self, &pageKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    //每页的大小
    public var size : Int{
        get{
            return (objc_getAssociatedObject(self, &sizeKey) as? Int) ?? 20
        }
        set{
            self.defaultParameters["size"] = self.size
            objc_setAssociatedObject(self, &sizeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
  
    public func fetchFirst() {
        self.hasNext = false
        self.page = 1
        self.fetch()
    }
    
    public func fetchNext() {
        if !self.hasNext{return}
        self.hasNext = false
        self.page = self.page + 1
        self.fetch()
    }

}
