#!/usr/bin/env perl6

#= compiles w3c property definitions to Raku roles, grammars or actions.

use CSS::Specification::Compiler;

#| e.g. css-compile --grammar=MyCSS::Grammar examples/css21-aural.txt> MyCSS/Grammar.rakumod
multi sub MAIN(Str:D $file, Str :$grammar!, :$scope='unit') {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs($file);
    my @id = $grammar.split('::');
    say .DEPARSE given $compiler.build-grammar(@id, :$scope);
}

multi sub MAIN(Str:D $file, Str :$actions!, :$scope='unit') {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs($file);
    my @id = $actions.split('::');
    say .DEPARSE given $compiler.build-actions(@id, :$scope);
}

multi sub MAIN(Str:D $file, Str :$role!, :$scope='unit') {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs($file);
    my @id = $role.split('::');
    say .DEPARSE given $compiler.build-role(@id, :$scope);
}

multi sub MAIN(Str:D $file, :$scope='unit') {
    $file.&MAIN( :$scope, :grammar<CSSGrammar>);
}

