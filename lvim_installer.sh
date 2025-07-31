#!/bin/bash

apt update && apt upgrade -y && apt install tmux git curl g++ cmake automake vim zlib1g-dev libssl-dev openssl bzip2 libbz2-dev libncurses5-dev libncursesw5-dev libffi-dev libreadline-dev sqlite3 libsqlite3-dev liblzma-dev ruby-full -y
export CXX=`which g++`
rm -rf $HOME/.pyenv
curl -fsSL https://pyenv.run | bash

bashrc="$HOME/.bashrc"

cat >>$bashrc << 'EOL'
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
export PATH="$PATH:/opt/nvim-linux64/bin:$HOME/.local/bin"
EOL

sed -i.bak '/\-z "\$PS1"/d' "$bashrc"
source "$bashrc"
pyenv --version

last_python_ver=`pyenv install --list|egrep '^\s*[0-9]'|grep -v [a-z]|tail -n1|sed 's/ //g'`

if [ $last_python_ver == "" ]; then
	echo "error: cannot find lastest python";
	exit -1;
fi

echo "latest python version: $last_python_ver";
pyenv install "$last_python_ver";
pyenv global "$last_python_ver"
pip install --upgrade pip
pip install neovim

gem install neovim

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
npm install -g neovim

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

nvim_zip=nvim-linux64.tar.gz

curl -LO https://github.com/neovim/neovim/releases/download/v0.9.5/$nvim_zip
rm -rf /opt/nvim
tar -C /opt -xzf $nvim_zip
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

cat >> $HOME/.config/lvim/config.lua << EOL
vim.g.python3_host_prog = '$HOME/.pyenv/versions/$last_python_ver/bin/python3'
vim.g.loaded_perl_provider = 0
EOL

lvim +LvimUpdate +LvimSyncCorePlugins +q
