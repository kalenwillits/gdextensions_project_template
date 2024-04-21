#include "dice_pool.hpp"
#include "die.hpp"
#include <vector>
#include <bits/stdc++.h>

#include <iostream>


DicePool::DicePool(const unsigned short ndice, const unsigned short nsides): result{0} {
	for (unsigned short i=0; i < ndice; ++i) {
		pool.push_back(Die(nsides));
	}
}

DicePool::~DicePool() {
};

void DicePool::roll() {
	for (Die &die: pool) {
			die.roll();
	}
}


void DicePool::sum() {
	result = 0;	
	for (Die &die: pool) {
		result += die.get_result();	
	}
}

unsigned short DicePool::get_result() {
	return result;
}

int DicePool::operator-() {
	return -get_result(); 
}


int DicePool::operator+(DicePool &pool){
	return get_result() + pool.get_result();
}

int DicePool::operator-(DicePool &pool){
	return get_result() - get_result();	
}

unsigned short DicePool::size() {
	return pool.size();
}

bool DicePool::compare_lowest(Die &l_die, Die &r_die) {
	return l_die.get_result() < r_die.get_result();
}

void DicePool::keep_lowest(unsigned short num) {
	std::sort(pool.begin(), pool.end(), compare_lowest);
	pool.resize(num);
}

bool DicePool::compare_highest(Die &l_die, Die &r_die) {
	return l_die.get_result() > r_die.get_result();

}

void DicePool::keep_highest(unsigned short num) {
	std::sort(pool.begin(), pool.end(), compare_highest);
	pool.resize(num);
}

int operator+(DicePool &pool, const int num) {
	return pool.get_result() + num;
}

int operator+(const int num, DicePool &pool) {
	return num + pool.get_result();
}

int operator-(DicePool &pool, const int num) {
	return pool.get_result() - num; 
}

int operator-(const int num, DicePool &pool) {
	return num - pool.get_result();
}

int operator*(DicePool &pool, const int num) {
	return pool.get_result() * num;
}

int operator*(const int num, DicePool &pool) {
	return num * pool.get_result();
}

int operator/(DicePool &pool, const int num) {
	return pool.get_result() / num;
}

int operator/(const int num, DicePool &pool) {
	return num / pool.get_result();
}

int operator%(DicePool &pool, const int num) {
	return pool.get_result() % num;
}

int operator%(const int num, DicePool &pool) {
	return num % pool.get_result();
} 

int operator<(DicePool &pool, const int num) {
	pool.keep_lowest(num);
	return pool.get_result();
}

int operator>(DicePool &pool, const int num) {
	pool.keep_highest(num);
	return pool.get_result();
}
