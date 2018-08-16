#!/bin/bash
/bin/sh -c 'kquitapp5 plasmashell && kstart5 plasmashell && exit'
systemctl --user restart xsession.target
