# coding: utf-8

Pod::Spec.new do |s|
  s.name         = "PluginQrcodeScanner"
  s.version      = "0.5.0"
  s.summary      = "Weex Plugin for Scanning and decoding QR codes"

  s.description  = <<-DESC
                   Weexplugin Source Description
                   DESC

  s.homepage     = "https://github.com"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
            copyright
    LICENSE
  }
  s.authors      = {
                     "dseeker" =>"siqueira@eyzmedia.de"
                   }
  s.platform     = :ios
  s.ios.deployment_target = "9.0"

  s.source       = { :git => 'please input the url of your code in github', :tag => 'please input you github tag' }
  s.source_files  = "ios/Sources/*.{h,m,mm}"
  
  s.requires_arc = true
  s.dependency "WeexPluginLoader"
  s.dependency "WeexSDK"
  s.dependency "MTBBarcodeScanner"
end
