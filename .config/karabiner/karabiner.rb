module Rule
  module_function
  def gen(desc, manipulators)
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
end

module Cond
  module_function
  def gen_device_if(identifiers)
    {
      type: "device_if",
      identifiers: identifiers,
    }
  end

  def gen_variable_if(name, value)
    {
      name: name,
      type: "variable_if",
      value: value
    }
  end

  # module variables
  def is_internal_keyboard
    gen_device_if([
      {vendor_id: 1452},
      {product_id: 610},
    ])
  end
  def is_layer0
    gen_variable_if("layer", 0)
  end
  def is_layer1
    gen_variable_if("layer", 1)
  end
  def is_layer2
    gen_variable_if("layer", 2)
  end
  def is_layer3
    gen_variable_if("layer", 3)
  end
end

module SetVar
  module_function
  def gen(name, value)
    {
      set_variable: {
        name: name,
        value: value,
      }
    }
  end
end

module ModFrom
  module_function
  def gen_mandatory(mods)
    {
      mandatory: mods
    }
  end

  def gen_optional(mods)
    {
      optional: mods
    }
  end

  # module variables
  def optional_any
    gen_optional(["any"])
  end
  def mandatory_fn
    gen_mandatory(["fn"])
  end
end

module KeyRegion
  module_function
  def alphabet
    ('a'..'z').to_a
  end

  # module variables
  def symbol_below
    [
      "comma",
      "period",
      "slash",
      "semicolon",
      "quote",
      "open_bracket",
      "close_bracket",
      "backslash",
    ]
  end
  def symbol_above
    [
      "hyphen",
      "equal_sign",
    ]
  end
  def number
    (0..9).to_a
  end
  def below
    alphabet + symbol_below
  end
  def above
    number + symbol_above
  end
  def whole
    below + above
  end
end

class Layer
  @@cond_is_in_layer0 = {
    name: "layer",
    type: "variable_if",
    value: 0,
  }
  def initialize(layer_num, layer_trigger, layer_mods, layer_keys)
    @layer_num = layer_num
    @layer_trigger = layer_trigger
    @layer_mods = layer_mods
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
    @rules += trigger_rules
    @rules += main_rules
    gen_rules_hook_after()
    @rules
  end

  def trigger_rules
    [Rule.gen(
      "layer #{@layer_num} trigger",
      [{
        conditions: [
          Cond.is_layer0,
        ],
        from: {
          key_code: @layer_trigger,
          modifiers: ModFrom.optional_any,
        },
        to: [SetVar.gen("layer", 1)],
        to_after_key_up: [SetVar.gen("layer", 0)],
        to_if_alone: [{
          key_code: "spacebar",
        }]
       }]
    )]
  end
  def main_rules
    [
      Rule.gen(
        "layer #{@layer_num}: layer_mod-key",
        @layer_keys.map { |key|
          {
            conditions: [
              @cond_is_in_this_layer
            ],
            from: {
              key_code: key,
              modifiers: ModFrom.optional_any
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
