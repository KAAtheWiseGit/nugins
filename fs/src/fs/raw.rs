use std::{fs, io::Result as IoResult, path::Path};

pub fn remove<P: AsRef<Path>>(path: P) -> IoResult<()> {
	fn inner(path: &Path) -> IoResult<()> {
		if path.is_dir() {
			fs::remove_dir_all(path)
		} else {
			fs::remove_file(path)
		}
	}

	inner(path.as_ref())
}

#[expect(dead_code)]
pub fn copy<P0: AsRef<Path>, P1: AsRef<Path>>(
	src: P0,
	dst: P1,
) -> IoResult<()> {
	fn inner(_src: &Path, _dst: &Path) -> IoResult<()> {
		// TODO: check prefix

		todo!()
	}

	inner(src.as_ref(), dst.as_ref())
}
