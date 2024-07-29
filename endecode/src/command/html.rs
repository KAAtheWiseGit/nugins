use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, PipelineData, Signature,
	Type, Value,
};

use crate::EndecodePlugin;

pub struct HtmlDecode;

impl PluginCommand for HtmlDecode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode html"
	}

	fn usage(&self) -> &str {
		"Unescape HTML entities in a string."
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
			.category(Category::Formats)
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
		let string = html_escape::decode_html_entities(&string);

		Ok(Value::string(string, call.head).into_pipeline_data())
	}
}

pub struct HtmlEncode;

impl PluginCommand for HtmlEncode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode html"
	}

	fn usage(&self) -> &str {
		"Escape special HTML characters into HTML entities."
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
			.category(Category::Formats)
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
		let (string, _) = crate::util::get_string(input, call.head)?;
		let string = html_escape::encode_text(&string);

		Ok(Value::string(string, call.head).into_pipeline_data())
	}
}
