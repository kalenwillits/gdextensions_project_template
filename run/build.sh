#!/bin/bash

set -xe
scons target=template_debug;
scons target=template_release;
