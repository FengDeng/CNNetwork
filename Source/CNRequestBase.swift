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

public class CNRequestBase {
    
    public internal(set) var dataRequest : DataRequest? = nil
    public internal(set) var dataResponse : DataResponse<Data>? = nil
    
    public var path : String = ""
    public var headers : HTTPHeaders = [:]
    public var parameters : Parameters = [:]
    public var method : HTTPMethod = .get
    public var encoding : ParameterEncoding = JSONEncoding.default
    
    public init() {
        
    }
    
    public func fetch(){
        CNNetworkManager.default.start(request: self)
    }
    public func cancle(){
        CNNetworkManager.default.cancle(request: self)
    }
    
    public func shouldSend()->Bool{
        return true
    }
    public func willSend(){
        
    }
    public func didSend(){
        
    }
    
    public func handleToError(response:DataResponse<Data>){
        
    }
    public func receiveError(error:NSError){
        
    }
    
    public func shouldReceiveData(responseData:Data)->Bool{
        return true
    }
    public func willReceiveData(responseData:Data){
        
    }
    public func didReceiveData(responseData:Data){
        
    }
    
}

extension CNRequestBase : Equatable{
    public static func ==(lhs: CNRequestBase, rhs: CNRequestBase) -> Bool {
        return lhs.path == rhs.path && NSDictionary.init(dictionary: lhs.headers).isEqual(to: rhs.headers) && NSDictionary.init(dictionary: lhs.parameters).isEqual(to: rhs.parameters) && lhs.method == rhs.method
    }
}
