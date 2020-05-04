#!/bin/bash
rm ~/.pub-cache/credentials.json
echo $CACHED_JSON > ~/.pub-cache/credentials.json
echo "done"
echo $CACHED_JSON
echo "la cosa:"
cat ~/.pub-cache/credentials.json

