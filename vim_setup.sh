#!/bin/sh
#
# Ugly hack for setting up vim. Be careful! ;-)
#
set -e

autoload="${HOME}/.vim/autoload"
bundle="${HOME}/.vim/bundle"
vimrc_local="${HOME}/.vimrc"
vimrc_remote="https://raw.githubusercontent.com/elasmo/dot-files/master/.vimrc"

[ ! $(command -v curl) ] && echo "curl not found." && exit $?
[ ! $(command -v git) ] && echo "git not found." && exit $?

[ ! -d ${autoload} ] && echo "Creating ${autoload}." && mkdir -p ${autoload}
[ ! -d ${bundle} ] && echo "Creating ${bundle}." && mkdir -p ${bundle}
[ -e ${vimrc_local} ] && echo "Backing up ${vimrc_local} to ${vimrc_local}.bak." && cp ${vimrc_local} "${vimrc_local}.bak"

echo "Installing ${vimrc_local} from ${vimrc_remote}"; curl -Sso ${vimrc_local} ${vimrc_remote}
[ ! -e ${autoload}/pathogen.vim ] && echo "Installing vim-pathogen." && curl -LSso ${autoload}/pathogen.vim https://tpo.pe/pathogen.vim
[ ! -d ${bundle}/vim-airline ] && echo "Installing vim-airline." && git clone https://github.com/vim-airline/vim-airline ${bundle}/vim-airline
[ ! -d ${bundle}/vim-airline-themes ] && echo "Installing vim-airline-themes." && git clone https://github.com/vim-airline/vim-airline-themes ${bundle}/vim-airline-themes
[ ! -d ${bundle}/vim-fugitive ] && echo  "Installing vim-fugitive." &&  git clone https://github.com/tpope/vim-fugitive ${bundle}/vim-fugitive
[ ! -d ${bundle}/vim-colors-solarized ] && echo "Installing vim-colors-solarized." && git clone https://github.com/altercation/vim-colors-solarized ${bundle}/vim-colors-solarized
