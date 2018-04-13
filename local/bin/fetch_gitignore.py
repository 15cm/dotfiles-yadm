#!/usr/bin/env python3
import requests
import os

#https://github.com/15cm/gitignore

ignore_src_names = [
    'macOS',
    'JetBrains',
    'Emacs',
    'Xcode',
    'JEnv',
    'Vim',
    'Tags',
    'Windows',
    'Emacs'
]

github_link_template = 'https://raw.githubusercontent.com/15cm/gitignore/master/Global/{0}.gitignore'
local_ignore_file = os.path.expanduser('~/.gitignore_global.local')
ignore_file = os.path.expanduser('~/.gitignore_global')

ignore_src_links = map(lambda x: github_link_template.format(x), ignore_src_names)
remote_ignore_texts = map(lambda link: requests.get(link).text, ignore_src_links)
with open(local_ignore_file) as f:
    local_ignore_lines = f.readlines()

with open(ignore_file, 'w') as f:
    f.writelines(local_ignore_lines + list(map(lambda txt: txt + '\n', remote_ignore_texts)))

