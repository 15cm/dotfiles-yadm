require './karabiner'

module Conf
  module_function
  def gen_emacs_manipulator(from_keycode, from_mods, to_keys, app_cond = nil)
    rc = {
      from: {
        key_code: from_keycode,
        modifiers: from_mods,
      },
      to: to_keys,
    }
    if app_cond
      rc[:conditions] = [app_cond]
    end
    rc
  end
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
        '(interval) caps_lock: escape, left_control',
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
        'emacs keymap: up/down/left/right/delete_forward',
        [
          ['p', 'up_arrow'],
          ['n', 'down_arrow'],
          ['b', 'left_arrow'],
          ['f', 'right_arrow'],
          ['d', 'delete_forward'],
        ].map { |(f, t)| [f, [{key_code: t}]] }
        .map { |from_keycode, to_keys| gen_emacs_manipulator(from_keycode, ModFrom.mandatory_control, to_keys, Cond.app_keymap_not_partial_nor_total_emacs) }
      ),
      Rule.gen(
        'emacs keymap: home/end/kill_to_end',
        (lambda do
            single_tokeys =
              [
              ['a', 'home'],
              ['e', 'end'],
              ].map { |f, t| [f, [{key_code: t}]] }
            complex_tokeys =
              [
              ['k', [
               {
                  key_code: 'end',
                  modifiers: ['fn', 'shift'],
               },
               {
                 key_code: 'delete_or_backspace'
               }
             ]],
              ]
            (single_tokeys + complex_tokeys)
            .map { |from_keycode, to_keys| gen_emacs_manipulator(from_keycode, ModFrom.mandatory_control, to_keys, Cond.app_keymap_need_home_end) }
          end).call
      ),
      Rule.gen(
        'emacs keymap: delete',
        [
          ['h', 'delete_or_backspace']
        ].map { |f, t| [f, [{key_code: t}]] }
        .map{ |from_keycode, to_keys| gen_emacs_manipulator(from_keycode, ModFrom.mandatory_control, to_keys, Cond.app_keymap_not_partial_nor_total_emacs) }
      ),
      Rule.gen(
        'emacs keymap: back/forward/delete_back/delete_forward a word',
        (lambda do
            moves = [
              ['b', 'left_arrow'],
              ['f', 'right_arrow'],
            ].map do |f, t|
              [
                f, [{
                  key_code: t,
                  modifiers: ['option']
                 }]
              ]
            end
            deletes = [
              ['h', 'left_arrow'],
              ['d', 'right_arrow'],
            ].map do |f, t|
              [
                f, [
                  {
                    key_code: t,
                    modifiers: ['option', 'shift'],
                  },
                  {
                    key_code: 'delete_or_backspace'
                  }
             ]
              ]
            end
            (moves + deletes)
            .map { |from_keycode, to_keys| gen_emacs_manipulator(from_keycode, ModFrom.mandatory_option, to_keys, Cond.app_keymap_not_total_emacs) }
          end).call
      ),
      Rule.gen(
        'command-control-u/d: page_up/page_down',
        [
          ['u', 'page_up'],
          ['d', 'page_down'],
        ].map do |from_keycode, to_keycode|
          {
            from: {
              key_code: from_keycode,
              modifiers: ModFrom.mandatory_control_command,
            },
            to: [{ key_code: to_keycode }]
          }
        end
      ),
      Rule.gen(
        'command-semicolon: f6(Firefox)',
        [{
          conditions: [
            Cond.app_is_firefox,
          ],
          from: {
            key_code: 'semicolon',
            modifiers: ModFrom.mandatory_command,
          },
          to: [{ key_code: 'f6' }]
         }]
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
      "command",
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
          },
          rules: gen_rules()
        }
      }]
    }
  end
end
