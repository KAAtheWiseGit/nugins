use nu_protocol::{LabeledError, Value};
use serde_json::{Number, Value as JsonValue};

macro_rules! number {
	( $val:ident ) => {
		JsonValue::Number((*$val).into())
	};
}

macro_rules! string {
	( $val:ident ) => {
		JsonValue::String($val.to_string())
	};
}

pub fn value_to_json_value(v: &Value) -> Result<JsonValue, LabeledError> {
	let span = v.span();
	Ok(match v {
		Value::Bool { val, .. } => JsonValue::Bool(*val),
		Value::Date { val, .. } => string!(val),
		Value::Float { val, .. } => {
			if let Some(json_number) = Number::from_f64(*val) {
				JsonValue::Number(json_number)
			} else {
				// JSON doesn't support NaN or Inf, so convert
				// those to a string
				JsonValue::String(val.to_string())
			}
		}
		Value::Int { val, .. } => number!(val),
		Value::Nothing { .. } => JsonValue::Null,
		Value::String { val, .. } => string!(val),
		Value::Glob { val, .. } => string!(val),
		Value::List { vals, .. } => JsonValue::Array(json_list(vals)?),
		Value::Record { val, .. } => {
			let mut m = serde_json::Map::new();
			for (k, v) in &**val {
				m.insert(k.clone(), value_to_json_value(v)?);
			}
			JsonValue::Object(m)
		}
		Value::Custom { val, .. } => {
			let collected = val.to_base_value(span)?;
			value_to_json_value(&collected)?
		}

		v @ Value::Binary { .. }
		| v @ Value::Closure { .. }
		| v @ Value::Range { .. }
		| v @ Value::Duration { .. }
		| v @ Value::Filesize { .. }
		| v @ Value::CellPath { .. } => {
			return Err(LabeledError::new("Unsupported type")
				.with_code("template::unsupported_type")
				.with_label(
					v.get_type().to_string(),
					v.span(),
				))
		}

		Value::Error { error, .. } => {
			return Err(LabeledError::from_diagnostic(&**error));
		}
	})
}

fn json_list(input: &[Value]) -> Result<Vec<JsonValue>, LabeledError> {
	let mut out = vec![];

	for value in input {
		out.push(value_to_json_value(value)?);
	}

	Ok(out)
}
