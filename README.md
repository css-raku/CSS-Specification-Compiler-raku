CSS-Specification-Compiler
====

Synopsis
--------

```raku
use CSS::Specification::Compiler;
my CSS::Specification::Compiler $compiler .= new;
use JSON::Fast;
$compiler.load-defs: "examples/css21-aural.txt";

# output Raku code
mkdir 'lib/MyCSS';

# output main grammar
'lib/MyCSS/Grammar.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-grammar: <MyCSS Grammar>;

# output grammar actions
'lib/MyCSS/Actions.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-actions: <MyCSS Actions>;

# output stubs for external rule references
'lib/MyCSS/Externals.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-role: <MyCSS Externals>;

# output associated metadata
mkdir 'resources';
'resources/MyCSSMeta.json'.IO.spurt: to-json($compiler.metadata, :sorted-keys);
```

Description
-----------
This is an internal module, used by
CSS::Module to build modules: CSS::Module::{CSS1|CSS21|CSS3|SVG}".

Status
------
This module is experimental, internal and subject to change. It uses the experimental RakuAST API, the
current version is known to build against Rakudo v2025.10.
