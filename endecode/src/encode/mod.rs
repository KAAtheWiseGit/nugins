use nu_protocol::{Category, Signature, Type};

mod base32;
mod base32hex;
mod base58;
mod crockford;
mod z32;
mod z85;

pub use base32::Base32;
pub use base32hex::Base32Hex;
pub use base58::Base58;
pub use crockford::Crockford;
pub use z32::Z32;
pub use z85::Z85;

pub fn signature(name: &str) -> Signature {
	Signature::build(name)
		.input_output_types(vec![
			(Type::Binary, Type::String),
			(Type::String, Type::String),
		])
		.category(Category::Formats)
}
