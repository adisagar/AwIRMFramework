Pod::Spec.new do |s|

s.platform = :ios

s.ios.deployment_target = '8.0'

s.name = "AWIrmFramework"

s.summary = "This framework authenticates the user and extracts the user IRM policies and restrictions for protected file. And also decrypts the contents if user has permissions."

s.requires_arc = true

s.version = "0.0.1"

s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "VMWare Airwatch" => "adityaprasad@vmware.com" }

s.homepage = "https://stash.air-watch.com/projects/ISCL/repos/awirmframework"

s.source = { :git => "ssh://git@stash.air-watch.com:7999/iscl/awirmframework.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.source_files = "AWIrmFramework/**/*.{h}"

end