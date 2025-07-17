use clap::Parser;

#[derive(Parser)]
#[command(name = "hello-world")]
#[command(about = "A simple Hello World CLI application")]
struct Cli {
    /// Name to greet
    #[arg(short, long, default_value = "World")]
    name: String,

    /// Number of times to greet
    #[arg(short, long, default_value_t = 1)]
    count: u8,
}

fn main() {
    let cli = Cli::parse();

    for i in 1..=cli.count {
        if cli.count > 1 {
            println!("{}. Hello, {}!", i, cli.name);
        } else {
            println!("Hello, {}!", cli.name);
        }
    }
}
