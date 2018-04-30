#!/bin/sh
#
# Ugly hack for setting up vim. Be careful! ;-)
#

autoload="${HOME}/.vim/autoload"
bundle="${HOME}/.vim/bundle"
vimrc_local="${HOME}/.vimrc"
vimrc_remote="https://raw.githubusercontent.com/elasmo/dot-files/master/.vimrc"

[ ! -d ${autoload} ] && echo "Creating ${autoload}.."; mkdir -p ${autoload}
[ ! -d ${bundle} ] && echo "Creating ${bundle}.."; mkdir -p ${bundle}
[ -e ${vimrc} ] && echo "Installing ${vimrc_local}.."; cp ${vimrc_local} "${vimrc}.bak"

curl -Sso ${vimrc_local} ${vimrc_remote}
[ ! -e ${autoload}/pathogen.vim ] && echo -n "Installing vim-pathogen.."; curl -LSso ${autoload}/pathogen.vim https://tpo.pe/pathogen.vim || echo "failed"; exit $?
[ ! -d ${bundle}/vim-airline ] && echo -n "Installing vim-airline.."; git clone https://github.com/vim-airline/vim-airline ${bundle}/vim-airline || echo "failed"; exit $?
[ ! -d ${bundle}/vim-airline-themes ] && echo -n "Installing vim-airline-themes.."; git clone https://github.com/vim-airline/vim-airline-themes ${bundle}/vim-airline-themes || echo "failed"; exit $?
[ ! -d ${bundle}/vim-fugitive ] && echo -n "Installing vim-fugitive.."; git clone https://github.com/tpope/vim-fugitive ${bundle}/vim-fugitive || echo "failed"; exit$?
[ ! -d ${bundle}/vim-colors-solarized ] && "Installing vim-colors-solarized.."; git clone https://github.com/altercation/vim-colors-solarized ${bundle}/vim-colors-solarized || echo "failed"; exit $?
