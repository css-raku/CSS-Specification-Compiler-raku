CSS-Specification-Compiler
====

Synopsis
--------

```raku
use CSS::Specification::Compiler;
my CSS::Specification::Compiler $compiler .= new;
$compiler.load-defs: "examples/css21-aural.txt";

# output Raku code
mkdir 'lib/CSS';

# output main grammar
"lib/CSS/Grammar.rakumod".IO.spurt: .DEPARSE
    given $compiler.build-grammar: <CSS Grammar>;

# output grammar actions
"lib/CSS/Actions.rakumod".IO.spurt: .DEPARSE
    given $compiler.build-actions: <CSS Actions>;

# output stubs for external rule references
"lib/CSS/Externals.rakumod".IO.spurt: .DEPARSE
    given $compiler.build-role: <CSS Externals>;
```
