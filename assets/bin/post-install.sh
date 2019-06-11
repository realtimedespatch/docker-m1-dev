#!/bin/bash

bin/n98 db:import sample_data.sql &&
bin/n98 admin:user:create admin support@realtimedespatch.co.uk password123 admin admin &&
docker-compose run --rm php rm -rf var/cache &&
bin/n98 sys:maintenance --off