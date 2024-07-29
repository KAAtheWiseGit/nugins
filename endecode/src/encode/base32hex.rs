use base32::{encode, Alphabet};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

pub struct Base32Hex;

impl PluginCommand for Base32Hex {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode base32hex"
	}

	fn usage(&self) -> &str {
		"Encode a string or binary value using Base32 with extended hex alphabet, RFC 4648, section 7."
	}

	fn signature(&self) -> Signature {
		crate::util::encode_signature(self.name())
			.switch("nopad", "Don't pad the output", None)
			.switch("lower", "Use lowercase letters", None)
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
		let alphabet = if call.has_flag("lower")? {
			Alphabet::Rfc4648HexLower {
				padding: call.has_flag("nopad")?,
			}
		} else {
			Alphabet::Rfc4648Hex {
				padding: call.has_flag("nopad")?,
			}
		};
		let out = encode(alphabet, &bytes);

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
