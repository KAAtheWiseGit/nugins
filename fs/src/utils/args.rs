use std::{collections::VecDeque, path::PathBuf};

use nu_glob::{Paths, Uninterruptible, glob};
use nu_plugin::EvaluatedCall;
use nu_protocol::{FromValue, NuGlob, PipelineData, Value, ValueIterator};

pub fn get_args(call: &EvaluatedCall, input: PipelineData) -> Iter {
	let call_args = call.rest::<Value>(0).unwrap();
	let mut call_args: VecDeque<_> = call_args.into();

	let input: Option<ValueIterator> = match input {
		PipelineData::Empty | PipelineData::ByteStream(..) => None,

		PipelineData::Value(value, _) => {
			match value {
				Value::List { vals, .. } => {
					for value in vals.into_iter().rev() {
						call_args.push_front(value);
					}
				}
				value @ _ => call_args.push_front(value),
			}
			None
		}

		PipelineData::ListStream(list, _) => Some(list.into_inner()),
	};

	Iter {
		current_iter: None,
		call_args,
		input,
	}
}

pub struct Iter {
	current_iter: Option<Paths>,
	call_args: VecDeque<Value>,
	input: Option<ValueIterator>,
}

impl Iterator for Iter {
	type Item = PathBuf;

	fn next(&mut self) -> Option<PathBuf> {
		macro_rules! process_value {
			($value:expr) => {
				match NuGlob::from_value($value).unwrap() {
					NuGlob::DoNotExpand(path) => {
						return Some(PathBuf::from(
							path,
						));
					}
					NuGlob::Expand(path) => {
						let paths_iter = glob(
							&path,
							Uninterruptible,
						)
						.unwrap();
						self.current_iter =
							Some(paths_iter);
						continue;
					}
				}
			};
		}

		loop {
			if let Some(ref mut iter) = self.current_iter {
				match iter.next() {
					Some(p) => return Some(p.unwrap()),
					None => self.current_iter = None,
				}
			};

			if let Some(ref mut input) = self.input {
				let value = match input.next() {
					Some(value) => value,
					None => {
						self.input = None;
						continue;
					}
				};
				process_value!(value);
			}

			if let Some(value) = self.call_args.pop_front() {
				process_value!(value);
			}

			return None;
		}
	}
}
