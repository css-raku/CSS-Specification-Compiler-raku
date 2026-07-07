unit class CSS::Specification::Compiler;

use CSS::Specification::Compiler::Actions;
also does CSS::Specification::Compiler::Actions;

use CSS::Specification::Compiler::Grammars;
also does CSS::Specification::Compiler::Grammars;

use CSS::Specification::Compiler::External;
also does CSS::Specification::Compiler::External;

use CSS::Specification;
use CSS::Specification::Actions;
has CSS::Specification::Actions:D $.actions handles<child-rules> .= new;
has Associative @.defs;

multi method load-defs(:@specs!) is hidden-from-backtrace {
    for @specs -> $spec is copy {
        # handle full line comments
        next if $spec.starts-with('#') || $spec eq '';
        # '| inherit' and '| initial' are implied, context dependant, and
        # inconsistantly specified. Treat them as implied.
        $spec .= subst(/\s* '|' \s* [inherit|initial]/, '', :g);
        my $/ = CSS::Specification.subparse($spec, :$!actions )
            // die "unable to parse: $spec";
        my $ast = $/.ast;
        @!defs.append: @$ast;
    }

    @!defs;
}

multi method load-defs(IO:D() :$file = $*IN) is hidden-from-backtrace {
    my @specs = $file.slurp.subst("\\\n", '', :g).lines;
    self.load-defs: :@specs;
}

multi method load-defs() is hidden-from-backtrace {
    my @specs = $*IN.lines;
    self.load-defs: :@specs;
}

has Hash $!metadata;
method metadata {
    $!metadata //= @!defs.&build-metadata: :%.child-rules;
}

sub build-metadata(@defs, :%child-rules --> Hash) is export(:build-metadata) {
    my %props;
    my %specs;

    for @defs
        .grep(*.<prop-spec>)
        .map(*.<prop-spec>)
        .sort(*.<props>[0])
         -> % (:@props!, :$synopsis!, Bool:D :$inherit = False, :$default, :%spec!, *%) {
        my %details = :$synopsis, :$inherit;
        %details<default> = $_ with $default;

        for @props.flat -> $prop-name {
            %specs{$prop-name} = %spec;
            %props{$prop-name} = %details;
        }
    }
    %props.&find-edges(%child-rules);
    %props.&check-edges;
    %props;
}

sub find-child-props($rule-name, %child-rules, %seen = %()) {
    my @kids;
    with %child-rules{$rule-name} {
       for .grep({!%seen{$_}++}) -> $child {
           @kids.push: $child;
           @kids.append: $child.&find-child-props(%child-rules, %seen);
       }
    }
    @kids;
}

sub find-edges(%props, %child-rules) {
    # match boxed properties with children
    for %props.kv -> $key, $value {
        unless $key ~~ / '-'[top|right|bottom|left]<?before ['-'|$$]> / {
            # see if the property has any children
            for <top right bottom left> -> $side {
                # find child. could be xxxx-side (e.g. margin-left)
                # or xxx-yyy-side (e.g. border-left-width);
                for $key ~ '-' ~ $side, $key.subst("-", [~] '-', $side, '-') -> $edge {
                    if $edge ne $key && (%props{$edge}:exists) {
                        my $prop = %props{$edge};
                        $prop<edge> = $key;
                        $value<edges>.push: $edge;
                        $value<box> ||= True;
                        last;
                    }
                }
            }
        }
    }
    for %props.kv -> $prop-name, $value {
        my $edges =  $value<edges> // {};
        my @child-rules = ('css-val-' ~ $prop-name).&find-child-props(%child-rules);
        my @child-props = @child-rules.grep(*.starts-with: 'css-val-').map(*.substr(8)).grep({!$edges{$_}}).unique;
        if @child-props {
            $value<children> = @child-props;
        }
        # we can get defaults from the children
        $value<default>:delete
            if ($value<edges>:exists)
            || ($value<children>:exists);
    }
}

sub check-edges(%props) {
    for %props.kv -> $key, $value {
        my $edges = $value<edges>;

        note "box property doesn't have four edges $key: $edges"
            if $edges && +$edges != 4;

        if $value<children> -> $children {
            if $value<edge> {
                my $non-edges = $children.grep: { ! %props{$_}<edge> };
                note "edge property $key has non-edge properties: $non-edges"
                    if $non-edges;
            }
        }
    }
}
