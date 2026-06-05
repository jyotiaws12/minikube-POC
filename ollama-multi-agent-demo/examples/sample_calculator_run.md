# Sample run

A real end-to-end run of `python main.py` (default calculator feature) using
`qwen2.5-coder:3b` via Ollama. The Tester's first suite failed, the team did one
fix round, and all tests passed.

```
Feature : a calculator module that supports add, subtract, multiply and divide
          on two numbers, raising an error on division by zero
Module  : calculator.py
Result  : PASSED
Fixes   : 1
```

## 1. Product Manager → `spec.md` (excerpt)

> The `calculator.py` module provides a simple interface for performing basic
> arithmetic operations on two numbers. It raises an error if division by zero
> is attempted.
>
> - `add(a: float, b: float) -> float` — raises `TypeError` on non-numeric input
> - `subtract(a, b)`, `multiply(a, b)` — same contract
> - `divide(a, b)` — raises `ZeroDivisionError` when `b == 0`

## 2. Developer → `calculator.py`

```python
def add(a: float, b: float) -> float:
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("unsupported operand type(s) for +: 'str' and 'float'")
    return a + b

def subtract(a: float, b: float) -> float:
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("unsupported operand type(s) for -: 'str' and 'float'")
    return a - b

def multiply(a: float, b: float) -> float:
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("unsupported operand type(s) for *: 'str' and 'float'")
    return a * b

def divide(a: float, b: float) -> float:
    if not isinstance(a, (int, float)) or not isinstance(b, (int, float)):
        raise TypeError("unsupported operand type(s) for /: 'str' and 'float'")
    if b == 0:
        raise ZeroDivisionError("division by zero")
    return a / b
```

## 3. Tester → `test_calculator.py`

```python
import pytest
from calculator import add, subtract, multiply, divide

def test_add():
    assert add(3.5, 2.0) == 5.5
    with pytest.raises(TypeError):
        add('a', 3.5)

def test_subtract():
    assert subtract(7.0, 4.5) == 2.5
    with pytest.raises(TypeError):
        subtract('a', 3.5)

def test_multiply():
    assert multiply(6.0, 8.0) == 48.0
    with pytest.raises(TypeError):
        multiply('a', 3.5)

def test_divide():
    assert divide(10.0, 2.0) == 5.0
    with pytest.raises(ZeroDivisionError):
        divide(10.0, 0.0)
```

## 4. Run result

```
=== Running the test suite ===
4 failed in 0.02s        # first attempt: Developer's code didn't match the spec
=== Tests failed. Fix round 1/2 ===
4 passed in 0.01s        # after Tester + Developer fix round
=== Pipeline finished: PASSED after 1 fix attempt(s) ===
```
