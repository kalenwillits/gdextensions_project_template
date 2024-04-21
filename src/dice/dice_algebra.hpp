#ifndef DICE_ALGEBRA_HPP
#define DICE_ALGEBRA_HPP

#include <string>
#include <vector>
#include "expression_value.hpp"


class DiceAlgebra {
	private:
		static const std::string CHARACTER_SET;
		std::string expr;
		int result;
		void eval_filters();
		void eval_dice_pool();
		void eval_parentheses();
		void eval_multiplication();
		void eval_division();
		void eval_modulus();
		void eval_addition();
		void eval_subtraction();
		void subsitute(const int &start, const int &end, std::string &sub, const size_t offset);
		ExpressionValue get_lvalue(size_t &i, const char operand) const;
		ExpressionValue get_rvalue(size_t &i, const char operand) const;


	public:
		enum ValidationResponse: unsigned short {
			IS_VALID,
			BAD_CHAR, 
			UNBALANCED, 
			BAD_FILTER,
			ZERO_DIVISION,
		};

		DiceAlgebra();
		DiceAlgebra(const std::string expr);

		unsigned short validate() const;
		void eval();
		int get_result();
		std::string get_expr();
};

#endif
