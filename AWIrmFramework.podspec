Pod::Spec.new do |s|

s.platform = :ios

s.ios.deployment_target = '8.0'

s.name = "AWIrmFramework"

s.summary = "This framework authenticates the user and extracts the user IRM policies and restrictions for protected file"

s.requires_arc = true

s.version = "0.0.11"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "VMWare Airwatch" => "adityaprasad@vmware.com" }

s.homepage = "https://stash.air-watch.com/projects/ISCL/repos/awirmframework"

s.source = { :git => "https://github.com/adisagar/AwIRMFramework.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.source_files =  "AWIrmFramework/**/*.{swift}", "AWIrmFramework/AWIrmFramework.h"

end