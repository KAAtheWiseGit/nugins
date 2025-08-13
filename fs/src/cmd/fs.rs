use nu_plugin::{EngineInterface, EvaluatedCall, SimplePluginCommand};
use nu_protocol::{Category, LabeledError, Signature, Type, Value};

use crate::FsPlugin;

pub struct Fs;

impl SimplePluginCommand for Fs {
	type Plugin = FsPlugin;

	fn name(&self) -> &str {
		"fs"
	}

	fn description(&self) -> &str {
		"TODO"
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.category(Category::FileSystem)
			.input_output_type(Type::Nothing, Type::String)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["filesystem"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		engine: &EngineInterface,
		call: &EvaluatedCall,
		_input: &Value,
	) -> Result<Value, LabeledError> {
		Ok(Value::string(engine.get_help()?, call.head))
	}
}
