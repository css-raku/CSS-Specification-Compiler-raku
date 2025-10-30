CSS-Specification-Compiler
====

Synopsis
--------

```raku
use CSS::Specification::Compiler;
my CSS::Specification::Compiler $compiler .= new;
use JSON::Fast;
$compiler.load-defs: :file<examples/css21-aural.txt>;

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
This module is used to compile [CSS property definitions](https://www.w3.org/TR/css-values-3/)
to Raku Grammars, Actions and Roles, and to extract meta-data.

[CSS::Module](https://raku.land/zef:dwarring/CSS::Module), or similar, can then be used to bundle
the definitions for use by [CSS::Properties](https://raku.land/zef:dwarring/CSS::Properties) and
other CSS related modules.

Status
------
This module is experimental, internal and subject to change. It uses the experimental RakuAST API, the
current version is known to build against Rakudo v2025.10.
