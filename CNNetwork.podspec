
Pod::Spec.new do |s|
  s.name             = 'CNNetwork'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CNNetwork.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/704292743@qq.com/CommonKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '704292743@qq.com' => '704292743@qq.com' }
  s.source           = { :git => 'git@git.51wakeup.cn:iOS-Team/CNNetwork.git', :branch => 'master' }

  s.ios.deployment_target = '8.0'

  s.swift_version = "4.1"
  s.source_files = 'CNNetwork/Classes/**/*'
  s.dependency "RxSwift"
  s.dependency "Alamofire"
end
