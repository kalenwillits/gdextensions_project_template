#ifndef GDCLASS_RESULT_HPP
#define GDCLASS_RESULT_HPP

#include <godot_cpp/classes/ref_counted.hpp>

namespace godot {

class Result : public RefCounted {
    GDCLASS(Result, RefCounted)

private:
	enum {OK_TYPE, FAILED_TYPE};
	Variant ok_value;
	Variant fail_value;


protected:
    static void _bind_methods();

public:
	Result(Variant error);
    Result();
    ~Result();
	void set_ok_value(Variant ok_value);
	void set_fail_value(Variant fail_value);
	static Ref<Result> ok(Variant ok_value);
	static Ref<Result> fail(Variant ok_value);
	static Ref<Result> from(Variant ok_value, Variant fail_value);
	Variant unwrap() const;
	Variant unwrap_or(Callable lambda) const;
	Variant error() const;
	int type() const;
	bool eq(int other) const;
	bool is_ok() const;
	bool is_fail() const;
	Ref<Result> catch_(Callable lambda) const;
	Ref<Result> then(Callable lambda) const;
};


};


#endif
