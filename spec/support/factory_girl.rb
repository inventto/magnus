# -*- encoding : utf-8 -*-
RSpec.configure do |config|    
  config.before(:suite) do    
    begin    
      DatabaseCleaner.start    
      FactoryGirl.lint    
    ensure    
      DatabaseCleaner.clean    
    end    
  end    
end
