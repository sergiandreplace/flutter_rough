#!/bin/bash
file_location=~/.pub-cache/credentials.json
if [ -e $policy ]; then
  echo "File already exists!"
else
  cat > $file_location <<EOF
$CACHED_JSON
EOF
fi
