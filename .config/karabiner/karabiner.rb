#!/usr/bin/env ruby

require 'json'

def gen_conf(rules)
  {
    global: {
      check_for_updates_on_startup: true,
      show_in_menu_bar: false,
      show_profile_name_in_menu_bar: false,
    },
    profiles: [{
      complex_modifications: {
        parameters: {
          "basic.to_if_alone_timeout_milliseconds": 500,
        },
        rules: rules
      }
    }]
  }
end

def pp(obj)
  puts JSON.pretty_generate(obj)
end

def rule_gen(desc, manipulators)
  manipulators.each { |m|
    m[:type] = "basic"
  }
  {
    description: desc,
    manipulators: manipulators.map { |m| m.merge({
      type: "basic"
    }) }
  }
end

def cond_gen_device_if(identifiers)
  {
    type: "device_if",
    identifiers: identifiers
  }
end

def modfrom_gen_mandatory(mods)
  {
    mandatory: mods
  }
end

def modfrom_gen_optional(mods)
  {
    optional: mods
  }
end

$modfrom_any = modfrom_gen_mandatory(["any"])

$cond_is_internal_keyboard = cond_gen_device_if([
      {vendor_id: 1452},
      {product_id: 610}
])


$key_region_alphabet = ('a'..'z').to_a
$key_region_symbol_below = [
  "comma",
  "period",
  "slash",
  "semicolon",
  "quote",
  "open_bracket",
  "close_bracket",
  "backslash",
]
$key_region_symbol_above = [
  "hyphen",
  "equal_sign",
]
$key_region_number = (0..9).to_a
$key_region_below = $key_region_alphabet + $key_region_symbol_below
$key_region_above = $key_region_number + $key_region_symbol_above
$key_region_whole = $key_region_below + $key_region_above

class Layer
  @@cond_is_in_layer0 = {
    name: "layer",
    type: "variable_if",
    value: 0,
  }
  def initialize(layer_num, layer_mods, layer_keys)
    @layer_num = layer_num
    @layer_modes = layer_mods
    @layer_keys = layer_keys

    @rules = []
    @cond_is_in_this_layer = {
      name: "layer",
      type: "variable_if",
      value: @layer_num,
    }
  end

  def gen_rules
    gen_rules_hook_before()
    @rules += layer_rules()
    gen_rules_hook_after()
    @rules
  end

  def layer_rules
    [
      rule_gen(
        "layer #{@layer_num}: layer_mod-key",
        @layer_keys.map { |key|
          {
            conditions: [
              @cond_is_in_this_layer
            ],
            from: {
              key_code: key,
              modifiers: $modfrom_any
            },
            to: [
              key_code: key,
              modifiers: @layer_mods
            ]
          }
        }
      )
    ]
  end

  def gen_rules_hook_before
  end

  def gen_rules_hook_after
  end
end

class Layer1 < Layer
  def initialize(*args)
    super(1, *args)
  end
  def gen_rules_hook_before
    @layer_keys -= ('a'..'c').to_a
  end
end

rules = [
  rule_gen(
    "(internal) fn-caps_lock: caps_lock",
    [
      {
        conditions: [
          $cond_is_internal_keyboard
        ],
        from: {
          key_code: "caps_lock",
          modifiers: $mod_mand_fn
        },
        to: [
          {key_code: "caps_lock"}
        ],
      }
    ],
  )
]

# Layer1
layer1_mods = [
  "command",
  "shift",
  "option",
]
layer1_keys = $key_region_whole

# Layer2

layers = [
  Layer1.new(layer1_mods, ['d'])
]

# concat rules from all layers
layers.each { |layer| rules += layer.gen_rules() }

#test
pp(rules)

# conf = gen_conf(rules)

# pp(conf)

# f = File.open("./karabiner.json", "w")
# JSON.dump(conf, f)
