def import_pods
  pod 'BigInt', '~> 3.1'
  pod 'CryptoSwift', '~> 0.12'
  pod 'SwiftRLP', '~> 1.1'
  pod 'secp256k1_swift'
end

target 'PlasmaSwiftLib' do
  platform :ios, '9.0'
  use_modular_headers!
  import_pods

  target 'PlasmaSwiftLibTests' do
    inherit! :search_paths
  end

end
