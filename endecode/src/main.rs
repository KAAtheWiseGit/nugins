use nu_plugin::{MsgPackSerializer, Plugin, PluginCommand, serve_plugin};

mod command;
mod util;

pub struct EndecodePlugin;

impl Plugin for EndecodePlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![
			Box::new(command::Base58Decode),
			Box::new(command::Base58Encode),
			Box::new(command::Base62Decode),
			Box::new(command::Base62Encode),
			Box::new(command::CrockfordDecode),
			Box::new(command::CrockfordEncode),
			Box::new(command::HtmlDecode),
			Box::new(command::HtmlEncode),
			Box::new(command::Z32Decode),
			Box::new(command::Z32Encode),
			Box::new(command::Z85Decode),
			Box::new(command::Z85Encode),
			Box::new(command::Deunicode),
		]
	}
}

fn main() {
	serve_plugin(&EndecodePlugin {}, MsgPackSerializer {})
}
