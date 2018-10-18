def import_pods
  pod 'scrypt', '~> 2.0'
  pod "PromiseKit", "~> 6.4.1"
  pod 'BigInt', '~> 3.1'
  pod 'CryptoSwift', '~> 0.12'
  pod 'Result', '~> 4.0'
  pod 'secp256k1_swift', '~> 1.0.3', :modular_headers => true
  pod 'SwiftRLP', '~> 1.0.1'
end

target 'PlasmaSwiftLib' do
  platform :ios, '9.0'
  use_modular_headers!
  import_pods

  target 'PlasmaSwiftLibTests' do
    inherit! :search_paths
  end

end
