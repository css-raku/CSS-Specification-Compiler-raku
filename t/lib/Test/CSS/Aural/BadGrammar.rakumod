use v6;

grammar Test::CSS::Aural::BadGrammar {
    use Test::CSS::Aural::Gen::Grammar;
    use CSS::Grammar::CSS21;
    use Test::CSS::Aural::Gen::Interface;
    also is Test::CSS::Aural::Gen::Grammar;
    also is CSS::Grammar::CSS21;
    also does Test::CSS::Aural::Gen::Interface;
        # this grammar doesn't provide interface methods - should fail at compilation, e.g.:
        # "Method 'generic-voice' must be implemented by Test::CSS::Aural::BadGrammar because it is required by a role"
}
