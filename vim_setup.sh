#!/bin/sh
#
# Ugly hack for setting up vim. Be careful! ;-)
#

autoload="${HOME}/.vim/autoload"
bundle="${HOME}/.vim/bundle"
vimrc_local="${HOME}/.vimrc"
vimrc_remote="https://raw.githubusercontent.com/elasmo/dot-files/master/.vimrc"

[ ! -d ${autoload} ] && mkdir -p ${autoload}
[ ! -d ${bundle} ] && mkdir -p ${autoload}
[ -e ${vimrc} ] && cp ${vimrc} "${vimrc}.bak"

curl -Sso ${vimrc_local} ${vimrc_remote}
[ ! -e ${autoload}/pathogen.vim ] && curl -LSso ${autoload}/pathogen.vim https://tpo.pe/pathogen.vim
[ ! -d ${bundle}/vim-airline ] && git clone https://github.com/vim-airline/vim-airline ${bundle}/vim-airline
[ ! -d ${bundle}/vim-airline-themes ] && git clone https://github.com/vim-airline/vim-airline-themes ${bundle}/vim-airline-themes
[ ! -d ${bundle}/vim-fugitive ] && git clone https://github.com/tpope/vim-fugitive ${bundle}/vim-fugitive
[ ! -d ${bundle}/vim-colors-solarized ] && git clone https://github.com/altercation/vim-colors-solarized ${bundle}/vim-colors-solarized
