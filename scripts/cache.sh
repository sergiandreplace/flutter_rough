#!/bin/bash
file_location=~/.pub-cache/credentials.json
if [ -e $policy ]; then
  echo "File $1.json already exists!"
else
  cat > $file_location <<EOF
$CACHED_JSON
EOF
fi
