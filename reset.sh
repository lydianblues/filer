#!/bin/bash
dropdb -Uquosap filer_development
createdb -E UTF-8 -U quosap -T template0 -O quosap filer_development
bundle exec rake db:migrate
# bundle exec rake db:seed
