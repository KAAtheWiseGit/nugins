use nu_protocol::{
	Category, LabeledError, PipelineData, Signature, Span, Type, Value,
};

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
		.input_output_types(vec![(Type::String, Type::Binary)])
		.category(Category::Formats)
}

pub fn string(
	input: PipelineData,
	head_span: Span,
) -> Result<(String, Span), LabeledError> {
	match input {
		PipelineData::Value(value, ..) => {
			let span = value.span();
			match value {
				Value::String { val, .. } => Ok((val, span)),
				_ => {
					unreachable!("type signature");
				}
			}
		}
		PipelineData::Empty => Err(LabeledError::new(
			"The command requires string input",
		)
		.with_label("No input was passed to the command", head_span)),
		_ => {
			unreachable!("type signature");
		}
	}
}
