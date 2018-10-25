def import_pods
  pod 'BigInt'
  pod 'CryptoSwift'
  pod 'SwiftRLP'
  pod 'secp256k1_swift'
  pod 'EthereumABI'
  pod 'EthereumAddress'
end

target 'PlasmaSwiftLib' do
  platform :ios, '9.0'
  use_modular_headers!
  import_pods

  target 'PlasmaSwiftLibTests' do
    inherit! :search_paths
  end

end
