
use Test::CSS::Aural::Gen::Grammar;
use Test::CSS::Aural::Gen::External;
use CSS::Specification::Base::Grammar;
use CSS::Grammar::CSS21;

grammar Test::CSS::Aural::Grammar
    is Test::CSS::Aural::Gen::Grammar
    is CSS::Specification::Base::Grammar
    is CSS::Grammar::CSS21
    does Test::CSS::Aural::Gen::External {

    proto rule proforma {*}
    rule proforma:sym<inherit> { <sym> }
}
