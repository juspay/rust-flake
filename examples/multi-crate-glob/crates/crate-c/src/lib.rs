pub fn c_hello() -> String {
    // To avoid infinite recursion, just return a message (do not call crate_a::a_hello())
    "Hello from C!".to_string()
}
