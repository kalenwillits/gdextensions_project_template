#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

def get_paths(dir_path, sources=set()):
    sources.add(f"{dir_path}/")
    for filename in os.listdir(dir_path):
        if os.path.isdir(f"{dir_path}/{filename}"):
            sources |= (get_paths(f"{dir_path}/{filename}", sources=sources))
    return sources

env.Append(CPPPATH=list(get_paths("src")))
sources = tuple([Glob(f"{path}*.cpp") for path in get_paths("src")])

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

