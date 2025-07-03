# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'App' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'razorpay-pod', '1.2.5'
pod 'lottie-ios'
pod 'SDWebImage', '~> 5.12.0'
pod 'MaterialComponents/Buttons'
pod 'IQKeyboardManagerSwift', '6.4.0'
pod 'GoogleSignIn'
pod 'JJFloatingActionButton'
pod 'GooglePlaces'
pod 'GoogleMaps'
pod 'GooglePlacePicker'
pod 'RangeSeekSlider'
pod 'Toast-Swift'
pod 'Apollo', '~> 0.10.1'
pod 'Cosmos'
pod 'SwiftyJSON'
pod 'ISPageControl', '~> 0.1.0'
pod 'GrowingTextView'
pod 'Firebase/Core'
pod 'MKToolTip'
pod 'Firebase/Messaging'
pod 'Firebase/Crashlytics'
pod 'SwiftMessages'
pod 'SCPageControl'
pod 'PayPalCheckout'
pod 'Alamofire'
pod 'AssetsPickerViewController'
pod 'SKPhotoBrowser'
pod 'Stripe'
pod 'SkeletonView'
pod 'JXPageControl'
pod "FlexiblePageControl"


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

end

