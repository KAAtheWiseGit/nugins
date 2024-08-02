use nu_plugin::{serve_plugin, MsgPackSerializer, Plugin, PluginCommand};

mod command;
mod util;

pub struct EndecodePlugin;

impl Plugin for EndecodePlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![
			Box::new(command::Z32Decode),
			Box::new(command::Z32Encode),
			Box::new(command::HtmlDecode),
			Box::new(command::HtmlEncode),
		]
	}
}

fn main() {
	serve_plugin(&EndecodePlugin {}, MsgPackSerializer {})
}
