#! /usr/bin/env sh

ROOT_DIR=$( cd ${0%/*} && cd .. &&  pwd -P )

cd $ROOT_DIR

VENV_DIR=${1:-$ROOT_DIR/test/venv}
PYTHON=${PYTHON:-python}

echo "Using $PYTHON to create virtual env in $VENV_DIR"

${PYTHON} -m venv $VENV_DIR --prompt test-crack
. $VENV_DIR/bin/activate
pip install -r $ROOT_DIR/test/requirements.txt
