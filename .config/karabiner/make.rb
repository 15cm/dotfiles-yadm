#!/usr/local/bin/ruby
require 'json'
require 'yaml'

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

a = YAML.load_file('karabiner.yaml')
b = YAML.load_file('private.yaml')
b.each do |x|
    a["profiles"][0]["complex_modifications"]["rules"][0]["manipulators"] << x
end

File.write('karabiner.json', a.to_json)
