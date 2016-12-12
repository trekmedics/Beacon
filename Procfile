web: bundle exec puma -t ${PUMA_MIN_THREADS:-8}:${PUMA_MAX_THREADS:-12} -w ${PUMA_WORKERS:-2} -p 5000 -e ${RACK_ENV:-$RAILS_ENV}
worker_queue: bundle exec env TERM_CHILD=1 bundle exec rake resque:work QUEUE=* RAILS_ENV=$RAILS_ENV
worker_scheduler: bundle exec env TERM_CHILD=1 bundle exec rake resque:scheduler VERBOSE=1 RAILS_ENV=$RAILS_ENV RESQUE_SCHEDULER_INTERVAL=2
