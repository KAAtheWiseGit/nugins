use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, Example, IntoPipelineData, LabeledError, PipelineData,
	Signature, Type, Value,
};

use crate::EndecodePlugin;

pub struct HtmlDecode;

impl PluginCommand for HtmlDecode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode html"
	}

	fn description(&self) -> &str {
		"Unescape HTML entities in a string."
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
			.category(Category::Formats)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["decoding", "html"]
	}

	fn examples(&self) -> Vec<Example> {
		vec![Example {
			description: "Unescape HTML-encoded strings",
			example: "'a &gt; b &amp;&amp; a &lt; c' | decode html",
			result: Some(Value::test_string("a > b && a < c")),
		}]
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

	fn description(&self) -> &str {
		"Escape special HTML characters into HTML entities."
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
			.category(Category::Formats)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["encoding", "html"]
	}

	fn examples(&self) -> Vec<Example> {
		vec![Example {
			description: "Escape HTML special characters",
			example:
				"'<script>alert('pwn!')</script>' | decode html",
			result: Some(Value::test_string(
				"&lt;script&gt;alert('pwn!')&lt;/script&gt;",
			)),
		}]
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
