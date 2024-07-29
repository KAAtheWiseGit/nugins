use nu_protocol::{LabeledError, PipelineData, Span, Value};

pub fn get_string(
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

pub fn get_bytes(
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
