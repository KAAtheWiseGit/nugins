use base32::{decode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Crockford;

impl PluginCommand for Crockford {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode crockford"
	}

	fn usage(&self) -> &str {
		"Decode a string or binary value using Base32, RFC 4648, section 6."
	}

	fn signature(&self) -> Signature {
		super::signature(self.name())
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
		let (string, span) = super::string(input, call.head)?;

		match decode(Alphabet::Crockford, &string) {
			Some(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			None => Err(LabeledError::new("Decoding error")
				.with_label(
					"Not a valid z-base-32 string",
					span,
				)),
		}
	}
}
