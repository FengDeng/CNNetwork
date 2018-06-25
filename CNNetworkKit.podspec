
Pod::Spec.new do |s|

  s.name         = "CNNetwork"
  s.version      = "0.0.2"
  s.summary      = "Simple request base on Alamofire & RxSwift"
  s.swift_version = "4.1"
  s.description  = <<-DESC
                    Simple request base on Alamofire & RxSwift,Simple request base on Alamofire & RxSwift
                   DESC

  s.homepage     = "http://git.51wakeup.cn:81/wakeup/GuideSpecs"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "邓锋" => "704292743@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@git.51wakeup.cn:iOS-Team/CNNetwork.git", :tag => "#{s.version}"  }
  s.source_files  = "Classes", "Source/*.swift"
  s.framework  = "Foundation"
  s.requires_arc = true
  s.dependency "RxSwift"
  s.dependency "Alamofire"

end
