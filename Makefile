install: install-vim install-bash install-virtualenvwrapper \
         install-terminal-settings install-git \
	 install-python install-keybindings

install-vim:
	rm -rf ~/.vim ~/.vimrc
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc

install-bash:
	rm -f ~/.bashrc
	ln -s `pwd`/bash/bashrc ~/.bashrc

install-git:
	rm -f ~/.gitconfig
	ln -s `pwd`/git/gitconfig ~/.gitconfig

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -s `pwd`/virtualenvwrapper/* ~/.virtualenvs

install-python:
	rm -f ~/.pythonstartup.py
	ln -s `pwd`/python/pythonstartup.py ~/.pythonstartup.py

dump-terminal-settings:
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal
	plutil -convert xml1 terminal/com.apple.Terminal.plist

install-terminal-settings:
ifeq ($(shell uname),Darwin)
	cp ~/Library/Preferences/com.apple.Terminal.plist terminal/old-settings.bak
	cp terminal/com.apple.Terminal.plist ~/Library/Preferences
	@echo "Old terminal settings were saved in terminal folder"
endif

install-keybindings:
	rm -f ~/Library/KeyBindings/DefaultKeyBinding.dict
	mkdir -p ~/Library/KeyBindings
	ln -s `pwd`/osx/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
