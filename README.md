# CNNetwork
Base on Alamofire &amp; RxSwift

## Pods
pod 'CNNetwork', :git => 'https://github.com/FengDeng/CNNetwork.git', :branch => 'master'

## Demo

1. config CNNetworkManager

    ```
            CNNetworkManager.default.host = "http://****.com"
        //监听网络连接
        CNNetworkManager.default.networkChanged.bind { (status) in
            switch status{
            case .notReachable:
                break
            case .reachable(let type):
                switch type{
                case .ethernetOrWiFi:
                    break
                case .wwan:
                    //切换到4g  暂停所有上传下载
                    
                    break
                }
                break
            case .unknown:
                break
            }
        }.disposed(by: self.rx.disposeBag)
        
        //配置基本信息
        
        //配置加密 //配置token
        CNNetworkManager.default.requestShouldSend = {request in
            //参数签名
            
            //配置token
            
            //统一header
            request.headers["Content-Type"] = "application/json"
            
            return true
        }
        
        CNNetworkManager.default.requestWillSend = {request in
            
        }
        
        CNNetworkManager.default.requestDidSend = {request in
            
        }
        
        CNNetworkManager.default.requestHandleToError = {request,data in
            return nil
        }
        
        CNNetworkManager.default.requestReceiveError = {request,error in
            print(error)
            return false
        }
        
        CNNetworkManager.default.requestShouldReceiveData = {request,data in
            return true
        }
        CNNetworkManager.default.requestDidReceiveData = {request,data in
            print(request.dataRequest)
            print(request.dataResponse)
            let str = String.init(data: request.dataResponse!.value!, encoding: String.Encoding.utf8)
            print(str)
        }
    ```


2. init request

  ```
  
  ```