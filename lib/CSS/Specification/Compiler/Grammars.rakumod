unit role CSS::Specification::Compiler::Grammars;

use CSS::Specification::Compiler::Util;

use experimental :rakuast;

method actions { ... }
method defs { ... }

proto sub compile (|c) is export(:compile) {
    {*}
}

multi sub modifier('i') { RakuAST::Regex::InternalModifier::IgnoreCase.new }

sub rule(RakuAST::Name:D $name, RakuAST::Regex:D $body) {
    RakuAST::RuleDeclaration.new(
            :$name,
            :$body,
        )
}

sub property-decl(Str:D $prop-name, :$quant, Str:D :$base-val!) {
    my RakuAST::Name $name = "decl:sym<$prop-name>".&name;
    my RakuAST::Regex $regex-body = RakuAST::Regex::Assertion::Alias.new(
        name      => "expr",
        assertion => $base-val.&assertion(:!capturing),
    );

    if $quant ~~ Array:D {
        my RakuAST::Regex::Quantifier $quantifier = quant($quant);
        $regex-body = RakuAST::Regex::QuantifiedAtom.new: :atom($regex-body), :$quantifier;
    }

    $name.&rule(
        seq (
            'i'.&modifier,
            RakuAST::Regex::CapturingGroup.new(
                $prop-name.&lit.&seq
            ).&ws,
            RakuAST::Regex::Quote.new(
                RakuAST::QuotedString.new(
                    segments   => (
                        RakuAST::StrLiteral.new(":"),
                    )
                )
            ).&ws,
            RakuAST::Regex::Assertion::Named::Args.new(
                name      => 'val'.&name,
                args      => RakuAST::ArgList.new(
                    RakuAST::QuotedRegex.new(
                        body => $regex-body.&ws,
                    ),
                    RakuAST::Var::Compiler::Routine.new.&postfix('WHY'.&call),
                ),
                :capturing
            )
        )
    );
}

multi sub compile(:@props!, :$default, Pair :$spec! is copy, Str :$synopsis!, Bool :$inherit = True) {
    my $quant;
    if $spec.key eq 'occurs' && $spec.value.head ~~ [1,4]  {
        ($quant, $spec) = $spec.value.List;
    }
    my RakuAST::Regex $body = $spec.&compile;
    $body = ('i'.&modifier,  $body.&ws, ).&seq;
    my Str $leading = (@props.head, ': ', $_, "\n").join
        given $synopsis;

    my RakuAST::Statement::Expression @exprs;

    for @props -> $prop {
        my $base-val = 'prop-val-' ~ $prop;
        @exprs.push: $prop.&property-decl(:$quant, :$base-val).declarator-docs(
            :$leading
        ).&expression;
        @exprs.push: $base-val.&name.&rule($body).&expression
            unless $*ACTIONS.rules{$base-val};
    }

    @exprs;
}

multi sub compile(Str :$rule!, :$spec!, Str :$synopsis!) {
    my RakuAST::Regex $body = $spec.&compile;
    $body = ('i'.&modifier,  $body.&ws, ).&seq;

    my Str $leading = $_ ~ "\n" given $synopsis;
    my RakuAST::Name $name = $rule.&name;

    $name.&rule($body).declarator-docs(
        :$leading
    ).&expression.List
}

multi sub compile(:@occurs! ($quant!, *%term)) {
    my RakuAST::Regex $atom = (|%term).&compile.&group.&ws;
    my %opt;
    %opt<separator> = compile(:op<,>)
       if $quant.tail ~~ ',';
    %opt<trailing-separator> = .value
       with $quant.first: {.isa(Pair) && .key eq 'trailing'};
    my RakuAST::Regex::Quantifier $quantifier = quant($quant);
    RakuAST::Regex::QuantifiedAtom.new: :$atom, :$quantifier, |%opt;
}

