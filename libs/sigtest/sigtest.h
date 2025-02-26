/*	sigtest.h
	Header for the sigma test assert interface
*/
#ifndef SIGTEST_H
#define SIGTEST_H

#include <stdio.h>

typedef void* object;
typedef char* string;

/**
 * @brief Type info enums 
 */
typedef enum {
	INT,
	FLOAT,
	DOUBLE,
	CHAR,
	STRING,
	PTR
	// Add more types as needed
} AssertType;
/**
 * @brief Test state result
 */
typedef enum {
	PASS,
	FAIL
} TestState;

/**
 * @brief Assert interface structure with function pointers
 */
typedef struct IAssert {
	/**
	* @brief Asserts the given condition is TRUE
	* @param  condition :the condition to check
	* @param  message :the message to display if assertion fails
	*/
	void (*isTrue)(int condition, const string message);
	/**
	* @brief Asserts the given condition is FALSE
	* @param  condition :the condition to check
	* @param  message :the message to display if assertion fails
	*/
	void (*isFalse)(int condition, const string message);
	/**
	* @brief Asserts that two values are equal.
	* @param expected :expected value.
	* @param actual :actual value to compare.
	* @param type :the value types
	* @param message :message to display if assertion fails.
	*/
	void (*areEqual)(object expected, object actual, AssertType type, const string message);
} IAssert;

/**
 * @brief Global instance of the IAssert interface for use in tests
 */
extern const IAssert Assert;

/**
 * @brief Test case structure
 * @detail Encapsulates the name of the test and the test case function pointer
 */
typedef struct {
	string name;
	void (*test_func)(void);
	struct {
		TestState state;
		string message;
	} testResult;
} Test;

extern Test tests[100];
extern int test_count;

/**
 * @brief Registers a new test into the test array
 * @param  name :the test name
 * @return func :pointer to the test function
 */
void register_test(string name, void (*func)(void));

#endif // SIGTEST_H
