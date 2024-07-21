use base32::{encode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Base32;

impl PluginCommand for Base32 {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode base32"
	}

	fn usage(&self) -> &str {
		"Encode a string or binary value using Base32, RFC 4648, section 6."
	}

	fn signature(&self) -> Signature {
		super::signature(self.name())
			.switch("nopad", "Don't pad the output", None)
			.switch("lower", "Use lowercase letters", None)
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
		let (bytes, _) = super::bytes(input, call.head)?;
		let alphabet = if call.has_flag("lower")? {
			Alphabet::Rfc4648Lower {
				padding: call.has_flag("nopad")?,
			}
		} else {
			Alphabet::Rfc4648 {
				padding: call.has_flag("nopad")?,
			}
		};
		let out = encode(alphabet, &bytes);

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
