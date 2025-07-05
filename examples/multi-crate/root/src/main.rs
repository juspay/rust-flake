use math_utils::*;

fn main() {
    println!("=== Math Utils Examples ===\n");

    // Basic arithmetic operations
    println!("Basic Operations:");
    println!("10 + 5 = {}", add(10.0, 5.0));
    println!("10 - 5 = {}", subtract(10.0, 5.0));
    println!("10 * 5 = {}", multiply(10.0, 5.0));

    match divide(10.0, 5.0) {
        Ok(result) => println!("10 / 5 = {result}"),
        Err(e) => println!("Error: {e}"),
    }

    // Division by zero example
    match divide(10.0, 0.0) {
        Ok(result) => println!("10 / 0 = {result}"),
        Err(e) => println!("10 / 0 -> Error: {e}"),
    }

    println!("\nAdvanced Operations:");
    println!("2^3 = {}", power(2.0, 3.0));
    println!("√16 = {}", sqrt(16.0));
    println!("5^2 = {}", power(5.0, 2.0));
    println!("√25 = {}", sqrt(25.0));

    // Complex calculation example
    println!("\nComplex Calculation:");
    println!("Calculating: (2^3 + √16) * 3 / 2");

    let step1 = power(2.0, 3.0);
    println!("Step 1: 2^3 = {step1}");

    let step2 = sqrt(16.0);
    println!("Step 2: √16 = {step2}");

    let step3 = add(step1, step2);
    println!("Step 3: {step1} + {step2} = {step3}");

    let step4 = multiply(step3, 3.0);
    println!("Step 4: {step3} * 3 = {step4}");

    match divide(step4, 2.0) {
        Ok(final_result) => println!("Step 5: {step4} / 2 = {final_result}"),
        Err(e) => println!("Error in final step: {e}"),
    }

    // Practical example: calculating compound interest
    println!("\nPractical Example - Simple Interest:");
    let principal = 1000.0;
    let rate = 0.05; // 5%
    let time = 3.0; // 3 years

    // Simple Interest = Principal * Rate * Time
    let interest = multiply(multiply(principal, rate), time);
    let total = add(principal, interest);

    println!("Principal: ${principal:.2}");
    println!("Rate: {:.1}%", rate * 100.0);
    println!("Time: {time:.0} years");
    println!("Interest: ${interest:.2}");
    println!("Total Amount: ${total:.2}");
}
