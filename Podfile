# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'monster-chase' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for monster-chase
  #pod 'PocketSwift', :git => 'git@github.com:pokt-network/pocket-swift.git', :branch => 'master'
  #pod 'PocketAion', '~> 0.0.14'
  #pod 'PocketAion', :path => '~/current_projects/pocket-ios-aion'
  pod 'PocketSwift/Aion', :path => '~/current_projects/pocket-swift'
  pod 'SidebarOverlay', :git => 'git@github.com:pokt-network/SidebarOverlay.git', :branch => 'develop'
  #pod 'FlexColorPicker', :git => 'https://github.com/RastislavMirek/FlexColorPicker', :branch => 'master'
  pod 'FlexColorPicker', '~> 1.2.1'
  pod 'SwiftHEXColors', '~> 1.2.0'
  pod 'BiometricAuthentication', '~> 3.0'
  pod 'CryptoSwift', '~> 1.0.0'
  pod 'SwiftyJSON', '~> 4.3.0'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
