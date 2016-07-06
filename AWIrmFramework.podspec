Pod::Spec.new do |s|


s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "AWIrmFramework"
s.summary = "This framework does all IRM operations."
s.requires_arc = true


s.version = "0.0.6"


s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "VMWare Airwatch" => "adityaprasad@vmware.com" }



s.homepage = "https://github.com/adisagar/AwIRMFramework"


s.source = { :git => "https://github.com/adisagar/AwIRMFramework.git", :tag => "#{s.version}"}


s.framework = "UIKit"



s.source_files = "AWIrmFramework/**/*.{swift}", "AWIrmFramework/AWIrmFramework.h"
s.frameworks  = "CoreData" , "MessageUI" , "SystemConfiguration" , "Security"
s.libraries = 'resolv'


s.vendored_frameworks = 'AWIrmFramework/Frameworks/MSRightsManagement.framework','AWIrmFramework/Frameworks/ADALiOS.framework'

s.resource_bundles = {   'MSRightsManagement' => ['AWIrmFramework/Frameworks/MSRightsManagementResources.bundle'],
                             'ADALiOS' => ['AWIrmFramework/Frameworks/ADALiOS.bundle']}

s.module_map = 'AWIrmFramework/AWIrmFramework.modulemap'

end