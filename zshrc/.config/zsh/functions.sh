BLUE='\e[1;34m'
YELLOW_B='\e[1;93m'

# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Mise à jour Système
sys_update () {
	sudo nala update && sudo nala dist-upgrade -y
	flatpak update
	brew update && brew upgrade
}

cd() {
	if [ -n "$1" ]; then
		builtin cd "$1" && clear && eza -a --icons --group-directories-first
	else
		dir=$(find / -type d 2>/dev/null | fzf --preview 'tree -C {}')
		if [ -n "$dir" ]; then
			builtin cd "$dir" && clear && eza -a --icons --group-directories-first
		fi
	fi
}


# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d=""
	limit=$1
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}

# Returns the last 2 fields of the working directory
pwdtail() {
	pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# IP address lookup
alias pubip="whatsmyip"
function whatsmyip ()
{
	# External IP Lookup
	echo -n "External IP: "
	curl -s ifconfig.me
}

# Automatically do an ls for directories after each zoxide
zza ()
{
	if [ -n "$1" ]; then
		__zoxide_z "$@" && eza -a --icons
	else
		__zoxide_z ~ && eza -a --icons
	fi
}

# Automatically do an ls for directories after each zoxide
zz ()
{
	if [ -n "$1" ]; then
		__zoxide_z "$@" && eza -aD --icons
	else
		__zoxide_z ~ && eza -aD --icons
	fi
}

# Automatically do an ls after each zoxide
zze ()
{
	if [ -n "$1" ]; then
		__zoxide_z "$@" && eza -alh --icons --group-directories-first
	else
		__zoxide_z ~ && eza -alh --icons --group-directories-first
	fi
}

gitnewfolder ()
{
	git init
	touch README.md
	git add README.md
	git commit -m "..."
	git branch -M main
	git remote add origin git@github.com:YehneeN/$(basename "$PWD").git
}

# Start Networking Toolbox
Net_Toolbox() {
    cd /home/rfontaine/Documents/Scripts/Dockers/Networking-Toolbox || exit
    clear

    case "$1" in
        Start)
            echo -e "${YELLOW_B}Démarrage de la webApp Networking toolbox\n"\
                    "Pour clôturer l'accès --> Net_Toolbox stop.\n\n"\
                    "${BLUE} ---- http://localhost:3000 ---- \n\n"

            sudo docker compose up -d
            while ! nc -z localhost 3000; do
                sleep 1
            done
#            xdg-open "http://localhost:3000"
            ;;
        Stop)
            echo -e "${YELLOW_B}Arrêt de la webApp Networking toolbox\n"
            sudo docker compose down
            ;;
        *)
            echo -e "${RED}Usage : Net_Toolbox Start|Stop"
            ;;
    esac
}

convertX() {
	cd /home/rfontaine/Documents/Scripts/Dockers/ConvertX || exit
	clear

	case "$1" in
		Start)
			echo -e "${YELLOW_B}Démarrage de la webApp ConvertX\n"\
				"Pour clôturer l'accès --> convertX Stop.\n\n"\
				"${BLUE} ---- http://localhost:3000 ----\n\n"

			sudo docker compose up -d
			while ! nc -z localhost 3000; do
				sleep 1
			done
			;;
		Stop)
			echo -e "${YELLOW_B}Arrêt de la webApp ConvertX\n"
			sudo docker compose down
			;;
		*)
			echo -e "${RED} Usage: convertX Start|Stop"
			;;
	esac
}


# Start Networking Toolbox
IT_Toolbox() {
    cd /home/rfontaine/Documents/Scripts/Dockers/IT-Tools || exit
    clear

    case "$1" in
        Start)
            echo -e "${YELLOW_B}Démarrage de la webApp IT Toolbox\n"\
                    "Pour clôturer l'accès --> IT_Toolbox stop.\n\n"\
                    "${BLUE} ---- http://localhost:3580 ---- \n\n"

            sudo docker compose -f docker-compose.yaml up -d
            while ! nc -z localhost 3580; do
                sleep 1
            done
