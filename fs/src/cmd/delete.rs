use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, PipelineData, Signature,
	SyntaxShape, Type, Value,
};

use crate::FsPlugin;

pub struct Delete;

impl PluginCommand for Delete {
	type Plugin = FsPlugin;

	fn name(&self) -> &str {
		"fs delete_"
	}

	fn description(&self) -> &str {
		"TODO"
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.category(Category::FileSystem)
			.input_output_type(Type::Nothing, Type::String)
			.rest(
				"paths",
				SyntaxShape::OneOf(vec![
					SyntaxShape::GlobPattern,
					SyntaxShape::String,
				]),
				"TODO desc",
			)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["filesystem"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		_input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		// TODO: check that paths are not empty

		Ok(Value::string("TODO", call.head).into_pipeline_data())
	}
}
