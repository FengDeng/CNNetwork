//
//  CNNetworkManager.swift
//  lecturer
//
//  Created by 邓锋 on 2018/4/26.
//  Copyright © 2018年 xiangzhen. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public class CNNetworkManager{
    
    //handle request
    
    //request
    public var requestShouldSend:((_ request:CNRequestBase)->Bool)?
    public var requestWillSend:((_ request:CNRequestBase)->Void)?
    public var requestDidSend:((_ request:CNRequestBase)->Void)?
    
    //error    如果实现了该方法，并且返回了error 则直接解析成错误
    public var requestHandleToError:((_ request:CNRequestBase,_ response:DataResponse<Data>)->NSError?)?
    public var requestReceiveError:((_ request:CNRequestBase,_ error:NSError)->Bool)?//return true 拦截掉错误，request将收不到
    
    //data
    public var requestShouldReceiveData:((_ request:CNRequestBase,_ responseData:Data)->Bool)?
    public var requestWillReceiveData:((_ request:CNRequestBase,_ responseData:Data)->Void)?
    public var requestDidReceiveData:((_ request:CNRequestBase,_ responseData:Data)->Void)?
    
    //end handle request
    
    
    public static let `default` = CNNetworkManager()
    
    public let reachabilityManager = NetworkReachabilityManager()
    public let networkChanged = PublishSubject<NetworkReachabilityManager.NetworkReachabilityStatus>.init()
    var requests = [CNRequestBase]()
    public let sessionManager : SessionManager
    private init() {
        //
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        self.sessionManager = SessionManager.init(configuration: configuration)
        //监听网络
        reachabilityManager?.listener = {[weak self]status in
            print("Network Status Changed: \(status)")
            self?.networkChanged.onNext(status)
        }
        reachabilityManager?.startListening()
    }
    
    //
    public var host = ""
    
    
    func start(request:CNRequestBase){
        //如果请求已经在数组中
        if let _ = self.requests.index(of: request){
            return
        }
        //should send
        if !request.shouldSend() {return}
        if let should = self.requestShouldSend?(request),!should{return}
        
        
        self.requests.append(request)
        let url = (host + request.path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let dataRequest = sessionManager.request(url!, method: request.method, parameters: request.parameters, encoding: request.encoding, headers: request.headers)
        request.dataRequest = dataRequest
        
        //will send
        request.willSend()
        self.requestWillSend?(request)
        
        
        dataRequest.responseData {[weak self] (response) in
            guard let `self` = self else{return}
            defer{ self.remove(request: request)}
            request.dataResponse = response
            //handle error
            if let error = self.requestHandleToError?(request,response){
                if let handle = self.requestReceiveError?(request,error as NSError),handle{return}
                request.receiveError(error: error as NSError)
                return
            }
            
            //error
            if let error = response.error{
                if let handle = self.requestReceiveError?(request,error as NSError),handle{return}
                request.receiveError(error: error as NSError)
                return
            }
            
            //data
            if let data = response.value{
                //should receive
                if let should = self.requestShouldReceiveData?(request,data),!should{return}
                if !request.shouldReceiveData(responseData: data){return}
                
                //will receive
                self.requestWillReceiveData?(request,data)
                request.willReceiveData(responseData: data)
                
                //did receive
                self.requestDidReceiveData?(request,data)
                request.dataResponse = response
                request.didReceiveData(responseData: data)
                return
            }
        }
        
        //did send
        request.didSend()
        self.requestDidSend?(request)
        
    }
    
    public func cancle(request:CNRequestBase){
        request.dataRequest?.cancel()
        self.remove(request: request)
    }
    
    private func remove(request:CNRequestBase){
        if let index = self.requests.index(of: request){
            self.requests.remove(at: index)
        }
    }
    
}

