#include <string>
#include <bits/stdc++.h>
#include <ctype.h>
#include "dice_pool.hpp"
#include "die.hpp"
#include "dice_algebra.hpp"
#include "expression_value.hpp"


DiceAlgebra::DiceAlgebra() : expr{} {}

DiceAlgebra::DiceAlgebra(const std::string expr) {
	result = 0;
	this->expr = expr;
	validate();
}


const std::string DiceAlgebra::CHARACTER_SET = "0123456789()*%/+-D<>";

unsigned short DiceAlgebra::validate() const {
	std::stack<size_t> parentheses {};
	for (size_t i=0; i < expr.length(); ++i) {
		char ch = std::toupper(expr.at(i));

		if (CHARACTER_SET.find(ch) == std::string::npos) {
			return ValidationResponse::BAD_CHAR;
		}

		switch (expr.at(i)) {
			case '(':
				parentheses.push(i);
				break;
			case ')':
				parentheses.pop();
				break;
			case '/': case '%':
				if ((i + 1) < expr.length()) {
					if (expr.at(i + 1) == '0') {
						return ValidationResponse::ZERO_DIVISION;
					}
				}
				break;
			case '<': case '>':
				if (i > 0) {
					int step = 1;

					while (true) {
						int next_step = i - step;
						if (next_step < 0) {
							return ValidationResponse::BAD_FILTER;
						}
						char prev_ch = std::toupper(expr.at(i - step));
						if (std::isdigit(prev_ch)) {
							step++;
						} else if (prev_ch == 'D') {
							break;
						} else {
							return ValidationResponse::BAD_FILTER;
						}
					}
				} else {
					return ValidationResponse::BAD_FILTER;
				}
				break;
		}
	}
	
	if (!parentheses.empty()) {
		return ValidationResponse::UNBALANCED;
	}

	return ValidationResponse::IS_VALID;
}

void DiceAlgebra::eval() {
	if (get_expr() == "") {
		expr == "0";
	}
	eval_parentheses();
	eval_filters();
	eval_dice_pool();
	eval_multiplication();
	eval_division();
	eval_modulus();
	eval_addition();
	eval_subtraction();
}

ExpressionValue DiceAlgebra::get_lvalue(size_t &i, const char operand) const {
	int step = 1;
	std::string result;
	while (true) {
		if ((static_cast<int>(i) - step) >= 0) {
			if (std::isdigit(expr.at(i - step))) {
				result = expr.at(i - step) + result;
				++step;
			} else {
				break;
			}
		} else {
			break;
		}
	}

	if (result == "") {
		switch (std::toupper(operand)) {
			case '+': 
			case '-': 
			case '/': 
			case '%': 
			case '*': 
			case '<': 
			case '>':
				result = "0";
				break;
			case 'D':
				result = "1";
				break;
		};
	}
	return ExpressionValue(std::max(std::stoi(result), 0), step);
}

ExpressionValue DiceAlgebra::get_rvalue(size_t &i, const char operand) const {
	int step = 1;
	std::string result;
	while (true) {
		if ((i + step) < expr.size()) {
			if (std::isdigit(expr.at(i + step))) {
				result += expr.at(i + step);
				step++;
			} else {
				break;
			}
		} else {
			break;
		}
	}

	if (result == "") {
		switch (std::toupper(operand)) {
			case '+': case '-':
				result = "0";
				break;
			case '/': case '%': case '*':
				result = "1";
				break;
			case '<': case '>':
				result = "0";
				break;
			case 'D':
				result = "1";
				break;
		};
	}

	return ExpressionValue(std::max(std::stoi(result), 0), step);
}


void DiceAlgebra::eval_parentheses() {
	while (expr.find('(') != std::string::npos) {
		std::stack<size_t> left_parentheses_stack {};
		std::queue<std::pair<size_t, size_t>> paired_parentheses_queue {};
		size_t left_parentheses = 0; 
		size_t right_parentheses = 0;
		for (size_t i=0; i < expr.length(); ++i) {
			auto ch = expr.at(i);
			if (ch == '(') {
				left_parentheses = i;
			} else if (ch == ')') {
				right_parentheses = i;
				auto expr_start = left_parentheses + 1;
				auto expr_length = (right_parentheses - left_parentheses) - 1;
				std::string inner_substr;
				if (expr_length <= 0) {
					inner_substr = "0";
				} else {
					inner_substr = expr.substr(expr_start, expr_length);
				}
				DiceAlgebra inner_expr {inner_substr};
				inner_expr.eval();
				std::string left_expr = expr.substr(0, left_parentheses);
				std::string right_expr = expr.substr(right_parentheses + 1);
				expr = left_expr + inner_expr.get_expr() + right_expr;
				break;
			}
		}
	}
}


