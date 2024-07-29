use base32::{encode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Crockford;

impl PluginCommand for Crockford {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode crockford"
	}

	fn usage(&self) -> &str {
		"Encode a string or binary value using Base32, RFC 4648, section 6."
	}

	fn signature(&self) -> Signature {
		super::signature(self.name())
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
		let out = encode(Alphabet::Crockford, &bytes);

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
