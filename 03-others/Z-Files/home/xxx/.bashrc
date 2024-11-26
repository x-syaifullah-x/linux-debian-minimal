#!~/.bashrc

command_not_found_handle() { return 127; }

[[ -x /usr/bin/sudo || $UID -eq 0 ]] || sudo() { su -c "PATH=$PATH:/sbin $(printf '%q ' "$@")"; }

shopt -s checkwinsize
shopt -s cmdhist

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

FIRST_RUN=
case "$TERM" in
	xterm-256color | foot)
		trap '[ $FIRST_RUN ] && echo -ne "\e]0;$BASH_COMMAND\a"' DEBUG
		PS1="\$([[ \$? -eq 0 || \$? -eq 130 ]] || echo '\e[31m✘\e[0m ')\[\e]0;Terminal\a\]\$([ \$UID -eq 0 ] && echo '#' || echo '⇰') "
	;;
	*)
		PS1="${debian_chroot:+($debian_chroot)}\$([ \$UID -eq 0 ] && echo '#' || echo '$') "
	;;
esac

PROMPT_COMMAND='
_x="s/^[[:space:]]*[0-9]+[[:space:]]+[A-Za-z]{3}, [0-9]{2} [A-Za-z]{3} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2} //; s/[[:space:]]*$//"
if history | head -n -1 | sed -E "$_x" | grep -Fxq "$(history 1 | sed -E "$_x")"; then
	history -d $((HISTCMD-1)) 2>/dev/null
fi

if [ $FIRST_RUN ]; then
	echo #NEWLINE
else
	FIRST_RUN=0
fi
'

HISTCONTROL=ignorespace:ignoredups:erasedups
HISTFILE=/dev/null
HISTIGNORE='history*:rm*:sudo rm*'
: '
docs :
%d = tanggal
%a = hari
%b = bulan
%Y = Tahun
%H = jam
%M = menit
%S = detik
'
HISTTIMEFORMAT='%a, %d %b %Y %H:%M:%S '