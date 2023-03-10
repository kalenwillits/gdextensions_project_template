import os
from pathlib import Path


class GodotExtension:
    def __init__(self, filename, header):
        self.filename = filename
        self.header = str(header)[4:]

    @property
    def name(self):
        return next(iter(self.filename.split(".")), "")

    @property
    def classname(self):
        return self.name.replace("_", " ").title().replace(" ", "")

    def __repr__(self):
        return self.header

    def __str__(self):
        return self.header


def get_extension_headers(path_string="src/"):
    results = []
    path = Path(path_string)
    for filename in os.listdir(path):
        if os.path.isdir(path / filename):
            results.extend(get_extension_headers(path / filename))
        else:
            is_cpp_header = filename[-4:].lower() == ".hpp"
            is_c_header = filename[-2:].lower() == ".h"
            is_register_types = filename[:len("register_types")].lower() == "register_types"
            is_gdclass = False
            with open(path / filename) as srcfile:
                if "GDCLASS" in srcfile.readline():
                    is_gdclass = True

            if not is_register_types and is_gdclass:
                if is_cpp_header or is_c_header:
                    results.append(GodotExtension(filename, path / filename))

    return results


def main():
    include_string = ""
    register_class_string = ""

    extensions = get_extension_headers()
    for godot_extension in extensions:
        include_string += f"#include <{godot_extension.header}>" + "\n"
        register_class_string += "\t\t" + f"ClassDB::register_class<{godot_extension.classname}>();" + "\n"

    REGISTER_TYPES_HPP = """#ifndef GDEXTENSION_REGISTER_TYPES_HPP
#define GDEXTENSION_REGISTER_TYPES_HPP

void initialize_module();
void uninitialize_module();

#endif"""

    REGISTER_TYPES_CPP = f"""{include_string}
#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_module(ModuleInitializationLevel p_level) {{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {{
        return;
    }}

    {register_class_string}
}}

void uninitialize_module(ModuleInitializationLevel p_level) {{
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {{
        return;
    }}
}}

extern "C" {{
// Initialization.
GDExtensionBool GDE_EXPORT library_init(const GDExtensionInterface *p_interface, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {{
    godot::GDExtensionBinding::InitObject init_obj(p_interface, p_library, r_initialization);

    init_obj.register_initializer(initialize_module);
    init_obj.register_terminator(uninitialize_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}}
}}"""

    with open(Path("src/register_types.hpp"), "w+") as register_types_hpp_file:
        register_types_hpp_file.write(REGISTER_TYPES_HPP)

    with open(Path("src/register_types.cpp"), "w+") as register_types_cpp_file:
        register_types_cpp_file.write(REGISTER_TYPES_CPP)


if __name__ == "__main__":
    main()
