use nu_plugin::{MsgPackSerializer, Plugin, PluginCommand, serve_plugin};

mod cmd;
mod fs;
mod paths;
mod utils;

pub struct FsPlugin;

impl Plugin for FsPlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![
			Box::new(cmd::Delete),
			Box::new(cmd::Fs),
			Box::new(cmd::Info),
			Box::new(cmd::List),
			Box::new(cmd::Shred),
		]
	}
}

fn main() {
	serve_plugin(&FsPlugin {}, MsgPackSerializer {})
}
