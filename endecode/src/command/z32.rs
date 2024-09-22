use base32::{decode, encode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Z32Decode;

impl PluginCommand for Z32Decode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode z32"
	}

	fn description(&self) -> &str {
		"Decode a string or binary value with the z-base-32 decoding."
	}

	fn signature(&self) -> Signature {
		crate::util::decode_signature(self.name())
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

		match decode(Alphabet::Z, &string) {
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

pub struct Z32Encode;

impl PluginCommand for Z32Encode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode z32"
	}

	fn description(&self) -> &str {
		"Encode a string or binary value with the z-base-32 encoding."
	}

	fn signature(&self) -> Signature {
		crate::util::encode_signature(self.name())
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["encoding", "base32"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (bytes, _) = crate::util::get_bytes(input, call.head)?;
		let out = encode(Alphabet::Z, &bytes);

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
