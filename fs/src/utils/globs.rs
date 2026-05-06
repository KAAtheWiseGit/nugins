use nu_glob::{GlobError, Paths, Uninterruptible, glob};
use nu_protocol::NuGlob;

use std::{collections::VecDeque, path::PathBuf};

pub struct GlobsIter {
	globs: VecDeque<NuGlob>,
	current: Option<Paths>,
}

impl GlobsIter {
	pub fn new(globs: Vec<NuGlob>) -> Self {
		Self {
			globs: globs.into(),
			current: None,
		}
	}
}

impl Iterator for GlobsIter {
	type Item = Result<PathBuf, GlobError>;

	fn next(&mut self) -> Option<Self::Item> {
		loop {
			if let Some(current) = &mut self.current {
				if let Some(next) = current.next() {
					return Some(next);
				} else {
					self.current = None;
					continue;
				}
			}

			let next_glob = self.globs.pop_front()?;

			match next_glob {
				NuGlob::Expand(g) => {
					self.current =
						Some(glob(&g, Uninterruptible)
							.unwrap());
					continue;
				}
				NuGlob::DoNotExpand(g) => {
					return Some(Ok(PathBuf::from(g)));
				}
			}
		}
	}
}
