unit role CSS::Specification::Compiler::Actions;

use CSS::Specification::Compiler::Util;

use experimental :rakuast;

method actions { ... }
method defs { ... }

method compile-actions(@actions-id, Str :$scope = 'our', Bool :$role) {
    my RakuAST::Method @methods = self!actions-methods;
    my RakuAST::Statement::Expression @expressions = @methods.map(&expression);
    my RakuAST::Blockoid $body .= new: @expressions.&statements;
    my RakuAST::Name $name .= from-identifier-parts(|@actions-id);
    $role
        ?? RakuAST::Role.new( :$name, :body(RakuAST::RoleBody.new: :$body), :$scope)
        !! RakuAST::Class.new(:$name, :$body, :$scope );
}

method link-actions(@group-id, @modules, Str :$scope = 'our') {
    my RakuAST::Name @module-names = @modules.map: -> @module-ids {
        RakuAST::Name.from-identifier-parts: |@module-ids;
    }
    my RakuAST::Statement @used = @module-names.map: -> $module-name { RakuAST::Statement::Use.new: :$module-name }
    my RakuAST::Trait::Is @traits =  @module-names.map: -> $name {
        RakuAST::Trait::Is.new: :$name;
    }
    my RakuAST::Name $name .= from-identifier-parts(|@group-id);
    my RakuAST::Blockoid $body .= new: @used.&statements;
    RakuAST::Class.new(:$name, :$scope, :$body, :@traits );
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

sub compile-action(Str $id) {
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

    my RakuAST::Signature $signature .= new(
        :parameters( '$/'.&param )
    );

    my $val-body  = 'list'.&compile-action;
    my $rule-body = 'rule'.&compile-action;

    for @.defs -> $def {
        if $def<rule-spec> -> % (:$rule!, *%) {
            my RakuAST::Name $name = $rule.&name;
            @methods.push: RakuAST::Method.new: :$name, :$signature, body => $rule-body;
        }
        elsif $def<func-spec> -> % (:$rule, :$func, *%){
            if $rule {
                my RakuAST::Name $name = $rule.&name;
                @methods.push: RakuAST::Method.new: :$name, :$signature, body => $func.&call-make-func;
            }
        }
    }

    for $.actions.funcs.keys.sort {
        my $name = .&name;
        @methods.push: RakuAST::Method.new: :$name, :$signature, body => .&call-make-func;
    }

    @methods;
}
