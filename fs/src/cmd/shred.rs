use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, NuGlob, PipelineData,
	Signature, Spanned, SyntaxShape, Type, Value,
};

use std::{
	io::{self, Write},
	path::PathBuf,
};

use crate::{util, FsPlugin};

pub struct Shred;

impl PluginCommand for Shred {
	type Plugin = FsPlugin;

	fn name(&self) -> &str {
		"fs shred"
	}

	fn description(&self) -> &str {
		"Permanently delete files"
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
				"File paths to delete",
			)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["filesystem", "delete"]
	}

	fn run(
		&self,
		_plugin: &FsPlugin,
		engine: &EngineInterface,
		call: &EvaluatedCall,
		_input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		// TODO: check that paths are not empty

		let paths = call.rest::<Spanned<NuGlob>>(0)?;

		if engine.is_using_stdio() {
			panic!("TODO: error");
		}

		let cwd = PathBuf::from(engine.get_current_dir()?);
		let _guard = engine.enter_foreground();

		if paths.is_empty() {
			return Err(LabeledError::new("requires file paths")
				.with_label(
					"no paths were passed",
					call.head,
				));
		}

		let mut answer = String::new();

		for path in paths {
			let path = match path.item {
				NuGlob::DoNotExpand(s) => s,
				NuGlob::Expand(s) => s,
			};
			let path = cwd.join(path);

			print!("remove permanently: {path:?}  [y/n]: ");
			io::stdout().flush().unwrap();
			answer.clear();
			io::stdin().read_line(&mut answer).unwrap();

			let confirmed = match answer.trim() {
				"y" | "Y" => true,
				"n" | "N" => false,
				_ => panic!("TODO: msg and repeat"),
			};

			if confirmed {
				util::remove(path).unwrap();
			}
		}

		Ok(Value::nothing(call.head).into_pipeline_data())
	}
}
