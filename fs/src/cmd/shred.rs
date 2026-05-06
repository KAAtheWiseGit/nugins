use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, NuGlob, PipelineData,
	Signature, SyntaxShape, Type, Value,
};

use std::{
	io::{self, Write},
	path::Path,
};

use crate::{FsPlugin, fs, utils::GlobsIter};

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
		std::env::set_current_dir(engine.get_current_dir()?).unwrap();

		let globs = call.rest::<NuGlob>(0)?;
		if globs.is_empty() {
			return Err(LabeledError::new("requires file paths")
				.with_label(
					"no paths were passed",
					call.head,
				));
		}

		let paths = GlobsIter::new(globs).peekable();

		if engine.is_using_stdio() {
			panic!("TODO: error");
		}

		let _guard = engine.enter_foreground();

		for path in paths {
			let path = path.unwrap();

			match confirm(&path) {
				Confirm::Yes => fs::raw::remove(path).unwrap(),
				Confirm::No => continue,
				Confirm::Quit => break,
			}
		}

		Ok(Value::nothing(call.head).into_pipeline_data())
	}
}

enum Confirm {
	Yes,
	No,
	Quit,
}

fn confirm(path: &Path) -> Confirm {
	let mut answer = String::new();

	loop {
		print!("remove permanently: {path:?}  [y/n/q]: ");
		io::stdout().flush().unwrap();
		answer.clear();
		io::stdin().read_line(&mut answer).unwrap();

		match answer.trim() {
			"y" | "Y" => return Confirm::Yes,
			"n" | "N" => return Confirm::No,
			"q" | "Q" => return Confirm::Quit,
			_ => {
				println!(
					"Invalid option.  Expected 'y', 'n', or 'q'"
				);
			}
		};
	}
}
