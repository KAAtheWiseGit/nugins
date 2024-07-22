# More formats for `encode`/`decode`

One day, while tinkering with [Iroh](https://iroh.computer), I had a
need to convert one identifier from Base32 to z-base-32.  This sent me
down a rabbit hole of all the binary-to-text encoding schemes.  It turns
out, there are quite a few out there.

This plugin provides the following ones:

- Base32 and `base32hex` from [RFC4648][rfc4648], with lowercase
  variants.

- [Crockford's Base32][crockford].

- [`z-base-32`][z32].

- ZeroMQ's [Z85][z85], a relaxed version (byte length doesn't have to be
  the multiple of 4).

- Base58, mostly used by cryptocurrencies.

See `help encode` for the command names.


[rfc4648]: https://datatracker.ietf.org/doc/html/rfc4648#section-6
[crockford]: https://www.crockford.com/base32.html
[z32]: https://philzimmermann.com/docs/human-oriented-base-32-encoding.txt
[z85]: https://rfc.zeromq.org/spec/32/
