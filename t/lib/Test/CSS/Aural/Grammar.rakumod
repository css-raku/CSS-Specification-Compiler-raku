
grammar Test::CSS::Aural::Grammar {
    use Test::CSS::Aural::Link::Grammar;
    use Test::CSS::Aural::Link::External;
    use CSS::Specification::Base::Grammar;
    use CSS::Grammar::CSS21;


    also is Test::CSS::Aural::Link::Grammar;
    also is CSS::Specification::Base::Grammar;
    also is CSS::Grammar::CSS21;
    also does Test::CSS::Aural::Link::External;

    proto rule proforma {*}
    rule proforma:sym<inherit> { <sym> }
}
