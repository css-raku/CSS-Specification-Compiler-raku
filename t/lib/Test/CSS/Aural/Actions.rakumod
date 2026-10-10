use v6;
use Test::CSS::Aural::Gen::Actions;
use Test::CSS::Aural::Gen::External;
use CSS::Specification::Base::Actions;
use CSS::Grammar::Actions;

class Test::CSS::Aural::Actions
    is Test::CSS::Aural::Gen::Actions
    is CSS::Specification::Base::Actions
    is CSS::Grammar::Actions {

    method proforma:sym<inherit>($/) { make 'keyw' => $/.trim.lc }
}
