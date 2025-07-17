pub fn b_hello() -> String {
    format!("B says: {}", crate_c::c_hello())
}
