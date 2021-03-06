Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_yandex_market'
  s.version     = '2.0.0'
  s.summary     = 'Export products to Yandex.Market'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.9.1'

  s.author            = 'Noname'
  # s.email             = 'david@loudthinking.com'
  s.homepage          = 'https://github.com/itima/spree-yandex-market'
  # s.rubyforge_project = 'actionmailer'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency('spree_core', '~> 2.0.0')
  s.add_dependency('nokogiri', '~> 1.5')
end
