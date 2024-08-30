# More formats for `encode`/`decode`

One day, while tinkering with [Iroh](https://iroh.computer), I had a
need to convert one identifier from Base32 to z-base-32.  This sent me
down a rabbit hole of all the binary-to-text encoding schemes.  It turns
out, there are quite a few out there.

This plugin provides the following bases:

- `encode crockford`: [Crockford's Base32][crockford].

- `decode/encode z32`: [`z-base-32`][z32], a "human-oriented" base-32
  encoding.

- `decode/encode z85`: ZeroMQ's [Z85][z85], a relaxed version (byte
  length doesn't have to be the multiple of 4).

- `decode/encode base58`: Base58, mostly used by cryptocurrencies.

As well as a number of miscellaneous encodings:

- `decode/encode html`: HTML entities escaping and unescaping.

- `decode unicode`: converts Unicode strings to plain ASCII using the
  [`deunicode`][deunicode] library.


[rfc4648]: https://datatracker.ietf.org/doc/html/rfc4648#section-6
[crockford]: https://www.crockford.com/base32.html
[z32]: https://philzimmermann.com/docs/human-oriented-base-32-encoding.txt
[z85]: https://rfc.zeromq.org/spec/32/
[deunicode]: https://lib.rs/crates/deunicode
