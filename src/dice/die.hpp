#ifndef DIE_HPP
#define DIE_HPP


class Die {
	private:
		unsigned short nsides;
		unsigned short result;
		
		static unsigned short random();
	public:
		Die();
		Die(const unsigned short &nsides);
		~Die();
		int operator-();
		int operator+(Die &die);
		int operator-(Die &die);
		void roll();
		unsigned short &get_result();


};

int operator+(Die &die, const int num);
int operator+(const int num, Die &die);
int operator-(Die &die, const int num);
int operator-(const int num, Die &die);
int operator*(Die &die, const int num);
int operator*(const int num, Die &die);
int operator/(Die &die, const int num);
int operator/(const int num, Die &die);
int operator%(Die &die, const int num);
int operator%(const int num, Die &die);

#endif
