#include <cstdlib>
#include <chrono>
#include <random>
#include "die.hpp"


Die::Die(const unsigned short &nsides): result{0} {
	this->nsides = nsides;
}

Die::Die(){
	nsides = 1;
}

Die::~Die(){}

unsigned short Die::random() {
	long seed {std::chrono::system_clock::now().time_since_epoch().count()};
	std::mt19937 generator (seed);
	return generator();
}

void Die::roll() {
	result = 0;
	result = (random() % nsides) + 1;
}

unsigned short &Die::get_result() {
	return result;
}

int Die::operator-() {
	return -get_result(); 
}

int Die::operator+(Die &die) {
	return get_result() + die.get_result();
} 

int Die::operator-(Die &die) {
	return get_result() - die.get_result();
}

int operator+(Die &die, const int num) {
	return die.get_result() + num;
}

int operator+(const int num, Die &die) {
	return num + die.get_result();
}

int operator-(Die &die, const int num) {
	return die.get_result() - num;
}

int operator-(const int num, Die &die) {
	return num - die.get_result();
}

int operator*(Die &die, const int num) {
	return die.get_result() * num;
}

int operator*(const int num, Die &die) {
	return num * die.get_result();
}

int operator/(Die &die, const int num) {
	if (num == 0) {
		return 0;
	}
	return die.get_result() / num;
}

int operator/(const int num, Die &die) {
	return num / die.get_result();
}

int operator%(Die &die, const int num) {
	if (num == 0) {
		return 0;
	}
	return die.get_result() % num;
}

int operator%(const int num, Die &die) {
	return num % die.get_result();
}


