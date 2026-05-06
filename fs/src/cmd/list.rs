#![allow(unused)]

use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, NuGlob, PipelineData,
	Signature, Spanned, SyntaxShape, Type, Value,
};

use std::{
	io::{self, Write},
	path::PathBuf,
};

use crate::{FsPlugin, utils::GlobsIter};

pub struct List;

impl PluginCommand for List {
	type Plugin = FsPlugin;

	fn name(&self) -> &str {
		"fs list_"
	}

	fn description(&self) -> &str {
		"List file system objects"
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.category(Category::FileSystem)
			.input_output_types(vec![
				(Type::list(Type::Glob), Type::table()),
				(Type::Nothing, Type::table()),
			])
			.rest(
				"paths",
				SyntaxShape::OneOf(vec![
					SyntaxShape::GlobPattern,
					SyntaxShape::String,
				]),
				"File paths to delete",
			)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["ls"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let globs = call.rest::<NuGlob>(0)?;

		std::env::set_current_dir(engine.get_current_dir()?).unwrap();

		for path in GlobsIter::new(globs) {
			let path = path.unwrap();

			if engine.signals().interrupted() {
				break;
			}

			println!("{path:?}");
		}

		Ok(Value::nothing(call.head).into_pipeline_data())
	}
}
