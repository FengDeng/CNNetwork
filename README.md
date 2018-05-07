# CNNetwork
Base on Alamofire &amp; RxSwift



## Pods
pod 'CNNetwork', :git => 'https://github.com/FengDeng/CNNetwork.git', :branch => 'master'

## Demo

### config CNNetworkManager

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


### init request

  1. 单个模型请求
    
    class B :Codable{
            var times = 8
            var sex = "男"
        }
        let base = CNRequestObject<B>()
        base.subscribe(success: { (b) in
            print(b)
        }) { (err) in
            print(err)
        }.disposed(by: self.rx.dispose)
        base.fetch()

  2. 数组模型请求

    class B :Codable{
            var times = 8
            var sex = "男"
        }
        let base = CNRequestArray<B>()
        base.subscribe(success: { (bs) in
            print(bs)
        }) { (err) in
            print(err)
        }.disposed(by: self.rx.dispose)
        base.fetchFirst()
        base.fetchNext()