prodcon() {
	if [[ "$1" == "--log" ]]; then
		
		# Log output to a file with a timestamped filename
		DATE="$(date +"%Y%m%d%H%M")"
		LOG_PATH="~/logs/console/$DATE.log"

		echo "Starting console with log $LOG_PATH"
    heroku run yarn workspace api console --app obie-private-rm-production 2>&1 | tee "/Users/schester/logs/console/$DATE.log"
  else
    # Run without logging
    heroku run yarn workspace api console --app obie-private-rm-production
  fi
}
