use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Type, Value,
};

use crate::EndecodePlugin;

pub struct Deunicode;

impl PluginCommand for Deunicode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode unicode"
	}

	fn usage(&self) -> &str {
		"Translate a unicode string into pure ASCII."
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
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
		let (string, _) = crate::util::get_string(input, call.head)?;
		let out = deunicode::deunicode(&string);

		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
