def import_pods
  pod 'web3swift', '~> 2.0.4'
end

target 'PlasmaSwiftLib' do
  platform :ios, '9.0'
  use_modular_headers!
  import_pods

  target 'PlasmaSwiftLibTests' do
    inherit! :search_paths
  end

end
