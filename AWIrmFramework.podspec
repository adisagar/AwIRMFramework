Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "AWIrmFramework"
s.summary = "This framework does all IRM operations."
s.requires_arc = true

# 2
s.version = "0.0.2"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "VMWare Airwatch" => "adityaprasad@vmware.com" }


# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/adisagar/AwIRMFramework"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/adisagar/AwIRMFramework.git", :tag => "#{s.version}"}

# 7
s.framework = "UIKit"

# 8

s.source_files = "AWIrmFramework/**/*.{swift}", "AWIrmFramework/AWIrmFramework.h"
s.frameworks  = "CoreData" , "MessageUI" , "SystemConfiguration" , "Security"
s.libraries = 'resolv'

#s.library = 'MSRightsManagement' , 'ADALiOS'
s.vendored_frameworks = 'AWIrmFramework/Frameworks/MSRightsManagement.framework','AWIrmFramework/Frameworks/ADALiOS.framework'
s.resource_bundles = {   'MSRightsManagement' => ['AWIrmFramework/Frameworks/MSRightsManagementResources.bundle'],
                             'ADALiOS' => ['AWIrmFramework/Frameworks/ADALiOS.bundle']}
s.module_map = 'AWIrmFramework/AWIrmFramework.modulemap'
#s.xcconfig            = { 'FRAMEWORK_SEARCH_PATHS' => 'AWIrmFramework/MSRightsManagement.framework/' }
#s.public_header_files =  "AWIrmFramework/*.{h}"
#s.public_header_files = "SwiftFramework/AwFramework.framework/Versions/A/Headers/*.{h}"
#s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => 'AWIrmFramework/MSRightsManagement.framework' }
end