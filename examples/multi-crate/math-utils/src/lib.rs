//! Math Utils Library
//!
//! A simple library providing basic mathematical operations with error handling.

use std::fmt;

/// Custom error type for mathematical operations
#[derive(Debug, Clone, PartialEq)]
pub enum MathError {
    DivisionByZero,
}

impl fmt::Display for MathError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            MathError::DivisionByZero => write!(f, "Division by zero is not allowed"),
        }
    }
}

impl std::error::Error for MathError {}

/// Adds two numbers
///
/// # Examples
///
/// ```
/// use math_utils::add;
///
/// assert_eq!(add(2.0, 3.0), 5.0);
/// ```
pub fn add(a: f64, b: f64) -> f64 {
    a + b
}

/// Subtracts the second number from the first
///
/// # Examples
///
/// ```
/// use math_utils::subtract;
///
/// assert_eq!(subtract(5.0, 3.0), 2.0);
/// ```
pub fn subtract(a: f64, b: f64) -> f64 {
    a - b
}

/// Multiplies two numbers
///
/// # Examples
///
/// ```
/// use math_utils::multiply;
///
/// assert_eq!(multiply(4.0, 3.0), 12.0);
/// ```
pub fn multiply(a: f64, b: f64) -> f64 {
    a * b
}

/// Divides the first number by the second
///
/// # Examples
///
/// ```
/// use math_utils::{divide, MathError};
///
/// assert_eq!(divide(6.0, 2.0).unwrap(), 3.0);
/// assert_eq!(divide(5.0, 0.0), Err(MathError::DivisionByZero));
/// ```
pub fn divide(a: f64, b: f64) -> Result<f64, MathError> {
    if b == 0.0 {
        Err(MathError::DivisionByZero)
    } else {
        Ok(a / b)
    }
}

/// Calculates the power of a number
///
/// # Examples
///
/// ```
/// use math_utils::power;
///
/// assert_eq!(power(2.0, 3.0), 8.0);
/// ```
pub fn power(base: f64, exponent: f64) -> f64 {
    base.powf(exponent)
}

/// Calculates the square root of a number
///
/// # Examples
///
/// ```
/// use math_utils::sqrt;
///
/// assert_eq!(sqrt(9.0), 3.0);
/// ```
pub fn sqrt(n: f64) -> f64 {
    n.sqrt()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2.0, 3.0), 5.0);
        assert_eq!(add(-1.0, 1.0), 0.0);
    }

    #[test]
    fn test_subtract() {
        assert_eq!(subtract(5.0, 3.0), 2.0);
        assert_eq!(subtract(0.0, 5.0), -5.0);
    }

    #[test]
    fn test_multiply() {
        assert_eq!(multiply(4.0, 3.0), 12.0);
        assert_eq!(multiply(-2.0, 3.0), -6.0);
    }

    #[test]
    fn test_divide() {
        assert_eq!(divide(6.0, 2.0).unwrap(), 3.0);
        assert_eq!(divide(5.0, 0.0), Err(MathError::DivisionByZero));
    }

    #[test]
    fn test_power() {
        assert_eq!(power(2.0, 3.0), 8.0);
        assert_eq!(power(5.0, 0.0), 1.0);
    }

    #[test]
    fn test_sqrt() {
        assert_eq!(sqrt(9.0), 3.0);
        assert_eq!(sqrt(16.0), 4.0);
    }
}