#            xdg-open "http://localhost:3000"
            ;;
        Stop)
            echo -e "${YELLOW_B}Arrêt de la webApp IT Toolbox\n"
            sudo docker compose -f docker-compose.yaml down
            ;;
        *)
            echo -e "${RED}Usage : IT_Toolbox Start|Stop"
            ;;
    esac
}

# Start IT_Service sync
IT_sharepoint() {
	case "$1" in
		mount)
			echo -e "${YELLOW_B}Montage DATA_CLIENT\n"
			rclone mount ITService: /mnt/SSD2/IT_Service \
                --vfs-cache-mode full \
                --vfs-write-back 10s \
                --vfs-cache-max-age 24h \
                --cache-dir /mnt/SSD2/.rclone_cache \
                --buffer-size 16M \
                --transfers 2 \
                --checkers 4 \
                --dir-cache-time 1m \
                --use-mmap \
                --exclude "/.Trash-*/**" \
                -vv --log-file=/mnt/SSD2/logs/rclone-vfs2.log &
			echo -e "${YELLOW_B}Démontage = IT_sharepoint unmount\n"
			;;
		unmount)
			echo -e "${YELLOW_B}Démontage DATA_CLIENT\n"
			fusermount -u /mnt/SSD2/IT_Service
			;;
		*)
			echo -e "${RED}Usage : IT_sharepoint mount|unmount"
			;;
	esac
}

# Start OneDrive sync
OneDrive_RF() {
	case "$1" in
		mount)
			echo -e "${YELLOW_B}Montage OneDrive\n"
			rclone --vfs-cache-mode writes mount OneDrive: /mnt/SSD2/OneDrive-RF &
			echo -e "${YELLOW_B}Démontage = OneDrive_RF unmount\n"
			;;
		unmount)
			echo -e "${YELLOW_B}Démontage OneDrive\n"
			fusermount -u /mnt/SSD2/OneDrive-RF
			;;
		*)
			echo -e "${RED}Usage : OneDrive_RF mount|unmount"
			;;
	esac
}


# Start Excalidraw
Excalidraw() {
    case "$1" in
        Start)
            echo -e "${YELLOW_B}Démarrage de la webApp Excalidraw\n"\
                    "Pour clôturer l'accès --> Excalidraw stop.\n\n"\
                    "${BLUE} ---- http://localhost:5000 ---- \n\n"

            docker run --rm -dit --name excalidraw -p 5000:80 excalidraw/excalidraw
            while ! nc -z localhost 5000; do
                sleep 1
            done
#            xdg-open "http://localhost:5000"
            ;;
        Stop)
            echo -e "${YELLOW_B}Arrêt de la webApp Excalidraw\n"
            docker stop excalidraw > /dev/null
            ;;
        *)
            echo -e "${RED}Usage : Excalidraw Start|Stop"
            ;;
    esac
}

# Start LDFM
ldfm() {
    case "$1" in
        Start)
            cd ~/Documents/Scripts/Dockers/ldfm
            echo -e "${YELLOW_B}Démarrage des containers LDFM \n"\
                    "Pour clôturer l'accès --> ldfm Stop.\n\n"\
                    "${BLUE} ---- https://localhost ---- \n\n"
            sh ./sh/start.sh

            ;;
        Stop)
            cd ~/Documents/Scripts/Dockers/ldfm
            echo -e "${YELLOW_B}Arrêt des containers LDFM\n"
            sh ./sh/down.sh
            ;;
        *)
            echo -e "${RED}Usage : ldfm Start|Stop"
            ;;
    esac
}

# Start Winapps
#vmWin() {
#	case "$1" in
#		Start)
#			echo -e "${YELLOW_B}Démarrage de WinApps\n"\
#				"Pour arrêter le container --> vmWin Stop. \n\n"
#
#			docker compose --file /mnt/HDD2/WinApps/compose.yaml start
#			;;
#		Stop)
#			echo -e "${YELLOW_B}Arrêt de WinApps\n"
#			docker compose --file /mnt/HDD2/WinApps/compose.yaml stop
#			;;
#		*)
#			echo -e "${RED}Usage: vmWin Start|Stop"
#			;;
#	esac
#}
