use v6;

class Test::CSS::Aural::Actions {
    use Test::CSS::Aural::Gen::Actions;
    use Test::CSS::Aural::Gen::External;
    use CSS::Specification::Base::Actions;
    use CSS::Grammar::Actions;
    also is Test::CSS::Aural::Gen::Actions;
    also is CSS::Specification::Base::Actions;
    also is CSS::Grammar::Actions;

    method proforma:sym<inherit>($/) { make 'keyw' => $/.trim.lc }
}
