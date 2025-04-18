# frozen_string_literal: true

source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "webrick", "~> 1.7" # Needed for Ruby 3.x

gem "jekyll-theme-chirpy", "~> 7.2", ">= 7.2.4"
gem "html-proofer", "~> 5.0", group: :test

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", :platforms => [:mingw, :x64_mingw, :mswin]
