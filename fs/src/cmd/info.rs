use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, PipelineData, Signature,
	Spanned, SyntaxShape, Type, Value,
};

use std::fs::symlink_metadata;
use std::path::PathBuf;

use crate::utils::info::metadata_to_record;
use crate::FsPlugin;

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
			.input_output_type(Type::Nothing, Type::record())
			.required("path", SyntaxShape::Filepath, "File path")
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["filesystem", "stat"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		engine: &EngineInterface,
		call: &EvaluatedCall,
		_input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let path: Spanned<PathBuf> = call.req(0)?;
		let span = call.head;

		let cwd = PathBuf::from(engine.get_current_dir()?);
		let metadata = symlink_metadata(cwd.join(&path.item)).unwrap();
		let record = metadata_to_record(span, &path.item, &metadata);
		let value = Value::record(record, span);

		Ok(value.into_pipeline_data())
	}
}
