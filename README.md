CSS-Specification-Compiler
====

Synopsis
--------

```raku
use CSS::Specification::Compiler;
my CSS::Specification::Compiler $compiler .= new;
use JSON::Fast;
$compiler.load-defs: :file<examples/css21-aural.tsv>;

# output Raku code
mkdir 'lib/MyCSS';

# output main grammar
'lib/MyCSS/Grammar.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-grammar: <MyCSS Grammar>;

# output a corresponding grammar parse actions class
'lib/MyCSS/Actions.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-actions: <MyCSS Actions>;

# output stubs for any external rule references
'lib/MyCSS/External.rakumod'.IO.spurt: .DEPARSE
    given $compiler.build-external: <MyCSS External>;

# output associated metadata
mkdir 'resources';
'resources/MyCSSMeta.json'.IO.spurt: $compiler.metadata.&to-json(:sorted-keys);
```

Description
-----------
This module is used to compile sets of [CSS property definitions](https://www.w3.org/TR/css-values-3/)
to Raku Grammars, Actions, External references, and to extract Metadata.

[CSS::Module](https://raku.land/zef:dwarring/CSS::Module), or similar, can then be used to bundle
the definitions for use by [CSS::Properties](https://raku.land/zef:dwarring/CSS::Properties) and
other downstream CSS related modules.

Status
------
This module may be subject to change. It uses RakuAST API, which is classed as experimental.
The current version was most recently tested against Rakudo 2026.05

It has been used to transpile property value definitions to Raku for recent CSS::Module releases.