void DiceAlgebra::eval_filters() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			if (expr.at(i) == '>') {
				has_operators = true;
				ExpressionValue filter_expr {get_rvalue(i, '>')};
				size_t step = i;  
				while (step > 0) {  
					if (std::toupper(expr.at(--step)) == 'D') {  
						ExpressionValue lvalue {get_lvalue(step, 'D')};
						ExpressionValue rvalue {get_rvalue(step, 'D')};
						DicePool dice = DicePool(lvalue.value, rvalue.value);
						dice.roll();
						dice > filter_expr.value;
						dice.sum();
						std::string result = std::to_string(dice.get_result());
						expr = expr.substr(0, (step - lvalue.distance) + 1) + result + expr.substr(i + filter_expr.distance);
						break;
					}
				}
				break;
			} else if (expr.at(i) == '<') {
				if (expr.at(i) == '<') {
					has_operators = true;
					ExpressionValue filter_expr {get_rvalue(i, '<')};
					size_t step = i;
					while (step > 0) {
					if (std::toupper(expr.at(--step)) == 'D') {
						ExpressionValue lvalue {get_lvalue(step, 'D')};
						ExpressionValue rvalue {get_rvalue(step, 'D')};
						DicePool dice = DicePool(lvalue.value, rvalue.value);
						dice.roll();
						dice < filter_expr.value;
						dice.sum();
						std::string result = std::to_string(dice.get_result());
						expr = expr.substr(0, (step - lvalue.distance) + 1) + result + expr.substr(i + filter_expr.distance);
						break;
						}
					}
					break;
				} 
			}
		}
	}
}


void DiceAlgebra::eval_dice_pool() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = std::toupper(expr.at(i)) == 'D';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, 'D')};
				ExpressionValue rvalue {get_rvalue(i, 'D')};
				DicePool dice = DicePool(lvalue.value, rvalue.value);
				dice.roll();
				dice.sum();
				std::string result = std::to_string(dice.get_result());
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}




void DiceAlgebra::subsitute(const int &start, const int &end, std::string &sub, const size_t offset=0) {
	std::string pre;
	pre = {expr.substr(0, (offset - start) + 1)};
	std::string post;
	post = {expr.substr((end + offset))};
	expr = pre + sub + post;
}


void DiceAlgebra::eval_multiplication() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = expr.at(i) == '*';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, '*')};
				ExpressionValue rvalue {get_rvalue(i, '*')};
				std::string result = std::to_string(lvalue.value * rvalue.value);
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}

void DiceAlgebra::eval_division() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = expr.at(i) == '/';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, '/')};
				ExpressionValue rvalue {get_rvalue(i, '/')};
				std::string result = std::to_string(lvalue.value / rvalue.value);
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}

void DiceAlgebra::eval_modulus() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = expr.at(i) == '%';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, '%')};
				ExpressionValue rvalue {get_rvalue(i, '%')};
				std::string result = std::to_string(lvalue.value % rvalue.value);
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}



void DiceAlgebra::eval_addition() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = expr.at(i) == '+';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, '+')};
				ExpressionValue rvalue {get_rvalue(i, '+')};
				std::string result = std::to_string(std::max(lvalue.value + rvalue.value, 0));
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}


void DiceAlgebra::eval_subtraction() {
	bool has_operators = true;
	while (has_operators) {
		has_operators = false;
		for (size_t i=0; i < expr.size(); ++i) {
			bool is_operator = expr.at(i) == '-';
			if (is_operator) {
				has_operators = true;
				ExpressionValue lvalue {get_lvalue(i, '-')};
				ExpressionValue rvalue {get_rvalue(i, '-')};
				std::string result = std::to_string(std::max(lvalue.value - rvalue.value, 0));
				subsitute(lvalue.distance, rvalue.distance, result, i);
				break;
			} 
		}
	}
}


std::string DiceAlgebra::get_expr() {
	return expr;
}

int DiceAlgebra::get_result() {
	eval();
	return std::stoi(expr);
}

