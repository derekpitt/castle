function parse_git_branch {
  ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
    echo "("${ref#refs/heads/}")"
	}

PS1="\w \$(parse_git_branch)$ "


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
