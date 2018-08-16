#!/bin/bash
kquitapp5 plasmashell && kstart5 plasmashell > /dev/null 2>&1 &
systemctl --user restart xsession.target
