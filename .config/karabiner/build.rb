#!/usr/bin/env ruby

require 'json'
require './conf'

conf = Conf.gen()

File.open("./karabiner.json", 'w') do |f|
  JSON.dump(conf, f)
end
