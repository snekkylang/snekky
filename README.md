# Snekky Language

The Snekky Programming Language

<a href="https://snekky.senkju.net/">Playground</a>

### Disclaimer!
Please do not take this project too seriously. I'm in no way a professional. To be honest, I'm surprised myself that Snekky is even somewhat usable.

## Installation

1. Clone repository
2. Compile it (`haxe build.hxml`)

## Usage

1. Create a file with .snek extension
2. Run ist using `Snekky`

## Benchmarks
Based on <a href="https://benchmarksgame-team.pages.debian.net/benchmarksgame/">Benchmarksgame</a>

|               | C     | Rust  | Go    | Java | NodeJs | Snekky   |
|---------------|-------|-------|-------|------|--------|----------|
| Spectral Norm | 1.98s | 1.98s | 3.95s | 4.2s | 4.27s  | 1h 44min |

## Why you should be using Snekky
<img src="https://axolotl.vip/PmMKa9an.png?key=3fFhm7yeiawmiJ">

## Example
```
let add = func(a, b) {
    let result = a + b;

    print(result);
}

add(1, 2);

mut i = 0;
while i < 10 {
    if i > 5 {
        print("Snek");
    } else {
        print(i);
    }

    i = i + 1;
}
```

## Contributing

1. Fork it (<https://github.com/snekkylang/snekky/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Senk Ju](https://github.com/snekkylang/snekky) - creator and maintainer
