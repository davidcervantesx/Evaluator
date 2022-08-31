# Evaluator

This evaluator implements a language that returns the last result of a series of values.\
Values can be number literals, e.g. "5", or the result of a function call, e.g. "(+ 2 3)".\
Functions are applied conjuctively. When one of the operands is a floating point value, the result also be a floating point value.

The string "(\* 5 5 5)" evaluates to 125 (equivalent to 5\*5\*5).\
The string "(+ (\* 5 5) (\* 7 7))" evaluates in the integer 74 (equivalent to 5\*5 + 7\*7).\
The string "(+ (\* 95 0.4) (\* 97 0.3) (\* 85 0.3))" evaluates to the floating point value 92.6 (equivalent to 95\*0.4 + 97\*0.3 + 85\*0.3).

The tokenizer and some example test cases were provided by Jeff Terell, who assigned this project as coursework.
