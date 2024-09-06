[![CI](https://github.com/0x676e67/vproxy/actions/workflows/ci.yml/badge.svg)](https://github.com/0x676e67/vproxy/actions/workflows/ci.yml)
[![CI](https://github.com/0x676e67/vproxy/actions/workflows/release.yml/badge.svg)](https://github.com/0x676e67/vproxy/actions/workflows/release.yml)
[![Crates.io Version](https://img.shields.io/crates/v/vproxy)](https://crates.io/crates/vproxy)
[![Crates.io Total Downloads](https://img.shields.io/crates/d/vproxy)](https://crates.io/crates/vproxy)

# vproxy

An fast asynchronous Rust `HTTP`/`Socks5` proxy

## Features

- IPv4/IPv6 priority
- Configurable concurrency limits
- Service binding `CIDR` address
- Specify a `CIDR` subnet range
- Basic authentication
- Proxy extensions
- `HTTP`/`SOCKS5` proxy
- SOCKS5 `TCP`/`UDP` proxy

## Sponsor

If you find this project helpful, please consider sponsoring me to support ongoing development:

**USDT-TRC20**: TCwD8HfHnJ7236Hdj3HF5uZKR2keeWeqZe

## Manual

```shell
$ vproxy -h
An easy and powerful Rust HTTP/Socks5 Proxy

Usage: vproxy
       vproxy <COMMAND>

Commands:
  run      Run server
  start    Start server daemon
  restart  Restart server daemon
  stop     Stop server daemon
  ps       Show the server daemon process
  log      Show the server daemon log
  update   Update the application
  help     Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

$ vproxy run -h
Run server

Usage: vproxy run [OPTIONS] <COMMAND>

Commands:
  http    Http server
  socks5  Socks5 server
  help    Print this message or the help of the given subcommand(s)

Options:
      --debug                              Debug mode [env: VPROXY_DEBUG=]
  -b, --bind <BIND>                        Bind address [default: 0.0.0.0:1080]
  -T, --connect-timeout <CONNECT_TIMEOUT>  Connection timeout in seconds [default: 10]
  -c, --concurrent <CONCURRENT>            Concurrent connections [default: 1024]
  -u, --ulimit                             Ulimit soft limit
  -w, --whitelist <WHITELIST>              IP addresses whitelist, e.g. 47.253.53.46,47.253.81.245
  -i, --cidr <CIDR>                        IP-CIDR, e.g. 2001:db8::/32
  -r, --cidr-range <CIDR_RANGE>            IP-CIDR-Range, e.g. 64
  -f, --fallback <FALLBACK>                Fallback address
  -h, --help                               Print help
```

## Installation

If you need more detailed installation and usage information, please check [wiki](https://github.com/0x676e67/vproxy/wiki)

## Contributing

If you would like to submit your contribution, please open a [Pull Request](https://github.com/0x676e67/vproxy/pulls).

## Getting help

Your question might already be answered on the [issues](https://github.com/0x676e67/vproxy/issues)

## License

**vproxy** © [0x676e67](https://github.com/0x676e67), Released under the [GPL-3.0](./LICENSE) License.
