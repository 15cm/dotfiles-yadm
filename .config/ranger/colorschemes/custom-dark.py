from ranger.colorschemes.default import Default

from ranger.gui.color import (
    black, blue, cyan, green, magenta, red, white, yellow, default,
    normal, bold, reverse,
    default_colors,
)

class Scheme(Default):

    def use(self, context):
        fg, bg, attr = Default.use(self, context)
        return fg, bg, attr
