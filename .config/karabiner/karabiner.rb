if File.exist?("./private.rb")
  require "./private"
end

module Rule
  module_function
  def gen(desc, manipulators)
    {
      description: desc,
      manipulators: manipulators.map do |m| m.merge({
        type: "basic"
      })
      end
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

  def gen_variable_if(name, value, is = true)
    {
      name: name,
      type: "variable_#{is ? 'if' : 'unless'}",
      value: value
    }
  end

  def gen_input_if(src, is = true)
    {
      type: "input_source_#{is ? 'if' : 'unless'}",
      input_sources: [
        language: src
      ]
    }
  end

  # module variables
  def is_internal_keyboard
    gen_device_if([
      {vendor_id: 1452, product_id: 610},
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

  def input_is_en
    gen_input_if("en")
  end
  def input_is_zh
    gen_input_if("zh-Hans")
  end
  def input_is_ja
    gen_input_if("ja")
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
  def optional_not_fn
    gen_optional([
      "control",
      "option",
      "shift",
      "command",
    ])
  end
  def optional_not_shift
    gen_optional([
      "control",
      "option",
      "command",
    ])
  end
  def mandatory_fn
    gen_mandatory(["fn"])
  end
  def mandatory_control
    gen_mandatory(["control"])
  end
  def mandatory_command
    gen_mandatory(["command"])
  end
  def mandatory_control_command
    gen_mandatory(["control", "command"])
  end
  def mandatory_option
    gen_mandatory(["option"])
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
  def others
    [
      "return_or_enter"
    ]
  end
  def number
    ('1'..'9').to_a << '0'
  end
  def below
    alphabet + symbol_below
  end
  def above
    number + symbol_above
  end
  def whole
    below + above + others
  end
end

class Layer
  @@cond_is_in_layer0 = {
    name: "layer",
    type: "variable_if",
    value: 0,
  }
  def initialize(
    layer_num, layer_trigger,
    layer_mods, layer_keys,
    layer_trigger_mod = ModFrom.optional_any
  )
    @layer_num = layer_num
    @layer_trigger = layer_trigger
    @layer_mods = layer_mods
    @layer_keys = layer_keys
    @layer_trigger_mod = layer_trigger_mod
    @layer_keymap = layer_keys.zip(layer_keys).to_h
    @layer_keymap_filter = []
    @layer_description_prefix = "layer #{@layer_num}"

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
      "#{@layer_description_prefix}: toggle layer",
      [{
        conditions: [
          Cond.is_layer0,
        ],
        from: {
          key_code: @layer_trigger,
          modifiers: @layer_trigger_mod,
        },
        to: [SetVar.gen("layer", @layer_num)],
        to_after_key_up: [SetVar.gen("layer", 0)],
        to_if_alone: [{
          key_code: @layer_trigger,
        }]
       }]
    )
  end
  def main_rule()
    @layer_keymap_filter.each { |k| @layer_keymap.delete(k) }
    Rule.gen(
      "#{@layer_description_prefix}: key -> layer_mod-key",
      @layer_keymap.map { |from_key, to_key|
        layer_manipulator(from_key, to_key)
      }
    )
  end

  def layer_manipulator(from_key, to_key, mod_from = ModFrom.optional_any)
    {
      conditions: [
        @cond_is_in_this_layer
      ],
      from: {
        key_code: from_key,
        modifiers: mod_from
      },
      to: [
        key_code: to_key,
        modifiers: @layer_mods
      ]
    }
  end

  def gen_rules_hook_before
  end

  def gen_rules_hook_after
  end
end

# Basic movements
class Layer1 < Layer
  def initialize(*args)
    super(1, *args)
  end

  def gen_rules_hook_before
    # switch input method
    def input_source_rule_hook
      # key => input_source_to_switch_to
      key_maps = [
        ['s', :en],
        ['d', :zh],
        ['f',:ja],
      ]
      @layer_keymap_filter += key_maps.map { |k, _| k }

      # place entry following the order in system keyboard
      cond_map = {
        en: Cond.input_is_en,
        ja: Cond.input_is_ja,
        zh: Cond.input_is_zh,
      }
      sys_next_key = "f18"
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
            @cond_is_in_this_layer,
            cond_map[src_from],
          ],
          from: {
            key_code: trigger_key,
            modifiers: ModFrom.optional_any,
          },
          to: Array.new(steps, { key_code: sys_next_key})
        }
      end

      @rules << Rule.gen(
        "#{@layer_description_prefix}: switch input source",
        manipulators
      )
    end

    # Cursor movement
    def movement_rule_hook()
      move_key_maps = [
        ['h', 'left_arrow'],
        ['j', 'down_arrow'],
        ['k', 'up_arrow'],
        ['l', 'right_arrow'],
        ['y', 'home'],
        ['u', 'page_down'],
        ['i', 'page_up'],
        ['o', 'end'],
        ['p', 'f6'],
        ['n', 'delete_or_backspace'],
        ['m', 'delete_forward'],
      ]
      move_word_key_maps = [
        ['semicolon', 'left_arrow'],
        ['quote', 'right_arrow']
      ]
      delete_word_key_maps = [
        ['comma', 'left_arrow'],
        ['period', 'right_arrow']
      ]
      @layer_keymap_filter += (move_key_maps + move_word_key_maps + delete_word_key_maps).map { |k, _| k }

      move_manipulators = move_key_maps.map do | f, t| {
        conditions: [
          @cond_is_in_this_layer
        ],
        from: {
          key_code: f,
          modifiers: ModFrom.optional_any,
        },
        to: [
          {key_code: t},
        ],
      }
      end

      move_word_manipulators = move_word_key_maps.map do |f, t|  {
        conditions: [
          @cond_is_in_this_layer
        ],
        from: {
          key_code: f,
          modifiers: ModFrom.optional_any,
        },
        to: [
          {key_code: t, modifiers: ['option']},
        ],
      }
      end

      delete_word_manipulators = delete_word_key_maps.map do |f, t|  {
        conditions: [
          @cond_is_in_this_layer
        ],
        from: {
          key_code: f,
          modifiers: ModFrom.optional_any,
        },
        to: [
          {key_code: t, modifiers: ['option', 'shift']},
          {key_code: 'delete_or_backspace'},
        ],
      }
      end
      @rules << Rule.gen(
        "#{@layer_description_prefix}: basic movements",
        move_manipulators
      )
      @rules << Rule.gen(
        "#{@layer_description_prefix}: word movements",
        move_word_manipulators
      )
      @rules << Rule.gen(
        "#{@layer_description_prefix}: delete word movements",
        delete_word_manipulators
      )
    end

    input_source_rule_hook()
    movement_rule_hook()
  end
