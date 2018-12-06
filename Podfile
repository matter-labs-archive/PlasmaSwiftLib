source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

def import_pods
  pod 'web3swift', '~> 2.0.4'
end

target 'PlasmaSwiftLib' do
  
  #use_modular_headers!
  use_frameworks!
  import_pods

  target 'PlasmaSwiftLibTests' do
    inherit! :search_paths
  end

end
