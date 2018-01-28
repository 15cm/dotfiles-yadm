#!/usr/bin/env python3
import requests
import os
from functional import seq

ignore_src_names = [
    'macOS',
    'JetBrains',
    'Emacs',
    'Xcode',
    'JEnv',
    'Vim',
    'Tags'
]

github_link_template = 'https://raw.githubusercontent.com/github/gitignore/master/Global/{0}.gitignore'
local_ignore_file = os.path.expanduser('~/.gitignore_global_local')
ignore_file = os.path.expanduser('~/.gitignore_global')

ignore_src_links = map(lambda x: github_link_template.format(x), ignore_src_names)
remote_ignore_texts_seq = seq(ignore_src_links).map(lambda link: requests.get(link).text)
with open(local_ignore_file) as f:
    local_ignore_lines = f.readlines()

with open(ignore_file, 'w') as f:
    f.writelines(local_ignore_lines + remote_ignore_texts_seq.map(lambda txt: txt + '\n').to_list())

