use v6;
use Test::CSS::Aural::Spec::Actions;
use Test::CSS::Aural::Spec::External;
use CSS::Specification::Base::Actions;
use CSS::Grammar::Actions;

class Test::CSS::Aural::Actions
    is Test::CSS::Aural::Spec::Actions
    is CSS::Specification::Base::Actions
    is CSS::Grammar::Actions
    does Test::CSS::Aural::Spec::External {

    method proforma:sym<inherit>($/) { make {'keyw' => ~$<sym>} }
}
