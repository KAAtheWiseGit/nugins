use std::{fs, io::Result as IoResult, path::Path};

pub fn remove<P: AsRef<Path>>(path: P) -> IoResult<()> {
	let path = path.as_ref();

	if path.is_dir() {
		fs::remove_dir_all(path)
	} else {
		fs::remove_file(path)
	}
}
