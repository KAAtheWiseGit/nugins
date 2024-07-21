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
		.input_output_types(vec![
			(Type::Binary, Type::String),
			(Type::String, Type::String),
		])
		.category(Category::Formats)
}

pub fn bytes(
	input: PipelineData,
	head_span: Span,
) -> Result<(Vec<u8>, Span), LabeledError> {
	let input_span = input.span().unwrap_or(Span::unknown());
	match input {
		PipelineData::Value(value, ..) => {
			let span = value.span();
			match value {
				Value::String { val, .. } => {
					Ok((val.into_bytes(), span))
				}
				Value::Binary { val, .. } => Ok((val, span)),
				_ => {
					unreachable!(
						"Other types are forbidden"
					);
				}
			}
		}
		PipelineData::ByteStream(stream, ..) => {
			Ok((stream.into_bytes()?, input_span))
		}
		PipelineData::Empty => Err(LabeledError::new(
			"The command requires string or binary input",
		)
		.with_label("No input was passed to the command", head_span)),
		_ => {
			unreachable!("Other types are forbidden");
		}
	}
}
