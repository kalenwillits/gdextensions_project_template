#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.


def parse_globs(dir_path):
    sources.append(Glob(f"{dir_path}*.cpp"))
    for filename in os.listdir(dir_path):
        if os.path.isdir(f"{dir_path}/{filename}"):
            parse_globs(f"{dir_path}/{filename}")

env.Append(CPPPATH=["src/"])

sources = []
parse_globs("src/")


if env["platform"] == "macos":
    library = env.SharedLibrary(
        "app/bin/lib.{}.{}.framework/libgdextension.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "app/bin/lib{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
