#!/bin/bash

# Make API request to whatismyip.com and retrieve response
response=$(curl 'https://api.whatismyip.com/wimi.php' \
  -X 'POST' \
  -H 'authority: api.whatismyip.com' \
  -H 'accept: */*' \
  -H 'accept-language: en-GB,en;q=0.9' \
  -H 'content-length: 0' \
  -H 'origin: https://www.whatismyip.com' \
  -H 'referer: https://www.whatismyip.com/' \
  -H 'sec-ch-ua: "Google Chrome";v="111", "Not(A:Brand";v="8", "Chromium";v="111"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-site' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36' \
  --compressed)

# Extract IPv4 address from response using grep and cut
my_ip=$(echo "$response" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | cut -d' ' -f1)

terraform destroy -auto-approve -var "my_ip=${my_ip}"
