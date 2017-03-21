# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FamilyBudget' do
    use_frameworks!
    
    pod 'SQLite.swift'
    
    pod 'Alamofire'
    
    pod 'SwiftyJSON'
    
    pod 'Charts'
    
    pod 'AlamofireNetworkActivityIndicator'

    target 'FamilyBudgetTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'FamilyBudgetUITests' do
        inherit! :search_paths
        # Pods for testing
    end
end

target 'widget' do
    use_frameworks!
    
    pod 'SQLite.swift'
    
    pod 'Alamofire'
    
    pod 'SwiftyJSON'

    pod 'Charts'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
