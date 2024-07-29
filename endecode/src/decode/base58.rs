use bs58::{alphabet::Alphabet, decode};
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
		"decode base58"
	}

	fn usage(&self) -> &str {
		"Decode a string or binary value using a Base58 alphabet."
	}

	fn signature(&self) -> Signature {
		super::signature(self.name()).required("alphabet", SyntaxShape::String, "Alphabet to use: can be 'bitcoin', 'monero', 'ripple', or 'flickr'")
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

		let alphabet = match call.req::<String>(0)?.as_str() {
			"bitcoin" => Alphabet::BITCOIN,
			"monero" => Alphabet::MONERO,
			"ripple" => Alphabet::RIPPLE,
			"flickr" => Alphabet::FLICKR,
			_ => {
				return Err(LabeledError::new("Alphabet must be one of 'bitcoin', 'monero', 'ripple', or 'flickr'").with_label("Unknown alphabet", call.head));
			}
		};
		let decode = decode(string).with_alphabet(alphabet).into_vec();

		match decode {
			Ok(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			Err(err) => Err(LabeledError::new("Decoding error")
				.with_label(err.to_string(), span)),
		}
	}
}
