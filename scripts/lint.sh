#!/bin/bash -e
# usage: lint.sh


function lint ()
{
  local TEMPLATE=cfn/$1

  cfn-lint --ignore-checks W2001 W8001 -t $TEMPLATE
  yamllint -d "{extends: relaxed, rules: {line-length: {max: 150}}}" $TEMPLATE
}

pip install yamllint

for script in `ls cfn`; do
  lint $script
done
