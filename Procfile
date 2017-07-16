web: bin/rails server -p $PORT -e $RAILS_ENV
resque: QUEUE=mailer rake environment resque:work
