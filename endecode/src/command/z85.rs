use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};
use z85::{decode, encode};

use crate::EndecodePlugin;

pub struct Z85Decode;

impl PluginCommand for Z85Decode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode z85"
	}

	fn usage(&self) -> &str {
		"Decode a string or binary value using ZeroMQ’s Z85 decoding."
	}

	fn signature(&self) -> Signature {
		crate::util::decode_signature(self.name())
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["decoding"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (string, span) = crate::util::get_string(input, call.head)?;

		match decode(&string) {
			Ok(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			Err(err) => Err(LabeledError::new("Decoding error")
				.with_label(err.to_string(), span)),
		}
	}
}

pub struct Z85Encode;

impl PluginCommand for Z85Encode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode z85"
	}

	fn usage(&self) -> &str {
		"Encode a string or binary value using ZeroMQ’s Z85 encoding."
	}

	fn signature(&self) -> Signature {
		crate::util::encode_signature(self.name())
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["encoding"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (bytes, _) = crate::util::get_bytes(input, call.head)?;
		let out = encode(&bytes);
		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
