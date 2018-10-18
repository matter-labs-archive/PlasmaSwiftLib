def import_pods
  pod 'BigInt', '~> 3.1'
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
