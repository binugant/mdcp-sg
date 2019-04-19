#!/bin/bash -e
# usage: lint.sh


function lint ()
{
  local TEMPLATE=$1

  cfn-lint --ignore-checks W2001 W8001 -t $TEMPLATE
  yamllint -d "{extends: relaxed, rules: {line-length: {max: 150}}}" $TEMPLATE
}

for script in `ls cfn/*yml`; do
  lint $script
done
