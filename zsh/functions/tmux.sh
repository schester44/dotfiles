t() {
 session=$(sesh list -t -c | fzf --height 40% --border-label ' sesh ' --border)

 if [ -n "$session" ]; then
	 sesh connect "$session"
 fi
}
