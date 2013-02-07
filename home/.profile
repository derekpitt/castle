# Set git autocompletion and PS1 integration
if [ -f /usr/local/git/contrib/completion/git-completion.bash ]; then
	. /usr/local/git/contrib/completion/git-completion.bash
fi
GIT_PS1_SHOWDIRTYSTATE=true

if [ -f /opt/local/etc/bash_completion ]; then
	. /opt/local/etc/bash_completion
fi

PS1='\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\] >> '


alias serve='python -m SimpleHTTPServer'


alias gs='git status'

export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin
