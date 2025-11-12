unit role CSS::Specification::Compiler::Actions;

use CSS::Specification::Compiler::Util;

use experimental :rakuast;

method actions { ... }
method defs { ... }

method build-actions(@actions-id, Str :$scope = 'our') {
    my RakuAST::Method @methods = self!actions-methods;
    my RakuAST::Statement::Expression @expressions = @methods.map(&expression);
    my RakuAST::Blockoid $body .= new: @expressions.&statements;
    my RakuAST::Name $name .= from-identifier-parts(|@actions-id);
    RakuAST::Class.new(
        :$name,
        :$body,
        :$scope,
    );
}

sub call-make-func(Str $name) {
    my RakuAST::StrLiteral $lit .= new($name);
    my RakuAST::QuotedString $qstr .= new: :segments($lit,);
    RakuAST::Blockoid.new(
        RakuAST::Var::Attribute::Public.new(
            :name('$.make-func'),
            args => RakuAST::ArgList.new(
                $qstr,
                RakuAST::Var::Lexical.new("\$/")
            )
        ).&expression.&statements
    );

}

sub build-action(Str $id) {
    RakuAST::Blockoid.new(
        RakuAST::Call::Name::WithoutParentheses.new(
            name => RakuAST::Name.from-identifier("make"),
            args => RakuAST::ArgList.new(
                RakuAST::ApplyPostfix.new(
                    operand => RakuAST::Var::Attribute::Public.new(
                        name => "\$.build"
                    ),
                    postfix => RakuAST::Call::Method.new(
                        name => RakuAST::Name.from-identifier($id),
                        args => RakuAST::ArgList.new(
                            RakuAST::Var::Lexical.new("\$/")
                        )
                    )
                )
            )
        ).&expression.&statements
    );
}

method !actions-methods {
    my RakuAST::Method @methods;
    my %references = $.actions.rule-refs;
    %references ,= $.actions.func-refs;

    my RakuAST::Signature $signature .= new(
        :parameters( '$/'.&param )
    );

    my $val-body  = 'list'.&build-action;
    my $rule-body = 'rule'.&build-action;

    for @.defs -> $def {
        if $def<props> -> @props {
            for @props -> $prop {
                my $val = 'prop-val-' ~ $prop;
                if %references{$val}:delete && !$.actions.rules{$val} {
                    my RakuAST::Name $name = $val.&name;
                    @methods.push: RakuAST::Method.new: :$name, :$signature, body => $val-body;
                }
            }
        }
        elsif $def<rule> -> $rule {
           my RakuAST::Name $name = $rule.&name;
            @methods.push: RakuAST::Method.new: :$name, :$signature, body => $rule-body;
        }
    }

    for $.actions.funcs.keys.sort {
        my $name = .&name;
        @methods.push: RakuAST::Method.new: :$name, :$signature, body => .&call-make-func;
    }

    @methods;
}
