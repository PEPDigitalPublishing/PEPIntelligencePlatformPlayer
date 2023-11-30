Pod::Spec.new do |s|

  s.name             = 'PEPIntelligencePlatformPlayer'

  s.version          = '1.0.0'

  s.summary          = 'PEPIntelligencePlatformPlayer Description.'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  s.homepage         = 'https://github.com/PEPDigitalPublishing/PEPIntelligencePlatformPlayer'

  s.author           = { '崔冉' => 'cuir@pep.com.cn' }

  s.source           = { :git => 'https://github.com/PEPDigitalPublishing/PEPIntelligencePlatformPlayer'}

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/PEPPlayer.h'

  s.public_header_files = 'Classes/PEPPlayer.h'

  s.dependency 'Masonry'

  s.resource_bundles = {
    'PEPPlayerAsset' => ['Assets/*.png', 'Classes/**/*.{xib, storyboard}']
  }

  s.subspec 'MediaPlayer' do |ss|

    ss.source_files = 'Classes/MediaPlayer/*.{h,m}'
    ss.public_header_files = 'Classes/MediaPlayer/*.{h,m}'

  end

  s.subspec 'PhotoBrower' do |ss|

    ss.source_files = 'Classes/PhotoBrower/*.{h,m}'
    ss.public_header_files = 'Classes/PhotoBrower/*.{h,m}'

  end

  s.subspec 'Utils' do |ss|

    ss.source_files = 'Classes/Utils/*.{h,m}'
    ss.public_header_files = 'lasses/Utils/*.{h,m}'

  end

  s.frameworks = 'UIKit', 'AVFoundation', 'CoreMedia'

end
















