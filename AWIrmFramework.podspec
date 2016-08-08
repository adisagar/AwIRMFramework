Pod::Spec.new do |s|


s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "AWIrmFramework"
s.summary = "This framework does all IRM operations."
s.requires_arc = true

s.dependency 'ADAL', '~> 2.2.2'


s.version = "0.0.18"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "VMWare Airwatch" => "adityaprasad@vmware.com" }

s.homepage = "'https://github.com/adisagar/AwIRMFramework"

s.source = { :git => "'https://github.com/adisagar/AwIRMFramework.git'", :tag => "#{s.version}"}

s.framework = "UIKit"

s.source_files = "AWIrmFramework/**/*.{swift}", "AWIrmFramework/AWIrmFramework.h",'AWIrmFramework/Frameworks/MSRightsManagement.framework/Headers/*'
s.frameworks  = "CoreData" , "MessageUI" , "SystemConfiguration" , "Security", "Foundation"
s.libraries = 'resolv'
s.resources = [ 'AWIrmFramework/Frameworks/MSRightsManagementResources.bundle']
s.private_header_files = ['AWIrmFramework/Frameworks/MSRightsManagement.framework/Headers/MSRightsManagement.h', 'AWIrmFramework/Frameworks/MSRightsManagement.framework/Headers/MSCustomProtection.h']

s.vendored_frameworks =  'AWIrmFramework/Frameworks/MSRightsManagement.framework'


s.pod_target_xcconfig = {
'OTHER_LDFLAGS'          => '-ObjC'
}

end