/*
  Set any config.h overrides for your specific keymap here.
  See config.h options at https://docs.qmk.fm/#/config_options?id=the-configh-file
*/
// Fix QMK dual role key slow on Ergodox EZ
// https://www.reddit.com/r/olkb/comments/7oe2sa/qmk_dual_role_key_slow_on_ergodox_ez/
#undef IGNORE_MOD_TAP_INTERRUPT

#undef DEBOUNCE
#define DEBOUNCE    5
