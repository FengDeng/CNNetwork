
Pod::Spec.new do |s|

  s.name         = "CNNetwork"
  s.version      = "0.0.1"
  s.summary      = "Simple request base on Alamofire & RxSwift"

  s.description  = <<-DESC
                    Simple request base on Alamofire & RxSwift,Simple request base on Alamofire & RxSwift
                   DESC

  s.homepage     = "https://github.com/FengDeng/CNNetwork"

  s.license      = { :type => "MIT", :file => "xiangzhen" }
  s.author             = { "邓锋" => "704292743@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/FengDeng/CNNetwork.git", :branch => "master" }
  s.source_files  = "Classes", "Source/*.swift"
  s.framework  = "Foundation"
  s.requires_arc = true
  s.dependency "RxSwift"
  s.dependency "Alamofire"

end
