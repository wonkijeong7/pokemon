use_frameworks!
inhibit_all_warnings!

target 'Pokemon' do
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'ReactorKit'
  pod 'RxDataSources'
  pod 'Alamofire'
end

target 'PokemonTests' do
  pod 'RxSwift'
  pod 'ReactorKit'
  pod 'RxBlocking'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
