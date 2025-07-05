use math_utils::*;

#[test]
fn integration_test_basic_operations() {
    // Test a sequence of operations
    let result = add(10.0, 5.0);
    let result = subtract(result, 3.0);
    let result = multiply(result, 2.0);
    let result = divide(result, 4.0).unwrap();

    assert_eq!(result, 6.0);
}

#[test]
fn integration_test_complex_calculation() {
    // Test: (2^3 + sqrt(16)) / 2 = (8 + 4) / 2 = 6
    let power_result = power(2.0, 3.0);
    let sqrt_result = sqrt(16.0);
    let sum = add(power_result, sqrt_result);
    let final_result = divide(sum, 2.0).unwrap();

    assert_eq!(final_result, 6.0);
}
