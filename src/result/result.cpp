#include "result.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void Result::_bind_methods() {
	ClassDB::bind_static_method("Result", D_METHOD("ok", "value"), &Result::ok);
	ClassDB::bind_static_method("Result", D_METHOD("fail", "value"), &Result::fail);
	ClassDB::bind_static_method("Result", D_METHOD("from", "ok_value", "fail_value"), &Result::from);
	ClassDB::bind_method(D_METHOD("set_ok_value", "value"), &Result::set_ok_value);
	ClassDB::bind_method(D_METHOD("set_fail_value", "value"), &Result::set_fail_value);
	ClassDB::bind_method(D_METHOD("unwrap"), &Result::unwrap);
	ClassDB::bind_method(D_METHOD("error"), &Result::error);
	ClassDB::bind_method(D_METHOD("type"), &Result::type);
	ClassDB::bind_method(D_METHOD("eq", "other"), &Result::eq);
	ClassDB::bind_method(D_METHOD("unwrap_or", "lambda"), &Result::unwrap_or);
	ClassDB::bind_method(D_METHOD("is_ok"), &Result::is_ok);
	ClassDB::bind_method(D_METHOD("is_fail"), &Result::is_fail);
	ClassDB::bind_method(D_METHOD("then", "lambda"), &Result::then);
	ClassDB::bind_method(D_METHOD("catch", "lambda"), &Result::catch_);
}

Result::Result() : ok_value{nullptr}, fail_value{nullptr} {
}

Result::Result(Variant value) {
	ok_value = value;
}

Result::~Result() {
}

void Result::set_ok_value(Variant value) {
	ok_value = value;
}

void Result::set_fail_value(Variant value) {
	fail_value = value;
}

Ref<Result> Result::ok(Variant ok_value) {
	Ref<Result> result = memnew(Result);
	result->set_ok_value(ok_value);
	return result;
}

Ref<Result> Result::fail(Variant fail_value) {
	Ref<Result> result = memnew(Result);
	result->set_fail_value(fail_value);
	return result;
}

Ref<Result> Result::from(Variant ok_value, Variant fail_value) {
	Ref<Result> result = memnew(Result);
	result->set_ok_value(ok_value);
	result->set_fail_value(fail_value);
	return result;
}

Variant Result::unwrap() const {
	return ok_value;
}

Variant Result::error() const {
	return fail_value;
}

int Result::type() const {
	if (ok_value.get_type() != Variant::Type::NIL) {
		return OK_TYPE;
	}
	return FAILED_TYPE;
}

bool Result::eq(int var) const {
	return var == type(); 
}

Variant Result::unwrap_or(Callable lambda) const {
	if (is_ok()) {
		return unwrap();
	}
	return lambda.callv({});
}


bool Result::is_ok() const {
	return type() == OK_TYPE;
}

bool Result::is_fail() const {
	return type() == FAILED_TYPE;
}

Ref<Result> Result::catch_(Callable lambda) const {
	Ref<Result> result = memnew(Result);
	if (is_fail()) {
		Array args {};
		args.append(fail_value);
		result->set_fail_value(lambda.callv(args));
	}
	result->set_ok_value(ok_value);
	return result;
}

Ref<Result> Result::then(Callable lambda) const {
	Ref<Result> result = memnew(Result);
	if (is_ok()) {
		Array args {};
		args.append(ok_value);
		result->set_ok_value(lambda.callv(args));
	}
	return result;
}
