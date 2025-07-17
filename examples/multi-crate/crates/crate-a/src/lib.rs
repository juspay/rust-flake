pub fn a_hello() -> String {
    format!("A says: {}", crate_b::b_hello())
}
