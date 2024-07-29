use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};
use z85::encode;

use crate::EndecodePlugin;

pub struct Z85;

impl PluginCommand for Z85 {
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
