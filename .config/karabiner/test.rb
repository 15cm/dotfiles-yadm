#!/usr/bin/env ruby

require 'json'
require './conf'

def pp(obj)
  puts JSON.pretty_generate(obj)
end

module Test
  include Conf
  def layer1_keys
    ["d"]
  end

  def test
    conf = gen()
    pp(conf)
  end
end

include Test

test()
