//
//  CNRequest.swift
//  Lecturer
//
//  Created by 邓锋 on 2018/4/18.
//  Copyright © 2018年 xiangzhen. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

open class CNRequestBase {
    
    open internal(set) var dataRequest : DataRequest? = nil
    open internal(set) var dataResponse : DataResponse<Data>? = nil
    
    open var host : String {return ""}
    open var path : String {return ""}
    open var headers : HTTPHeaders {return [:]}
    open var parameters : Parameters {return [:]}
    open var method : HTTPMethod {return .get}
    open var encoding : ParameterEncoding {return JSONEncoding.default}
    
    public var defaultParameters : Parameters = [:]
    
    public var defaultHeaders : HTTPHeaders = [:]
    
    public var defaultQuerys : HTTPHeaders = [:]
    
    public internal(set) var isRequesting = false
    
    public init() {
        
    }
    
    open func fetch(){
        CNNetworkManager.default.start(request: self)
    }
    open func cancle(){
        CNNetworkManager.default.cancle(request: self)
    }
    
    @objc open func shouldSend()->Bool{
        return true
    }
    open func willSend(){
        
    }
    open func didSend(){
        
    }
    
    open func handleToError(response:DataResponse<Data>){
        
    }
    open func receiveError(error:NSError){
        
    }
    
    open func shouldReceiveData(responseData:Data)->Bool{
        return true
    }
    open func willReceiveData(responseData:Data){
        
    }
    open func didReceiveData(responseData:Data){
        
    }
    
}

extension CNRequestBase : Equatable{
    open static func ==(lhs: CNRequestBase, rhs: CNRequestBase) -> Bool {
        return lhs.path == rhs.path && NSDictionary.init(dictionary: lhs.headers).isEqual(to: rhs.headers) && NSDictionary.init(dictionary: lhs.parameters).isEqual(to: rhs.parameters) && lhs.method == rhs.method
    }
}


