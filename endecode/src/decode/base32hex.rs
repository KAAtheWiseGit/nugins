use base32::{decode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Base32Hex;

impl PluginCommand for Base32Hex {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode base32hex"
	}

	fn usage(&self) -> &str {
		"Decode a string or binary value using Base32 with extended hex alphabet, RFC 4648, section 7."
	}

	fn signature(&self) -> Signature {
		crate::util::decode_signature(self.name())
			.switch("nopad", "Don't pad the output", None)
			.switch("lower", "Use lowercase letters", None)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["decoding", "base32"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (string, span) = crate::util::get_string(input, call.head)?;

		let alphabet = if call.has_flag("lower")? {
			Alphabet::Rfc4648HexLower {
				padding: call.has_flag("nopad")?,
			}
		} else {
			Alphabet::Rfc4648Hex {
				padding: call.has_flag("nopad")?,
			}
		};

		match decode(alphabet, &string) {
			Some(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			None => Err(LabeledError::new("Decoding error")
				.with_label(
					"Not a valid base32hex string",
					span,
				)),
		}
	}
}
