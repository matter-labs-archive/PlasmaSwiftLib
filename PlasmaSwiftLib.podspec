Pod::Spec.new do |s|
  s.name             = 'PlasmaSwiftLib'
  s.version          = '2.1.0'
  s.summary          = 'PlasmaSwiftLib is your toolbelt for any kind interactions with The Matter Plasma Implementations.'
 
  s.description      = <<-DESC
Use this library to implement all necessary functionality of THe Matter Plasma Implementation into your App. Completely native on pure Swift. 
                       DESC
 
  s.homepage         = 'https://github.com/matterinc/PlasmaSwiftLib'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Anton Grigorev' => 'antongrigorjev2010@gmail.com' }
  s.source           = { :git => 'https://github.com/matterinc/PlasmaSwiftLib.git', :tag => s.version.to_s }
  s.swift_version = '4.2'
  s.module_name = 'PlasmaSwiftLib'
 
  s.ios.deployment_target = '9.0'
  s.source_files = "PlasmaSwiftLib/**/*.{h,swift}", "PlasmaSwiftLib/**/**/*.{h,swift}"
  s.public_header_files = "PlasmaSwiftLib/*.{h}"
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.dependency 'BigInt'
  s.dependency 'CryptoSwift'
  s.dependency 'EthereumABI'
  s.dependency 'EthereumAddress'
  s.dependency 'PromiseKit'
  s.dependency 'SipHash'
  s.dependency 'SwiftRLP'
  s.dependency 'scrypt'
  s.dependency 'secp256k1_swift'
  s.dependency 'web3swift'
 
end
