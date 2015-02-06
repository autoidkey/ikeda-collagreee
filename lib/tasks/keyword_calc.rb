require "#{Rails.root}/app/models/theme"
require File.expand_path('../boot', __FILE__)
require File.expand_path('../environment', __FILE__)

class KeywordCalc
  def self.calc
    puts 'calc!'
    puts Theme.last.title
    Theme.test
  end
end
