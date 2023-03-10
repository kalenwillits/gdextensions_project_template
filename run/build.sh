#!/bin/bash

set -xe
python3 run/build_register_types.py;
scons target=template_debug;
scons target=template_release;
