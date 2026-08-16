unit role CSS::Specification::Compiler::Puncuation;
has %.puncuation is built;

sub puncuate(|c) {
    dd c;
}

method compile-puncuation {
    %!puncuation{.key} = .value.&puncuate
        for $.actions.props;
}
