use base32::{encode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Z32;

impl PluginCommand for Z32 {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode z32"
	}

	fn usage(&self) -> &str {
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
