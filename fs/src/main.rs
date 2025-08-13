use nu_plugin::{serve_plugin, MsgPackSerializer, Plugin, PluginCommand};

mod cmd;
mod util;

pub struct FsPlugin;

impl Plugin for FsPlugin {
	fn version(&self) -> String {
		env!("CARGO_PKG_VERSION").into()
	}

	fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
		vec![
			Box::new(cmd::Fs),
			Box::new(cmd::Delete),
			Box::new(cmd::List),
			Box::new(cmd::Shred),
		]
	}
}

fn main() {
	serve_plugin(&FsPlugin {}, MsgPackSerializer {})
}
