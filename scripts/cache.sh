#!/bin/bash
file_location=~/.pub-cache/credentials.json
if [ -e $policy ]; then
  rm file_location
  echo "deleting"
fi

cat > $file_location <<EOF
$CACHED_JSON
EOF
echo "done"

