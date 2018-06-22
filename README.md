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


### 如何使用


### 单个模型

    //新建一个模型
        class UserVO : Codable{
            var name = ""
            var sex = Sex.man
            
            enum Sex : Int,Codable {
                case man
                case woman
            }
        }
        
        //建立一个获取单个模型的请求
        class GetUserVO: CNRequest<UserVO> {
            
        }
        let getUserVOAPI = GetUserVO.init()
        getUserVOAPI.subscribe(success: { (user) in
            print(user)
        }) { (err) in
            
        }.disposed(by: disposeBag)
        getUserVOAPI.fetch()



### 数组模型，带翻页

    //建立一个获取数组模型的请求
        class GetUserVOList: CNRequest<[UserVO]> {
            
        }
        let api2 = GetUserVOList()
        api2.subscribe(success: { (users) in
            print(users.count)
        }) { (ere) in
            
        }.disposed(by: disposeBag)
        api2.fetchFirst()
        api2.fetchNext()


### 单个模型，里面含有数组  有翻页

    //新建一个模型，翻页数组在模型内部，例如
        class Store: Pageble{
            var name = ""
            var users = [UserVO]() //这个是翻页数组
            
            //下面两个方法是翻页协议
            var datas: [UserVO] {
                return users
            }
            var hasNext: Bool {
                return users.count > 0
            }
        }
        class GetStore: CNRequest<Store> {
            
        }
        let storeAPI = GetStore()
        storeAPI.subscribe(success: { (store) in
            let users = store.users
            print(users)
        }) { (err) in
            
        }.disposed(by: disposeBag)
        storeAPI.fetchFirst()
        storeAPI.fetchNext()