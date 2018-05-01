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

  def gen_input_is(src)
    {
      type: "input_source_if",
      input_sources: [
        language: src
      ]
    }
  end

  # module variables
  def is_internal_keyboard
    gen_device_if([
      {vendor_id: 1452},
      {product_id: 610},
    ])
  end
  # layers
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
  # input sources
  def input_is_en
    gen_input_is("en")
  end
  def input_is_zh
    gen_input_is("zh-Hans")
  end
  def input_is_ja
    gen_input_is("ja")
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
    @rules << trigger_rule
    @rules << main_rule
    gen_rules_hook_after()
    @rules
  end

  def trigger_rule
    Rule.gen(
      "layer #{@layer_num} trigger",
      [{
        conditions: [
          Cond.is_layer0,
        ],
        from: {
          key_code: @layer_trigger,
          modifiers: ModFrom.optional_any,
        },
        to: [SetVar.gen("layer", @layer_num)],
        to_after_key_up: [SetVar.gen("layer", 0)],
        to_if_alone: [{
          key_code: @layer_trigger,
        }]
       }]
    )
  end
  def main_rule
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
    # switch input method
    def gen_input_source_rule
      # key => input_source_to_switch_to
      key_maps = [
        ['a', :en],
        ['s', :zh],
        ['d',:ja],
      ]

      # place entry following the order in system keyboard
      cond_map = {
        ja: Cond.input_is_ja,
        en: Cond.input_is_en,
        zh: Cond.input_is_zh,
      }
      sys_next_key = "f18"

      @layer_keys -= key_maps.map { |(k, _)| k }
      len = key_maps.length

      find_src_index = lambda do |src| 
        cond_map.find_index { |k, _| k == src }
      end

      manipulators = (0...len).to_a
        .product((0...len).to_a)
        .map do |(index_to, index_from)|
        _, src_from = key_maps[index_from]
        trigger_key, src_to = key_maps[index_to]
        pos_from = find_src_index.call(src_from)
        pos_to = find_src_index.call(src_to)
        steps = (pos_to - pos_from + len) % len

        {
          conditions: [
            Cond.is_layer1,
            cond_map[src_from]
          ],
            from: {
            key_code: trigger_key,
            modifiers: ModFrom.optional_any,
          },
            to: steps == 0 ? [{ key_code: "vk_none" }] : Array.new(steps, { key_code: sys_next_key})
        }
      end
      Rule.gen(
        "layer #{@layer_num}: switch input source",
        manipulators
      )
    end
    @rules << gen_input_source_rule
  end
end