multi sub quant('?') { RakuAST::Regex::Quantifier::ZeroOrOne.new }
multi sub quant('*') { RakuAST::Regex::Quantifier::ZeroOrMore.new }
multi sub quant('+') { RakuAST::Regex::Quantifier::OneOrMore.new }
multi sub quant(',') { RakuAST::Regex::Quantifier::OneOrMore.new }
multi sub quant(@ ( UInt:D $min, UInt:D $max, *@) ) {
    RakuAST::Regex::Quantifier::Range.new: :$min, :$max
}
multi sub quant(@ ( Str:D $_, ',', :trailing($)) ) {  # list-maybe
    .&quant;
}

sub look-ahead(RakuAST::Regex::Assertion $assertion, Bool :$negated = False) is export {
    RakuAST::Regex::Assertion::Lookahead.new(
        :$assertion, :$negated
    );
}

proto sub assertion(|) is export {*}
multi sub assertion(Str:D $id, Bool :$capturing = True, RakuAST::ArgList :$args!) {
    my RakuAST::Name $name := $id.&name;
    RakuAST::Regex::Assertion::Named::Args.new(
        :$name, :$capturing, :$args,
    );
}

multi sub assertion(Str:D $id, Bool :$capturing = True) {
    my RakuAST::Name $name := $id.&name;
    RakuAST::Regex::Assertion::Named.new(
        :$name, :$capturing,
    );
}

proto sub arg(|) is export {*}
multi sub arg(Str:D $arg) {
    RakuAST::ArgList.new: RakuAST::StrLiteral.new($arg);
}

multi sub arg(Int:D $arg) {
    RakuAST::ArgList.new: RakuAST::IntLiteral.new($arg);
}

multi sub ws(RakuAST::Regex::WithWhitespace $w) is export { $w }
multi sub ws(RakuAST::Regex $r) is export { RakuAST::Regex::WithWhitespace.new($r) }

sub lit(Str:D $s) is export { RakuAST::Regex::Literal.new($s) }

multi sub group(RakuAST::Regex::Group $g) {$g}
multi sub group(RakuAST::Regex::Assertion $a) {$a}
multi sub group(RakuAST::Regex $r) is export  {
    RakuAST::Regex::Group.new: $r
}

sub alt(@choices) is export {
    RakuAST::Regex::Alternation.new: |@choices;
}

multi sub seq(@seq) {
    RakuAST::Regex::Sequence.new(|@seq);
}
multi sub seq($seq) { $seq }

multi sub seq-alt(@seq) is export  { RakuAST::Regex::SequentialAlternation.new: |@seq }
sub conjunct(RakuAST::Regex $r1, RakuAST::Regex $r2) is export {
    RakuAST::Regex::Conjunction.new($r1, $r2);
}

sub lexical(Str:D $sym) is export {
    RakuAST::Var::Lexical.new($sym)
}

sub array-index($_) is export {
    RakuAST::Postcircumfix::ArrayIndex.new(
        index => RakuAST::SemiList.new(.&expression)
    )
}

sub call(Str:D $id, :@args) is export {
    my RakuAST::Name $name = $id.&name;
    my RakuAST::ArgList $args .= new(|@args)
        if @args;
    RakuAST::Call::Method.new: :$name, :$args;
}

multi sub postfix($operand, Str:D $operator) {
    $operand.&postfix: RakuAST::Postfix.new(:$operator);
}

multi sub postfix($operand, $postfix) {
    RakuAST::ApplyPostfix.new(
        :$operand, :$postfix
    )
}

sub unseen(Str:D $var) is export {
    my RakuAST::Var $operand = $var.&lexical;
    my RakuAST::Blockoid $body .= new(
        RakuAST::StatementList.new(
            expression $operand.&postfix('++')
        )
    );
    my RakuAST::Block $block .= new: :$body;
    RakuAST::Regex::Assertion::PredicateBlock.new(
        :$block, :negated,
    )
 }

