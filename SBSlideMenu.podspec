Pod::Spec.new do |s|

  s.name         = "SBSlideMenu"
  s.version      = "0.0.1"
  s.summary      = "Amazing UISegmentedControl replacement"
 
  s.description  = <<-DESC
                   Multiple controls grouped together to forme like a segmented control
                   with the ability to define any transition moving between
                   the controls.
                   DESC
 
  s.homepage = "https://github.com/salimbraksa/SBSlideMenu"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Braksa Salim" => "salim.braksa@gmail.com" }
  s.social_media_url   = "https://twitter.com/salimbraksa"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/salimbraksa/SBSlideMenu.git", :tag => s.version }
  s.source_files  = "SBSlideMenu/*.swift"

  s.dependency 'Cartography'

end