end

# Windows Management
class Layer2 < Layer
  def initialize(*args)
    super(2, *args)
  end

  def gen_rules_hook_before
    def private_rule_hook
      if defined?(Private)
        @rules << Rule.gen(
          "#{@layer_description_prefix}: private password",
          [{
            conditions: [
              @cond_is_in_this_layer,
            ],
            from: {
              key_code: "grave_accent_and_tilde",
            },
            to:
            (Private.password.chars.map do |c|
              {key_code: c}
              end) << {key_code: "return_or_enter"}
           }]
        )
      end
    end

    def f_region_rule_hook
      # F Region
      f_map = (KeyRegion.above
        .zip(('1'..'12').map { |x| 'f' + x })).to_h

      @layer_keymap_filter += f_map.keys

      manipulators = f_map.map do |from_key, to_key|
        m = layer_manipulator(from_key, to_key)
        m[:to][0].delete(:modifiers)
        m
      end

      @rules << Rule.gen(
        "#{@layer_description_prefix}: F region",
        manipulators
      )
    end

    private_rule_hook()
    f_region_rule_hook()
  end
end

# F Region, System Control, Media
class Layer3 < Layer
  def initialize(*args)
    super(3, *args)
  end

  def gen_rules_hook_before
    def app_rule_hook
      # Clementine
      app_map = {
        "j" => "5",
        "k" => "6",
        "l" => "7",
        "n" => "8",
        "m" => "9",
      }
      @layer_keymap.merge!(app_map)
    end
    def media_rule_hook
      # Media
      media_map = {
        "o" => "volume_decrement",
        "p" => "volume_increment",
        "i" => "mute",
      }

      @layer_keymap_filter += media_map.keys

      manipulators = media_map.map do |from_key, to_key|
        m = layer_manipulator(from_key, to_key)
        m[:to][0].delete(:modifiers)
        m
      end

      @rules << Rule.gen(
        "#{@layer_description_prefix}: media, F region",
        manipulators
      )
    end

    app_rule_hook()
    media_rule_hook()
  end
end

