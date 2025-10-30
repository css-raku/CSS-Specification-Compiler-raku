# compiles w3c property definitions to Raku roles, grammars or actions.
use CSS::Specification::Compiler;

subset Name of Str;
subset Scope of Str where 'our'|'unit';

multi sub MAIN(Str $file?, Name :$grammar!, Scope :$scope='unit')  is hidden-from-backtrace {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs(:$file);
    my @id = $grammar.split('::');
    say .DEPARSE given $compiler.build-grammar(@id, :$scope);
}

multi sub MAIN(Str $file?, Name :$actions!, Scope :$scope='unit')  is hidden-from-backtrace {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs(:$file);
    my @id = $actions.split('::');
    say .DEPARSE given $compiler.build-actions(@id, :$scope);
}

multi sub MAIN(Str $file?, Name :$role!, Scope :$scope='unit')  is hidden-from-backtrace {
    my CSS::Specification::Compiler $compiler .= new;
    $compiler.load-defs(:$file);
    my @id = $role.split('::');
    say .DEPARSE given $compiler.build-role(@id, :$scope);
}

multi sub MAIN(Str $file?, Bool :$metadata!) is hidden-from-backtrace {
    my CSS::Specification::Compiler $compiler .= new;
     $compiler.load-defs(:$file);
    say $compiler.metadata.raku;
}

multi sub MAIN(Str $file?, Scope :$scope='unit')  is hidden-from-backtrace {
    $file.&MAIN( :$scope, :grammar<CSSGrammar>);
}

