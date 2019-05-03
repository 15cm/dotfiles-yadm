require './karabiner'

module Conf
  module_function
  def basic_rules
    [
      Rule.gen(
        "(internal) fn-caps_lock: caps_lock",
        [{
            conditions: [
              Cond.is_internal_keyboard,
            ],
            from: {
              key_code: "caps_lock",
              modifiers: ModFrom.mandatory_fn,
            },
            to: [{key_code: "caps_lock"}],
          }],
      ),
      Rule.gen(
        '(internal) caps_lock: escape, left_control',
        [{
          conditions: [
            Cond.is_internal_keyboard,
          ],
          from: {
            key_code: 'caps_lock',
            modifiers: ModFrom.optional_not_fn,
          },
          to: [{ key_code: "left_control"}],
          to_if_alone: [{ key_code: "escape"}],
         }]
      ),
      Rule.gen(
        '(internal) left_command: f7, left_gui',
        [{
          conditions: [
            Cond.is_internal_keyboard,
          ],
          from: {
            key_code: 'left_gui',
            modifiers: ModFrom.optional_any
          },
          to: [{ key_code: "left_gui"}],
          to_if_alone: [{ key_code: "f7"}],
         }]
      ),
    ]
  end

  # Layer1
  def layer1_trigger
    "spacebar"
  end
  def layer1_mods
    [
    "command",
    "control",
    ]
  end
  def layer1_keys
    KeyRegion.whole
  end

  # Layer2
  def layer2_trigger
    "tab"
  end
  def layer2_mods
    [
      "command",
      "option",
      "control",
    ]
  end
  def layer2_keys
    KeyRegion.whole
  end

  # Layer3
  def layer3_trigger
    "grave_accent_and_tilde"
  end
  def layer3_mods
    [
      "control",
      "shift",
      "option",
    ]
  end
  def layer3_keys
    KeyRegion.below
  end

  # final conf
  def layers
    [
      Layer1.new(layer1_trigger, layer1_mods, layer1_keys),
      Layer2.new(layer2_trigger, layer2_mods, layer2_keys),
      Layer3.new(layer3_trigger, layer3_mods, layer3_keys, ModFrom.optional_not_shift),
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
            "basic.to_delayed_action_delay_milliseconds": 500,
          },
          rules: gen_rules()
        }
      }]
    }
  end
end
