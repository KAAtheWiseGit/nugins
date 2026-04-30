use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, NuGlob, PipelineData,
	Signature, Spanned, SyntaxShape, Type, Value,
};

use std::{
	io::{self, Write},
	path::{Path, PathBuf},
};

use crate::{FsPlugin, fs};

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

		for path in paths {
			let path = match path.item {
				NuGlob::DoNotExpand(s) => s,
				NuGlob::Expand(s) => s,
			};
			let path = cwd.join(path);

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
