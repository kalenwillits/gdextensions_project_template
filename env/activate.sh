#!/bin/bash
set -xe
export CPLUS_INCLUDE_PATH=\
$PWD/src:\
$PWD/godot-cpp/gen/include:\
$PWD/godot-cpp/include:\
$PWD/godot-cpp/gdextension;