multi sub compile(Str:D :$keyw!) {
    conjunct $keyw.&lit-ws, 'keyw'.&assertion;
}

multi sub compile(Str:D() :$num!) {
    conjunct $num.&lit-ws, 'number'.&assertion;
}

sub _choice(@lits, RakuAST::Regex $term2) {
    my RakuAST::Regex $term1 = @lits == 1 ?? @lits[0] !! @lits.&alt.&group;
    conjunct($term1, $term2);
}

multi sub compile(Str:D :$rule!) {
    $rule.&assertion;
}

multi sub compile(:@keywords!) {
    _choice @keywords.map(&lit-ws), 'keyw'.&assertion.&ws;
}

multi sub compile(:@numbers!) {
    _choice @numbers.map(&lit-ws), 'number'.&assertion;
}

sub lit-ws(Str:D() $_) is export { .&lit.&ws }

multi sub compile(Str:D :$op!) {
    my RakuAST::ArgList $args = $op.&arg;
    'op'.&assertion(:$args);
}

multi sub compile(:@alt!)   { seq-alt @alt.map(&compile).map(&ws) }
multi sub compile(:@seq!)   { seq @seq.map(&compile).map(&ws) }
multi sub compile(:$group!) { group $group.&compile }

multi sub compile(:required(@combo)!) {
    compile(:@combo, :required);
}

multi sub compile(:@combo!, Bool :$required) {
    my Str $v = 'A';
    my @atoms = @combo.map: {
        my \id = $v++;
        my $desigilname = id.&name;
        my RakuAST::VarDeclaration::Simple $decl .= new(
            :sigil('$*'), :$desigilname,
        );
        my RakuAST::Regex::Statement $unseen-var-decl .= new: $decl.&expression;
        my RakuAST::Regex::Assertion $unseen-assertion = ('$*'~id).&unseen;
        my RakuAST::Regex $term = .&compile;
        [$term.&ws, $unseen-var-decl, $unseen-assertion].&seq;
    }
    my $atom = @atoms == 1 ?? @atoms.head !! @atoms.&alt.&group;
    my UInt $n = +@combo;
    my RakuAST::Regex::Quantifier $quantifier = $required
        ?? quant([$n, $n])
        !! quant('+');

    RakuAST::Regex::QuantifiedAtom.new: :$atom, :$quantifier;
}

multi sub compile(Str:D :func($rule)!, |c) {
    compile :$rule, |c;
}

multi sub compile(:%proto! ( :$func!, *%) ) {
    # nb: prototype has been saved in %.actions.funcs
    compile :$func;
}

multi sub compile(:%func-spec! ( :$func!, :$signature!, :$synopsis!) ) {

    my constant Usage =  RakuAST::Regex::Assertion::Named::Args.new(
        name      => 'usage'.&name,
        args      => RakuAST::ArgList.new(
            RakuAST::Var::Compiler::Routine.new.&postfix('WHY'.&call),
        ),
        :capturing
    );
    my $args = [$signature.&compile.&ws, Usage].&seq-alt.&ws.&group;
    my $body = ['i'.&modifier,
                ($func ~ '(').&lit.&ws, $args.&ws, ')'.&lit].&seq.&ws;
    my Str $leading = $_ ~ "\n" given $synopsis;
    $func.&name.&rule($body).declarator-docs(:$leading);
}

multi sub compile($arg) { compile |$arg }

method build-grammar(@grammar-id, Str :$scope = 'our') {
    my $*ACTIONS = $.actions;
    my RakuAST::Name $name .= from-identifier-parts(|@grammar-id);
    my @compiled = flat @.defs.map: &compile;
    my RakuAST::StatementList $statements .= new: |@compiled;
    my RakuAST::Block $body .= new: :body(RakuAST::Blockoid.new: $statements);

    RakuAST::Grammar.new(
        :$name,
        :$body,
        :$scope,
    );
}
