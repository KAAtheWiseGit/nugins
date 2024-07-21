use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};
use z85::decode;

use crate::EndecodePlugin;

pub struct Z85;

impl PluginCommand for Z85 {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode z85"
	}

	fn usage(&self) -> &str {
		"Decode a string or binary value using ZeroMQ’s Z85 decoding."
	}

	fn signature(&self) -> Signature {
		super::signature(self.name())
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
		let (string, span) = super::string(input, call.head)?;

		match decode(&string) {
			Ok(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			Err(err) => Err(LabeledError::new("Decoding error")
				.with_label(err.to_string(), span)),
		}
	}
}
