Pod::Spec.new do |s|
  s.name             = "DRNRACNetworkClient"
  s.version          = "0.1.0"
  s.summary          = "A reactive network client"
  s.description      = <<-DESC
  A reactive network client built with AFNetworking and ReactiveCocoa to make pleasant dealing with network layer.
                       DESC
  s.homepage         = "https://github.com/ricowere/DRNRACNetworkClient"
  s.license          = 'MIT'
  s.author           = { "David Rico" => "drico.david@gmail.com" }
  s.source           = { :git => "https://github.com/ricowere/DRNRACNetworkClient.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.3'
  s.requires_arc = true

  s.public_header_files = 'Source/**/*.h'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Source/**/*.{h,m}'
  end

  s.dependency 'AFNetworking', '~> 2.5'
  s.dependency 'ReactiveCocoa','~> 2.5'

end