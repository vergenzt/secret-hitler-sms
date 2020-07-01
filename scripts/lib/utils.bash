#!/usr/bin/env bash

lookup() {
  gpaste <(echo "$2") <(echo "$1") | awk "\$1 == \"$3\" { print \$2 }"
}

# https://stackoverflow.com/a/37840948
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
