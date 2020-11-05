# Snekky Language 🐍

The Snekky Programming Language

<a href="https://snekky-lang.org">Playground</a>

### Disclaimer!
Please do not take this project too seriously. I'm in no way a professional. To be honest, I'm surprised myself that Snekky is even somewhat usable.

## Features
- Built-in REPL.
- Familiar syntax.
- Compiles to a custom bytecode.
- Arrays and hashes.
- Lambdas and closures are supported.
- `if`s and functions may implicitly return a value.
- Final (`let`) and mutable (`mut`) variables.
- Destructuring of arrays and hashes.
- `for ... in` loops with iterators.
- As flexible and dynamic as a snek.

## Installation
#### Compile it yourself
1. Download and install [Haxe](https://haxe.org/).
2. Clone this repository.
3. Compile the project by executing `haxe build.hxml`.

#### Download release binaries
Release binaries can be found on the [releases tab](https://github.com/snekkylang/snekky/releases). \
Binaries of the latest unreleased version can be found on the [actions tab](https://github.com/snekkylang/snekky/actions).

## Usage

1. Create a file called `input.snek`
2. Run it using `Snekky.exe input.snek`

## Example
```
// This is a comment
let add = func(a, b) {
    let result = a + b;

    Sys.println(result);
};

add(1, 2);

mut i = 0;
while i < 10 {
    Sys.println(
        if (i > 5) {
            "Snek"
        } else {
            i
        }
    );

    i += 1;
}

func(msg) {
    Sys.println("Self-invoking function says " >< msg);
}("Axolotls are cool!");
```

## Contributing

1. Fork it (<https://github.com/snekkylang/snekky/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Senk Ju](https://github.com/snekkylang/snekky) - creator and maintainer
