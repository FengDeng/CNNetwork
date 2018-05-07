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

class CNRequestBase {
    
    var dataRequest : DataRequest? = nil
    var dataResponse : DataResponse<Data>? = nil
    
    var path : String = ""
    var headers : HTTPHeaders = [:]
    var parameters : Parameters = [:]
    var method : HTTPMethod = .get
    var encoding : ParameterEncoding = JSONEncoding.default
    
    
    func fetch(){
        CNNetworkManager.default.start(request: self)
    }
    func cancle(){
        CNNetworkManager.default.cancle(request: self)
    }
    
    func shouldSend()->Bool{
        return true
    }
    func willSend(){
        
    }
    func didSend(){
        
    }
    
    func handleToError(response:DataResponse<Data>){
        
    }
    func receiveError(error:NSError){
        
    }
    
    func shouldReceiveData(responseData:Data)->Bool{
        return true
    }
    func willReceiveData(responseData:Data){
        
    }
    func didReceiveData(responseData:Data){
        
    }
    
}

extension CNRequestBase : Equatable{
    static func ==(lhs: CNRequestBase, rhs: CNRequestBase) -> Bool {
        return lhs.path == rhs.path && NSDictionary.init(dictionary: lhs.headers).isEqual(to: rhs.headers) && NSDictionary.init(dictionary: lhs.parameters).isEqual(to: rhs.parameters) && lhs.method == rhs.method
    }
}
