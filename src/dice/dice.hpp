#ifndef GDCLASS_DICE_HPP
#define GDCLASS_DICE_HPP

#include <godot_cpp/classes/object.hpp>
#include "dice_algebra.hpp"

namespace godot {

class Dice : public Object {
    GDCLASS(Dice, Object)

private:
	String expr;
	DiceAlgebra dice_algebra;

protected:
    static void _bind_methods();

public:
	Dice();
    Dice(String expr);
    ~Dice();

	int set_expr(String expr);
	String get_expr();
	void roll();
	int get_result();
};

}

#endif
