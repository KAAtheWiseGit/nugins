use tinytemplate::TinyTemplate;

use nu_plugin::{
	serve_plugin, EngineInterface, EvaluatedCall, MsgPackSerializer,
	Plugin, PluginCommand,
};
use nu_protocol::{
	Category, IntoPipelineData, LabeledError, PipelineData, Record,
	Signature, Span, SyntaxShape, Type, Value,
};

pub struct TemplatePlugin;

impl Plugin for TemplatePlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![Box::new(TemplateCommand)]
	}
}

fn main() {
	serve_plugin(&TemplatePlugin {}, MsgPackSerializer {})
}

type Result<T> = std::result::Result<T, LabeledError>;

pub struct TemplateCommand;

impl PluginCommand for TemplateCommand {
	type Plugin = TemplatePlugin;

	fn name(&self) -> &str {
		"template"
	}

	fn usage(&self) -> &str {
		"A template engine"
	}

	fn extra_usage(&self) -> &str {
		"This command uses the TinyTemplate Rust library.  Full syntax description can be found here:\n\nhttps://docs.rs/tinytemplate/1.2.1/tinytemplate/syntax/index.html"
	}

	fn signature(&self) -> Signature {
		Signature::build(self.name())
			.input_output_types(vec![(Type::String, Type::String)])
			.required(
				"context",
				SyntaxShape::Record(vec![]),
				"Data used in the template",
			)
			.category(Category::Strings)
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["template"]
	}

	fn run(
		&self,
		_plugin: &TemplatePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData> {
		let (template, _template_span) = get_string(input, call.head)?;
		let record = call.req::<Record>(0)?;

		println!("{}", serde_json::to_string(&record).unwrap());

		let mut tt = TinyTemplate::new();
		tt.add_template("template", &template).unwrap();
		let rendered = tt.render("template", &record).unwrap();

		Ok(Value::string(rendered, call.head).into_pipeline_data())
	}
}

// XXX: consider making a util crate
fn get_string(input: PipelineData, head_span: Span) -> Result<(String, Span)> {
	match input {
		PipelineData::Value(value, ..) => {
			let span = value.span();
			match value {
				Value::String { val, .. } => Ok((val, span)),
				_ => {
					unreachable!("type signature");
				}
			}
		}
		PipelineData::Empty => Err(LabeledError::new(
			"The command requires string input",
		)
		.with_label("No input was passed to the command", head_span)),
		_ => {
			unreachable!("type signature");
		}
	}
}
