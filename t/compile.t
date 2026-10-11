use Test;
use CSS::Grammar::Test;
use CSS::Grammar::CSS21;
use CSS::Specification::Compiler;
use CSS::Specification::Compiler::Make;
use JSON::Fast;
use lib 't';

my $file = $*SPEC.catfile('examples', 'css21-aural.tsv');

my CSS::Specification::Compiler::Make $maker .= new;
$maker.make-module: '.', "Test::CSS::Aural", ($file,), :lib<t/lib>;
$maker.link: :lib<t/lib>;

my $actions;
lives-ok {$actions = (require ::("Test::CSS::Aural::Actions")).new}, 'class composition - lives';
ok $actions.defined, '::("Test::CSS::Aural::Actions").new';

my $aural-class;
lives-ok {$aural-class = (require ::("Test::CSS::Aural::Grammar"))}, 'grammar composition - lives';
isa-ok $aural-class, CSS::Grammar::CSS21;

for ('.aural-test { stress: 42; speech-rate: fast; volume: inherit; voice-family: female; }' =>
     ast => :stylesheet[
                     :ruleset{
                         :selectors[ :selector[ :simple-selector[ :class<aural-test> ] ] ],
                         :declarations[
                                  :property{ :ident<stress>, :expr[ :num(42) ] },
                                  :property{ :ident<speech-rate>, :expr[ :keyw<fast> ] },
                                  :property{ :ident<volume>, :expr[ :keyw<inherit> ] },
                                  :property{ :ident<voice-family>, :expr[ :keyw<female> ] },
                              ],
                     }
                 ],
     '.boxed-test { border-color: #aaa }' =>
     ast => :stylesheet[
                    :ruleset{
                        :selectors[ :selector[ :simple-selector[ :class<boxed-test> ] ]],
                        :declarations[ :property{
                            :ident<border-color>,
                            :expr[ :rgb[ :num(170), :num(170), :num(170) ]]}],
                    }
                  ],
     ) {
    my ($input, $expected) = .kv;

    &CSS::Grammar::Test::parse-tests($aural-class, $input, 
                                     :$actions, :$expected);
}
done-testing;
