#!/bin/bash
rm $FLUTTER_ROOT/.pub-cache/credentials.json 2> /dev/null
echo $CACHED_JSON > $FLUTTER_ROOT/.pub-cache/credentials.json

