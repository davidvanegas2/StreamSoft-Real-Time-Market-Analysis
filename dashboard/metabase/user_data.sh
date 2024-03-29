#!/bin/bash
sudo yum install docker -y
sudo service docker start
sudo docker pull metabase/metabase:latest
sudo docker run -d -p 80:3000 --name metabase metabase/metabase
sleep 1m

# Wait until Metabase is up
while true; do
    echo "Checking if Metabase is up..."
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/api/health)

    if [ "$response" -eq 200 ]; then
        echo "Metabase is up and running!"
        break
    else
        echo "Metabase is not up yet. Waiting..."
        sleep 10
    fi
done

current_response=$(curl -s -m 5 -X GET \
                    -H "Content-Type: application/json" \
                    http://localhost:80/api/session/properties
                    )

SETUP_TOKEN=$(echo "$current_response" | jq -r '.["setup-token"]')
export SETUP_TOKEN

create_admin_response=$(curl -s -X POST \
  -H "Content-type: application/json" \
  http://localhost:80/api/setup \
  -d '{
    "token": "'${SETUP_TOKEN}'",
    "user": {
        "email": "user@test.test",
        "first_name": "User",
        "last_name": "Name",
        "password": "MySecretPassword1"
    },
    "prefs": {
        "allow_tracking": true,
        "site_name": "My Metabase Instance"
    }
  }')

SESSION_TOKEN=$(echo "$create_admin_response" | jq -r '.id')
export SESSION_TOKEN

curl 'http://localhost:80/api/database' \
  -H 'Content-Type: application/json' \
  -H 'X-Metabase-Session: '"$SESSION_TOKEN"'' \
  --data-raw '{"is_on_demand":false,"is_full_sync":true,"is_sample":false,"cache_ttl":null,"refingerprint":false,"auto_run_queries":true,"schedules":{},"details":{"region":"us-west-2","workgroup":"streaming_workgroup","s3_staging_dir":null,"catalog":null,"access_key":null,"secret_key":null,"advanced-options":false},"name":"dashboard_data","engine":"athena"}'
