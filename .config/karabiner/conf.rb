require './karabiner'

module Conf
  module_function
  def basic_rules
    [
      Rule.gen(
        "(internal) fn-caps_lock: caps_lock",
        [
          {
            conditions: [
              Cond.is_internal_keyboard
            ],
            from: {
              key_code: "caps_lock",
              modifiers: ModFrom.mandatory_fn
            },
            to: [
              {key_code: "caps_lock"}
            ],
          }
        ],
      )
    ]
  end

  # Layer1
  def layer1_trigger
    "spacebar"
  end
  def layer1_mods
    [
    "command",
    "shift",
    "option",
    ]
  end
  def layer1_keys
    KeyRegion.whole
  end

  # final conf
  def layers
    [
      Layer1.new(layer1_trigger, layer1_mods, layer1_keys),
    ]
  end

  def gen_rules()
    layers.inject(basic_rules) { |acc, layer| acc + layer.gen_rules }
  end
  def gen()
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
          rules: gen_rules()
        }
      }]
    }
  end
end
