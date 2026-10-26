unit module CSS::Specification::Compiler::Util;

sub name(Str:D $id) is export {  RakuAST::Name.from-identifier($id) }

sub param(Str:D $name) is export {
    RakuAST::Parameter.new(
        target => RakuAST::ParameterTarget::Var.new(:$name)
    )
}

sub expression($expression) is export {
    RakuAST::Statement::Expression.new: :$expression;
}

proto statements($) is export {*}

multi sub statements(@exprs) {
    RakuAST::StatementList.new(|@exprs);
}
multi sub statements($expr) {
    RakuAST::StatementList.new($expr);
}

sub lit's(Str:D $s) is export { RakuAST::StrLiteral.new($s) }
sub lit'i(Str:D $s) is export { RakuAST::IntLiteral.new($s) }
sub lit'r(Str:D $s) is export { RakuAST::Regex::Literal.new($s) }
