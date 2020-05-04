#!/bin/bash
rm ~/.pub-cache/credentials.json 2> /dev/null
mkdir ~/.pub-cache 2> /dev/null
echo $CACHED_JSON > ~/.pub-cache/credentials.json

