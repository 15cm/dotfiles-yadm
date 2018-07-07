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

module App
  module_function
  def name2bundle_id(name)
    name_bid_map =
    {
      telegram: "^org\\.telegram\\.desktop.*",
      microsoft_office: "^com\\.microsoft\\..*",
      alacritty: "^io\\.alacritty.*",
      emacs: "^org\\.gnu\\.Emacs.*",
      iterm: "^com\\.googlecode\\.iterm2.*",
      terminal: "^com\\.apple\\.com\\.Terminal.*",
      jetbrains: "^com\\.jetbrains\\..*",
      xcode: "^com\\.apple\\.dt\\.Xcode.*",
      firefox: "^org\\.mozilla\\.firefox.*",
      parallel_desktop: "com\\.parallels\\.desktop.*",
    }
  name_bid_map[name]
  end
  def editors
    [
      :emacs,
    ]
  end
  def terminals
    [
      :alacritty,
      :iterm,
      :terminal,
    ]
  end
  def ides
    [
      :jetbrains,
      :xcode,
    ]
  end
  def keymap_total_emacs
    editors + terminals
  end
  def keymap_partial_emacs
    ides
  end
  def keymap_need_home_end
    [
      :telegram,
      :microsoft_office,
    ]
  end
  def firefox
    [
      :firefox
    ]
  end
  def parallel_desktop
    [
      :parallel_desktop
    ]
  end
end

module T1
  module_function
  def f1
    1
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
  def gen_application_if(app_names, is = true)
    bundle_ids = app_names.map { |name| App.name2bundle_id(name) }
    {
      bundle_identifiers: bundle_ids,
      type: "frontmost_application_#{is ? 'if' : 'unless'}",
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

  def input_is_en
    gen_input_if("en")
  end
  def input_is_zh
    gen_input_if("zh-Hans")
  end
  def input_is_ja
    gen_input_if("ja")
  end

  def app_keymap_not_total_emacs
    gen_application_if(App.keymap_total_emacs + App.parallel_desktop, false)
  end
  def app_keymap_not_partial_nor_total_emacs
    gen_application_if(App.keymap_partial_emacs + App.keymap_total_emacs + App.parallel_desktop, false)
  end
  def app_keymap_need_home_end
    gen_application_if(App.keymap_need_home_end)
  end
  def app_is_firefox
    gen_application_if(App.firefox)
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

# Application Launcher, Input Source Switching
class Layer1 < Layer
  def initialize(*args)
    super(1, *args)
  end

  def gen_rules_hook_before
    # switch input method
    def input_source_rule_hook
      # key => input_source_to_switch_to
      key_maps = [
        ['a', :en],
        ['s', :zh],
        ['d',:ja],
      ]
      @layer_keymap_filter += key_maps.map { |k, _| k }

      # place entry following the order in system keyboard
      cond_map = {
        ja: Cond.input_is_ja,
        en: Cond.input_is_en,
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
    input_source_rule_hook()
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
    def special_rule_hook
      special_map = {
        "h" => "left_arrow",
        "j" => "down_arrow",
        "k" => "up_arrow",
        "l" => "right_arrow",
        "y" => "home",
        "u" => "page_down",
        "i" => "page_up",
        "o" => "end",
        "comma" => "f12",
        "period" => "f6",
      }
      @layer_keymap_filter += special_map.keys

      manipulators = special_map.map do |from_key, to_key|
        m = layer_manipulator(from_key, to_key)
        m[:to][0].delete(:modifiers)
        m
      end

      @rules << Rule.gen(
        "#{@layer_description_prefix}: direction, Tmux prefix, Firefox switch frame",
        manipulators
      )
    end

    private_rule_hook()
    special_rule_hook()
  end
end

# F Region, System Control, Media
class Layer3 < Layer
  def initialize(*args)
    super(3, *args)
  end

  def gen_rules_hook_before
    def special_main_rule_hook
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
    def special_rule_hook
      # Media
      media_map = {
        "o" => "volume_decrement",
        "p" => "volume_increment",
        "i" => "mute",
      }


      # F Region
      f_map = (KeyRegion.above
        .zip(('1'..'12').map { |x| 'f' + x })).to_h

      special_map = media_map.merge(f_map)
      @layer_keymap_filter += special_map.keys

      manipulators = special_map.map do |from_key, to_key|
        m = layer_manipulator(from_key, to_key)
        m[:to][0].delete(:modifiers)
        m
      end

      @rules << Rule.gen(
        "#{@layer_description_prefix}: media, F region",
        manipulators
      )
    end

    special_main_rule_hook()
    special_rule_hook()
  end
end

