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

public enum CNResponse<T> {
    case success(value:T)
    case failure(error:NSError)
}

open class CNRequestObject<T:Codable> : CNRequestBase{
    
    private var publish = PublishSubject<CNResponse<T>>.init()
    
    open func subscribe(success:@escaping (T)->Void,failure:@escaping (Error)->Void)->Disposable{
        return self.publish.subscribe(onNext: { (response) in
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
    
    //override
    override open func didReceiveData(responseData: Data) {
        super.didReceiveData(responseData: responseData)
        do {
            let decoder = JSONDecoder()
            let obj = try decoder.decode(T.self, from: responseData)
            self.publish.onNext(CNResponse.success(value: obj))
        } catch  {
            self.publish.onNext(CNResponse.failure(error: error as NSError))
        }
    }
    override open func receiveError(error: NSError) {
        self.publish.onNext(CNResponse.failure(error: error as NSError))
    }
}

open class CNRequestArray<T:Codable> : CNRequestBase{
    
    open var page = 1 //翻页的page 和 size
    open var size = 20 //此参数无效 目前服务器想返回几条 就返回几条，直接根据返回结果是不是0来判断hasNext
    open var hasNext = false //是否有下一页 如果正在请求中 该参数也为false
    
    private var publish = PublishSubject<CNResponse<[T]>>.init()
    
    open func subscribe(success:@escaping ([T])->Void,failure:@escaping (Error)->Void)->Disposable{
        return self.publish.subscribe(onNext: { (response) in
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
    
    open func fetchFirst(){
        self.hasNext = false
        self.page = 1
        self.fetch()
    }
    
    open func fetchNext(){
        if !self.hasNext{return}
        self.hasNext = false //
        self.page = self.page + 1
        self.fetch()
    }
    
    //override
    
    open override func shouldSend() -> Bool {
        self.parameters["page"] = self.page
        return true
    }
    
    open override func didReceiveData(responseData: Data) {
        super.didReceiveData(responseData: responseData)
        do {
            let decoder = JSONDecoder()
            let obj = try decoder.decode([T].self, from: responseData)
            if obj.count != 0{
                //结束不为0  说明有下一页
                self.hasNext = true
            }
            self.publish.onNext(CNResponse.success(value: obj))
        } catch  {
            self.hasNext = true
            self.publish.onNext(CNResponse.failure(error: error as NSError))
        }
    }
    open override func receiveError(error: NSError) {
        self.hasNext = true
        self.publish.onNext(CNResponse.failure(error: error as NSError))
    }
}

