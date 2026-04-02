# Edit .zshrc file
alias ezrc='vim ~/.dotfiles/zshrc/.zshrc'
alias ezalias='vim ~/.dotfiles/zshrc/.config/zsh/aliases.sh'
alias ezfunction='vim ~/.dotfiles/zshrc/.config/zsh/functions.sh'
alias ezbind='vim ~/.dotfiles/hypr/.config/hypr/sFiles/keybinds.conf'

# Change directory aliases
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's eza lists
alias ls='eza -a --icons --group-directories-first' 			# add colors, icons, group directories
alias lf='eza -af --icons'  									# files only
alias ld='eza -aD --icons'										# directories only
alias ll='eza -alh --icons --group-directories-first'			# long listing format
alias lfiles='eza -alhf --icons'   								# long format, files only
alias ldirs='eza -alhD --icons'   								# long format, directories only
alias lx='eza -alhfs extension --icons '   						# sort files by extension
alias lk='eza -alhrs size --icons --group-directories-first'		# sort by size
alias lc='eza -alhrs changed --icons --group-directories-first'	# sort by change time
alias la='eza -alhrs accessed --icons --group-directories-first'	# sort by access time
alias lt='eza -alhrs created --icons --group-directories-first'	# sort by date
alias lr='eza -alR --icons --group-directories-first'	# recursive ls

# Alias's for eza trees
alias tree="eza -Ta --icons --group-directories-first"				# Tree all the way, use -L to control depth
alias treemin="eza -Ta --icons -L 2 --group-directories-first"		# Tree into 1 subfolder level
alias treed="eza -TaD --icons"										# Tree directories all the way, use -L to control depth
alias treedmin="eza -TaD --icons -L 2"								# Tree directories into 1 subfolder level							# Tree directories into 1 subfolder level

# Search command line history
alias h="history | grep "

# Search running processes
alias p="ps aux | grep "

# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Alias's to modified commands
alias cat="bat"
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias less='less -R'
alias pacman='sudo pacman'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'
alias curl="curl -#"
alias goTrash="cd ~/.local/share/Trash"
alias powershell="pwsh" 

# Personal Alias's
alias sht="sudo shutdown -P now"
alias rbt="sudo shutdown -r now"
alias ff="fastfetch"
alias zi="__zoxide_zi"
alias reload="source ~/.zshrc"
alias iptables="sudo iptables"
alias dl="z ~/Téléchargements && ls"
alias passgen="openssl rand -base64 16"
alias meteo="curl wttr.in"
alias monip="curl -4 monip.org"

# System Monitoring
alias meminfo='free -m -l -t' # Show free and used memory
alias memhog='ps -eo pid,ppid,cmd,%mem --sort=-%mem | head' # Processes consuming most mem
alias cpuhog='ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head' # Processes consuming most cpu
alias cpuinfo='lscpu' # Show CPU Info
alias distro='cat /etc/*-release' # Show OS info
alias ports='netstat -tulanp' # Show open ports

# dufs
#alias dufsup='dufs --allow-upload $HOME/Documents/Share'

# Scan clam
alias avscan='clamscan -r --bell -i $1'

# Sudo commands
alias docker='sudo docker'
alias exegol='sudo $(echo ~/.local/bin/exegol)'
alias cruise='sudo cruise'

