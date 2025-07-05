use std::env;
use std::process;
use math_utils::*;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 4 {
        eprintln!("Usage: {} <number1> <operator> <number2>", args[0]);
        eprintln!("Operators: +, -, *, /");
        eprintln!("Example: {} 10 + 5", args[0]);
        process::exit(1);
    }

    let num1: f64 = match args[1].parse() {
        Ok(n) => n,
        Err(_) => {
            eprintln!("Error: '{}' is not a valid number", args[1]);
            process::exit(1);
        }
    };

    let operator = &args[2];

    let num2: f64 = match args[3].parse() {
        Ok(n) => n,
        Err(_) => {
            eprintln!("Error: '{}' is not a valid number", args[3]);
            process::exit(1);
        }
    };

    let result = match operator.as_str() {
        "+" => add(num1, num2),
        "-" => subtract(num1, num2),
        "*" => multiply(num1, num2),
        "/" => match divide(num1, num2) {
            Ok(result) => result,
            Err(e) => {
                eprintln!("Error: {}", e);
                process::exit(1);
            }
        },
        _ => {
            eprintln!("Error: '{}' is not a supported operator", operator);
            eprintln!("Supported operators: +, -, *, /");
            process::exit(1);
        }
    };

    println!("{} {} {} = {}", num1, operator, num2, result);
}
