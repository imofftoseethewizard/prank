#! /usr/bin/env sh

ROOT_DIR=$( cd ${0%/*} && cd .. &&  pwd -P )

cd $ROOT_DIR

. ./setup.rc

cd test
pytest $1
