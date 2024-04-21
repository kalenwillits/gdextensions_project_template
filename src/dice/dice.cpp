#include "dice.hpp"
#include "dice_algebra.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Dice::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_expr", "expr"), &Dice::set_expr);
	ClassDB::bind_method(D_METHOD("get_eval_expr"), &Dice::get_expr);
	ClassDB::bind_method(D_METHOD("get_expr"), &Dice::get_expr);
	ClassDB::bind_method(D_METHOD("roll"), &Dice::roll);
	ClassDB::bind_method(D_METHOD("get_result"), &Dice::get_result);
}

Dice::Dice() : expr{}, dice_algebra{} {
}

Dice::Dice(String expr) : expr{expr} {
	dice_algebra = DiceAlgebra({*expr.utf8().get_data()});
}

Dice::~Dice() {
}

int Dice::set_expr(String expr) {
	this->expr = expr;
	this->dice_algebra = DiceAlgebra(expr.utf8().get_data());
	return dice_algebra.validate();
}

String Dice::get_expr() {
	return expr;
}


void Dice::roll() {
	this->dice_algebra = DiceAlgebra(expr.utf8().get_data());
	dice_algebra.eval();
}

int Dice::get_result() {
	return dice_algebra.get_result();
}
