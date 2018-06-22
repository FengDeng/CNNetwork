//
//  ViewController.swift
//  CNRequestDemo
//
//  Created by 邓锋 on 2018/5/7.
//  Copyright © 2018年 xiangzhen. All rights reserved.
//

import UIKit
import RxSwift





class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let disposeBag = DisposeBag()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

