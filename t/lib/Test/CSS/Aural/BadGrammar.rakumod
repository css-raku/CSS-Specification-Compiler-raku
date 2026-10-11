use v6;

grammar Test::CSS::Aural::BadGrammar {
    use Test::CSS::Aural::Link::Grammar;
    use CSS::Grammar::CSS21;
    use Test::CSS::Aural::Link::External;
    also is Test::CSS::Aural::Link::Grammar;
    also is CSS::Grammar::CSS21;
    also does Test::CSS::Aural::Link::External;
        # this grammar doesn't provide interface methods - should fail at compilation, e.g.:
        # "Method 'generic-voice' must be implemented by Test::CSS::Aural::BadGrammar because it is required by a role"
}
