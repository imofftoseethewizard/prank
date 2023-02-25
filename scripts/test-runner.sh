#! /usr/bin/env sh

ROOT_DIR=$( cd ${0%/*} && cd .. &&  pwd -P )

cd $ROOT_DIR

. ./setup.rc
. ./test/venv/bin/activate

cd test
pytest
