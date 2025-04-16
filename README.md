# ${\color{Cyan}bglib}$
A personal set of utility / convenience functions and macros.

## Cooler Features
### `bglib.oops`
object oriented patterns using macros

### `bglib.ExceptionHandler`
A macro which adds a global exception handler to your project

### `bglib.macros.extractMetadata`
Extracts metadata entry parameters into a null safe struct, with error handling.

### `bglib.macros.Unpack`
Adds dynamic array/vector and struct unpacking to haxe

### `bglib.utils.PrimitiveTools.dynamicMatch`
Adds dynamic enum matching, check [`EnumMatch.hx`](./examples/EnumMatch.hx).


# Usage

For now
```
haxelib git bglib https://github.com/Bgabri/bglib
```

Alternatively use `./link.sh src/bglib path/to/proj` to directly insert the library.

# Examples
Some examples are available in [`./examples`](./examples/).
```
haxe examples.hxml --run TestCli
```

# Tests
run
```
haxe tests.hxml
```