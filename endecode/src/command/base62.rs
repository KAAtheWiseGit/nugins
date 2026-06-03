use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{
	IntoPipelineData, LabeledError, PipelineData, Signature, Value,
};

use crate::EndecodePlugin;

const ALPHABET: &[u8; 62] =
	b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

fn encode62(bytes: &[u8]) -> String {
	if bytes.is_empty() {
		return String::new();
	}

	let mut num =
		bytes.iter().fold(0u128, |acc, &b| (acc << 8) | b as u128);
	let mut result = Vec::new();

	while num > 0 {
		result.push(ALPHABET[(num % 62) as usize]);
		num /= 62;
	}

	let leading_zeros = bytes.iter().take_while(|&&b| b == 0).count();
	result.resize(result.len() + leading_zeros, ALPHABET[0]);

	result.reverse();
	String::from_utf8(result).unwrap()
}

fn decode62(input: &str) -> Result<Vec<u8>, &'static str> {
	if input.is_empty() {
		return Ok(Vec::new());
	}

	const LOOKUP: [u8; 256] = {
		let mut lookup = [0u8; 256];
		let mut i = 0;
		while i < ALPHABET.len() {
			lookup[ALPHABET[i] as usize] = i as u8;
			i += 1;
		}
		lookup
	};

	let bytes = input.as_bytes();
	let leading_zeros =
		bytes.iter().take_while(|&&b| b == ALPHABET[0]).count();

	let mut num = 0u128;
	for &b in &bytes[leading_zeros..] {
		let val = LOOKUP[b as usize] as u128;
		num = num
			.checked_mul(62)
			.and_then(|n| n.checked_add(val))
			.ok_or("Value too large to decode")?;
	}

	let mut result = num
		.to_be_bytes()
		.iter()
		.skip_while(|&&b| b == 0)
		.cloned()
		.collect::<Vec<_>>();

	let mut out = vec![0u8; leading_zeros];
	out.append(&mut result);

	Ok(out)
}

pub struct Base62Decode;

impl PluginCommand for Base62Decode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"decode base62"
	}

	fn description(&self) -> &str {
		"Decode a string or binary value using Base62."
	}

	fn signature(&self) -> Signature {
		crate::util::decode_signature(self.name())
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["decoding"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (string, span) = crate::util::get_string(input, call.head)?;

		match decode62(&string) {
			Ok(out) => Ok(Value::binary(out, call.head)
				.into_pipeline_data()),
			Err(err) => Err(LabeledError::new("Decoding error")
				.with_label(err.to_string(), span)),
		}
	}
}

pub struct Base62Encode;

impl PluginCommand for Base62Encode {
	type Plugin = EndecodePlugin;

	fn name(&self) -> &str {
		"encode base62"
	}

	fn description(&self) -> &str {
		"Encode a string or binary value using Base62."
	}

	fn signature(&self) -> Signature {
		crate::util::encode_signature(self.name())
	}

	fn search_terms(&self) -> Vec<&str> {
		vec!["encoding"]
	}

	fn run(
		&self,
		_plugin: &EndecodePlugin,
		_engine: &EngineInterface,
		call: &EvaluatedCall,
		input: PipelineData,
	) -> Result<PipelineData, LabeledError> {
		let (bytes, _) = crate::util::get_bytes(input, call.head)?;
		let out = encode62(&bytes);
		Ok(Value::string(out, call.head).into_pipeline_data())
	}
}
