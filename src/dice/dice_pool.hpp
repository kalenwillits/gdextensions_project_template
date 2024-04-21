#ifndef DICE_POOL_HPP
#define DICE_POOL_HPP

#include <vector>
#include "die.hpp"


class DicePool 
{
private:
	unsigned short result;
	static bool compare_highest(Die &l_die, Die &r_die);
	static bool compare_lowest(Die &l_die, Die &r_die);


public:
	std::vector<Die> pool;
	DicePool(const unsigned short ndice, const unsigned short nsides);
	~DicePool();
	void sum();
	void roll();
	unsigned short size();
	unsigned short get_result();
	int operator-();
	int operator+(DicePool &pool);
	int operator-(DicePool &pool);
	void keep_highest(unsigned short num);
	void keep_lowest(unsigned short num);
};


int operator+(DicePool &pool, const int num);
int operator+(const int num, DicePool &pool);
int operator-(DicePool &pool, const int num);
int operator-(const int num, DicePool &pool);
int operator*(DicePool &pool, const int num);
int operator*(const int num, DicePool &pool);
int operator/(DicePool &pool, const int num);
int operator/(const int num, DicePool &pool);
int operator%(DicePool &pool, const int num);
int operator%(const int num, DicePool &pool);
int operator<(DicePool &pool, const int num);
int operator>(DicePool &pool, const int num);

#endif
