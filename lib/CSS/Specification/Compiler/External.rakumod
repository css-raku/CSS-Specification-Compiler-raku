unit role CSS::Specification::Compiler::External;

use CSS::Specification::Compiler::Util;

use experimental :rakuast;

method actions { ... }

method build-external(@role-id, Str :$scope = 'our') {
    my RakuAST::Method @methods = self!interface-methods;
    my RakuAST::Statement::Expression @expressions = @methods.map(&expression);
    my RakuAST::Blockoid $body .= new: @expressions.&statements;
    my RakuAST::Name $name .= from-identifier-parts(|@role-id);

    RakuAST::Role.new(
        :$name,
        :body(RakuAST::RoleBody.new: :$body),
        :$scope,
    );
}

#= generate an interface class for all unresolved terms.
method !interface-methods {
    my %unresolved = $.actions.rule-refs;
    %unresolved ,= $.actions.func-refs;
    %unresolved{'prop-val-' ~ $_}:delete
        for $.actions.props.keys;
    %unresolved{$_}:delete
        for $.actions.rules.keys;
    %unresolved{$_}:delete
        for $.actions.funcs.keys;

    my $parameters = RakuAST::Parameter.new(
        slurpy => RakuAST::Parameter::Slurpy::Capture
    );
    my RakuAST::Signature $signature .= new(
        :$parameters
    );

    my RakuAST::Blockoid $body .= new(
        RakuAST::Stub::Fail.new.&expression.&statements
    );

    my Str @stubs = %unresolved.keys.sort;
    @stubs.map: {
        my RakuAST::Name $name = .&name;
        RakuAST::Method.new: :$name, :$signature, :$body;
    }
}
