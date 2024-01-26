import argparse
from pathlib import Path


parser = argparse.ArgumentParser()
parser.add_argument("classname")
args = parser.parse_args()


def main():
    snake_case = args.classname
    title_case = snake_case.replace("_", " ").title().replace(" ", "")
    screaming_snake_case = snake_case.upper()

    TEMPLATE_HPP_CODE = f"""#ifndef GDCLASS_{screaming_snake_case}_HPP
#define GDCLASS_{screaming_snake_case}_HPP

#include <godot_cpp/classes/node.hpp>

namespace godot {{

class {title_case} : public Node {{
    GDCLASS({title_case}, Node)

private:

protected:
    static void _bind_methods();

public:
    {title_case}();
    ~{title_case}();

}};

}}

#endif"""

    TEMPLATE_CPP_CODE = f"""#include "{snake_case}.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void {title_case}::_bind_methods() {{
}}

{title_case}::{title_case}() {{
    // initialize variables here
}}

{title_case}::~{title_case}() {{
    // add your cleanup here
}}"""

    with open(Path(f"src/{snake_case}.hpp"), "w+") as hpp_file:
        hpp_file.write(TEMPLATE_HPP_CODE)

    with open(Path(f"src/{snake_case}.cpp"), "w+") as cpp_file:
        cpp_file.write(TEMPLATE_CPP_CODE)


if __name__ == "__main__":
    main()
