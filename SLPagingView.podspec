Pod::Spec.new do |s|
	s.name = 'SLPagingView'
	s.version = '0.0.5'
	s.summary = 'Navigation bar system allowing to do a Tinder like or Twitter like'
	s.homepage = 'https://github.com/ankorko/SLPagingView'
	s.license = 'MIT'
	s.author = { 'ankorko' => 'ankorko@gmail.com' }
	s.source = { :git => 'https://github.com/ankorko/SLPagingView.git', :tag => "#{s.version}" }
	s.source_files = 'SLPagingView/**/*.{h,m}'
	s.requires_arc = true
	s.platform = :ios, '7.0'
	s.ios.deployment_target = '7.0'
end
