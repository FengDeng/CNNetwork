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
    public var requestReceiveError:((_ request:CNRequestBase,_ error:NSError)->Error?)?//return nil 拦截掉错误，request将收不到
    
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
        let requestRetrier = NetworkRequestRetrier()   // Create a request retrier
        sessionManager.retrier = requestRetrier        // Set the retrier
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "gateway.91zhiyin.com": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(),
//                validateCertificateChain: true,
//                validateHost: true
//            )
//        ]
//        self.sessionManager = SessionManager.init(configuration:configuration , serverTrustPolicyManager: ServerTrustPolicyManager.init(policies: serverTrustPolicies))
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
        print("start--:\(request)")
        print("--:\(request.isRequesting)")
        //如果请求已经在数组中
        if let _ = self.requests.index(of: request){
            print("请求重复")
            return
        }
        if request.isRequesting{
            return
            
        }
        //should send
        if !request.shouldSend() {return}
        if let should = self.requestShouldSend?(request),!should{return}
        
        
        self.requests.append(request)
        let queryStr = request.defaultQuerys.map { (obj) -> String in
            return "\(obj.key)=\(obj.value)"
            }.joined(separator: "&")
        let queryStr1 = queryStr.count > 0 ? "?\(queryStr)" : queryStr
        let requestHost = request.host.count == 0 ? host : request.host
        let url = (requestHost + request.path + queryStr1).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var dataRequest : DataRequest
        if request.method == .get{
            let paras = request.parameters + request.defaultParameters
            var str = paras.map { (obj) -> String in
                return "\(obj.key)=\(obj.value)"
                }.joined(separator: "&")
            if str.count > 0{
                str = "&" + str
            }
            dataRequest = sessionManager.request(url! + str, method: request.method, parameters: nil, encoding: request.encoding, headers: request.headers + request.defaultHeaders)
        }else{
            dataRequest = sessionManager.request(url!, method: request.method, parameters: request.parameters + request.defaultParameters, encoding: request.encoding, headers: request.headers + request.defaultHeaders)
        }
        
        
        request.dataRequest = dataRequest
        if let timeoutInterval = request.timeoutInterval{
            dataRequest.request?.timeoutInterval == timeoutInterval
        }

        //will send
        request.willSend()
        self.requestWillSend?(request)
        
        request.isRequesting = true
        dataRequest.responseData {[weak self] (response) in
            guard let `self` = self else{return}
            defer{ self.remove(request: request)}
            request.isRequesting = false
            request.dataResponse = response
            //handle error
            if let error = self.requestHandleToError?(request,response){
                guard let handle = self.requestReceiveError else{
                    request.receiveError(error: (error as NSError))
                    return
                }
                if let handleError = handle(request,(error as NSError)){
                    request.receiveError(error: (handleError as NSError))
                }
                return
            }
            
            //error
            if let error = response.error{
                guard let handle = self.requestReceiveError else{
                    request.receiveError(error: (error as NSError))
                    return
                }
                if let handleError = handle(request,(error as NSError)){
                    request.receiveError(error: (handleError as NSError))
                }
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

func + <T>(lhs: Dictionary<String,T>, rhs: Dictionary<String,T>) -> Dictionary<String,T> {
    var dic = lhs
    for (key,value) in rhs{
        dic[key] = value
    }
    return dic
}

///重试
class NetworkRequestRetrier: RequestRetrier {
    
    // [Request url: Number of times retried]
    private var retriedRequests: [String: Int] = [:]
    
    internal func should(_ manager: SessionManager,
                         retry request: Request,
                         with error: Error,
                         completion: @escaping RequestRetryCompletion) {
        
        guard
            request.task?.response == nil,
            let url = request.request?.url?.absoluteString
            else {
                removeCachedUrlRequest(url: request.request?.url?.absoluteString)
                completion(false, 0.0) // don't retry
                return
        }
        
        guard let retryCount = retriedRequests[url] else {
            retriedRequests[url] = 1
            completion(true, 1.0) // retry after 1 second
            return
        }
        
        if retryCount <= 3 {
            retriedRequests[url] = retryCount + 1
            completion(true, 1.0) // retry after 1 second
        } else {
            removeCachedUrlRequest(url: url)
            completion(false, 0.0) // don't retry
        }
        
    }
    
    private func removeCachedUrlRequest(url: String?) {
        guard let url = url else {
            return
        }
        retriedRequests.removeValue(forKey: url)
    }
    
}
