platform :ios, '14.0'

target 'MyWishlist' do
  
  use_frameworks!

  # Pods for MyWishlist
  
  pod 'RealmSwift', '10.49.3'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Realm'
      create_symlink_phase = target.shell_script_build_phases.find { |x| x.name == 'Create Symlinks to Header Folders' }
      create_symlink_phase.always_out_of_date = "1"
    end
  end
end
