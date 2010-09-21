install: install-vim install-bash install-virtualenvwrapper

install-vim:
	rm -rf ~/.vim ~/.vimrc
	ln -s `pwd`/vim ~/.vim
	ln -s ~/.vim/vimrc ~/.vimrc

install-bash:
	rm -f ~/.bashrc
	ln -s `pwd`/bash/bashrc ~/.bashrc

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs
	ln -s `pwd`/virtualenvwrapper/* ~/.virtualenvs
