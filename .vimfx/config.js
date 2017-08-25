const MAPPINGS = {
  'tab_select_previous': 'K',
  'tab_select_next': 'J'
}

const VIMFX_PREFS = {
  'prevent_autofocus': true
}

let {commands} = vimfx.modes.normal

const CUSTOM_COMMANDS = [
  [
    {
      name: 'search_tabs',
      description: 'Search tabs',
      category: 'tabs',
      order: commands.focus_location_bar.order + 1,
    },
    (args) => {
      let {vim} = args
      let {gURLBar} = vim.window
      gURLBar.value = ''
      commands.focus_location_bar.run(args)
      // Change the `*` on the text line to a `%` to search tabs instead of bookmarks.
      gURLBar.value = '% '
      gURLBar.onInput(new vim.window.KeyboardEvent('input'))
    },
    'T'
  ]
]

// Apply The Above

CUSTOM_COMMANDS.forEach(([options, fn, key]) => {
  vimfx.addCommand(options, fn)
  vimfx.set(`custom.mode.normal.${options['name']}`, key)
})

Object.entries(MAPPINGS).forEach(([command, value]) => {
  const [shortcuts, mode] = Array.isArray(value)
        ? value
        : [value, 'mode.normal']
  vimfx.set(`${mode}.${command}`, shortcuts)
})

Object.entries(VIMFX_PREFS).forEach(([pref, valueOrFunction]) => {
  const value = typeof valueOrFunction === 'function'
        ? valueOrFunction(vimfx.getDefault(pref))
        : valueOrFunction
  vimfx.set(pref, value)
})
