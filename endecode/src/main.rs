use nu_plugin::{serve_plugin, MsgPackSerializer, Plugin, PluginCommand};

mod decode;
mod encode;

mod util;
mod command;

pub struct EndecodePlugin;

impl Plugin for EndecodePlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![
			Box::new(crate::encode::Base32),
			Box::new(crate::encode::Base32Hex),
			Box::new(crate::encode::Base58),
			Box::new(crate::encode::Crockford),
			Box::new(crate::encode::Z32),
			Box::new(crate::encode::Z85),
			Box::new(crate::decode::Base32),
			Box::new(crate::decode::Base32Hex),
			Box::new(crate::decode::Base58),
			Box::new(crate::decode::Crockford),
			Box::new(crate::decode::Z32),
			Box::new(crate::decode::Z85),
		]
	}
}

fn main() {
	serve_plugin(&EndecodePlugin {}, MsgPackSerializer {})
}
