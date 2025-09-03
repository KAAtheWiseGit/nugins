use nu_plugin::EvaluatedCall;
use nu_protocol::{
	LabeledError, ListStream, NuGlob, PipelineData, Spanned, Value,
};

use std::collections::VecDeque;
pub struct PathsIter {
	items: VecDeque<Spanned<NuGlob>>,
	stream: Option<ListStream>,
}

fn value_to_glob(value: &Value) -> Result<Spanned<NuGlob>, LabeledError> {
	let span = value.span();
	let item = match value {
		Value::String { val, .. } => NuGlob::DoNotExpand(val.clone()),
		Value::Glob { val, no_expand, .. } => {
			if *no_expand {
				NuGlob::DoNotExpand(val.clone())
			} else {
				NuGlob::Expand(val.clone())
			}
		}

		_ => todo!(),
	};

	Ok(Spanned { span, item })
}

fn append_globs(
	value: Value,
	items: &mut VecDeque<Spanned<NuGlob>>,
) -> Result<(), LabeledError> {
	let list = value.as_list()?;

	for value in list {
		let glob = value_to_glob(value)?;
		items.push_back(glob);
	}

	Ok(())
}

impl PathsIter {
	pub fn new(
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<Self, LabeledError> {
		let items = call.rest::<Spanned<NuGlob>>(0)?;
		let mut items = VecDeque::from(items);

		let input = match input {
			PipelineData::Empty => None,
			PipelineData::ListStream(stream, _metadata) => {
				Some(stream)
			}
			PipelineData::Value(val, _metadata) => {
				append_globs(val, &mut items)?;
				None
			}
			_ => panic!("TODO: error"),
		};

		if items.is_empty() && input.is_none() {
			return Err(LabeledError::new("requires file paths")
				.with_label(
					"no paths were passed",
					call.head,
				));
		}

		Ok(PathsIter {
			items,
			stream: input,
		})
	}
}

impl Iterator for PathsIter {
	type Item = Result<Spanned<NuGlob>, LabeledError>;

	fn next(&mut self) -> Option<Self::Item> {
		if let Some(item) = self.items.pop_front() {
			return Some(Ok(item));
		}

		let input = self.stream.as_mut()?;
		let item = input.next_value()?;

		Some(value_to_glob(&item))
	}
}
