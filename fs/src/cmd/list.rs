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

use crate::{FsPlugin, paths::PathsIter};

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
				(Type::list(Type::String), Type::table()),
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
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let paths = PathsIter::new(call, input)?;

		for path in paths {
			let path = path?;

			println!("{path:?}");
		}

		Ok(Value::nothing(call.head).into_pipeline_data())
	}
}
