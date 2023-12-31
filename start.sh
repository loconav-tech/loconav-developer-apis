#!/bin/bash
rake meta_endpoints:add_deploy_info

if [[ "$APP" == "sidekiq"  ]] ; then
  bundle exec sidekiq start -c 1
else
  rails server -b 0.0.0.0
fi
