use bs58::{alphabet::Alphabet, encode};
use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, SyntaxShape,
	Value,
};

use crate::EndecodePlugin;

pub struct Base58;

impl PluginCommand for Base58 {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode base58"
	}

	fn usage(&self) -> &str {
		"Encode a string or binary value using a Base58 alphabet."
	}

	fn signature(&self) -> Signature {
		crate::util::encode_signature(self.name()).required("alphabet", SyntaxShape::String, "Alphabet to use: can be 'bitcoin', 'monero', 'ripple', or 'flickr'")
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
		let alphabet = match call.req::<String>(0)?.as_str() {
			"bitcoin" => Alphabet::BITCOIN,
			"monero" => Alphabet::MONERO,
			"ripple" => Alphabet::RIPPLE,
			"flickr" => Alphabet::FLICKR,
			_ => {
				return Err(LabeledError::new("Alphabet must be one of 'bitcoin', 'monero', 'ripple', or 'flickr'").with_label("Unknown alphabet", call.head));
			}
		};
		let out = encode(bytes).with_alphabet(alphabet).into_string();

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
