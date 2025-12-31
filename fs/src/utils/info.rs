use chrono::{DateTime, FixedOffset, Utc};
use nu_protocol::{record, Filesize, Record, Span, Value};

use std::{
	fs::{FileType, Metadata},
	os::unix::fs::MetadataExt,
	path::Path,
};

pub fn metadata_to_record(
	span: Span,
	path: &Path,
	metadata: &Metadata,
) -> Record {
	let file_type = fs_type(metadata.file_type());
	let size = Filesize::new(metadata.size() as i64);
	let modified: DateTime<Utc> = metadata.modified().unwrap().into();
	let modified: DateTime<FixedOffset> = modified.into();

	let out = record!(
		"name" => Value::string(path.to_string_lossy(), span),
		"type" => Value::string(file_type, span),
		"size" => Value::filesize(size, span),
		"modified" => Value::date(modified, span),
	);

	out
}

pub fn fs_type(metadata: FileType) -> &'static str {
	#[cfg(unix)]
	use std::os::unix::fs::FileTypeExt;

	#[cfg(unix)]
	if metadata.is_block_device() {
		return "block device";
	} else if metadata.is_char_device() {
		return "char device";
	} else if metadata.is_fifo() {
		return "fifo";
	} else if metadata.is_socket() {
		return "socket";
	}

	if metadata.is_dir() {
		"dir"
	} else if metadata.is_file() {
		"file"
	} else if metadata.is_symlink() {
		"symlink"
	} else {
		"unknown"
	}
}
