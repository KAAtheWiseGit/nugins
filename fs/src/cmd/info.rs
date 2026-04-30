use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoInterruptiblePipelineData, LabeledError, PipelineData,
	Signature, SyntaxShape, Type, Value,
};

use std::fs::symlink_metadata;
use std::path::PathBuf;

use crate::FsPlugin;
use crate::utils::get_args;
use crate::utils::info::metadata_to_record;

pub struct Info;

impl PluginCommand for Info {
	type Plugin = FsPlugin;

	fn name(&self) -> &str {
		"fs info"
	}

	fn description(&self) -> &str {
		"Get information about a filesystem object"
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.category(Category::FileSystem)
			.input_output_type(
				Type::one_of([
					Type::Nothing,
					Type::Glob,
					Type::list(Type::Glob),
				]),
				Type::record(),
			)
			.rest("paths", SyntaxShape::GlobPattern, "File path")
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["filesystem", "stat"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		std::env::set_current_dir(engine.get_current_dir()?).unwrap();

		let span = call.head;
		let iter = get_args(call, input);

		let values = iter
			.map(|path| -> Result<Value, LabeledError> {
				let cwd = PathBuf::from(
					engine.get_current_dir()?,
				);
				let metadata =
					symlink_metadata(cwd.join(&path))
						.unwrap();
				let record = metadata_to_record(
					span, &path, &metadata,
				);
				Ok(Value::record(record, span))
			})
			.collect::<Result<Vec<Value>, LabeledError>>()?;

		Ok(values.into_pipeline_data(span, engine.signals().clone()))
	}
}
