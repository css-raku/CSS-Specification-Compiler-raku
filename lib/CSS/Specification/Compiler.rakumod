unit class CSS::Specification::Compiler;

use CSS::Specification::Compiler::Actions;
also does CSS::Specification::Compiler::Actions;

use CSS::Specification::Compiler::Grammars;
also does CSS::Specification::Compiler::Grammars;

use CSS::Specification::Compiler::Roles;
also does CSS::Specification::Compiler::Roles;

use CSS::Specification;
use CSS::Specification::Actions;
has CSS::Specification::Actions:D $.actions handles<child-props> .= new;
has Associative @.defs;

multi method load-defs(:@lines!) is hidden-from-backtrace {
    for @lines -> $prop-spec {
        # handle full line comments
        next if $prop-spec.starts-with('#') || $prop-spec eq '';
        # '| inherit' and '| initial' are implied anyway; get rid of them
        my $spec = $prop-spec.subst(/\s* '|' \s* [inherit|initial]/, '', :g);

        my $/ = CSS::Specification.subparse($spec, :$!actions )
            // die "unable to parse: $spec";
        my $ast = $/.ast;
        @!defs.append: @$ast;
    }

    @!defs;
}

multi method load-defs(IO:D() :$file!) is hidden-from-backtrace {
    my @lines = $file.lines;
    self.load-defs: :@lines;
}

multi method load-defs() is hidden-from-backtrace {
    my @lines = $*IN.lines;
    self.load-defs: :@lines;
}

method metadata {
    @!defs.&build-metadata: :%.child-props;
}

sub build-metadata(@defs, :%child-props --> Hash) is export(:build-metadata) {
    my %props;

    for @defs .grep(*.<props>).sort(*.<props>[0]) {
        my $name = .<props>[0];
        my %details = .<synopsis>:kv;
        %details<inherit> = .<inherit>.so;
        %details<default> = $_ with .<default>;

        for .<props>.flat -> $prop-name {
            %props{$prop-name} = %details;
        }
    }
    %props.&find-edges(%child-props);
    %props.&check-edges;
    %props;
}

sub find-edges(%props, %child-props) {
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
    for %props.kv -> $key, $value {
        with %child-props{$key} {
            for .unique -> $child-prop {
                next if $value<edges> && $value<edges>.grep($child-prop);
                my $prop = %props{$child-prop};
                # property may have multiple parents
                $value<children>.push: $child-prop;
            }
        }
        # we can get defaults from the children
        $value<default>:delete
            if ($value<edges>:exists)
            || ($value<children>:exists);
    }
}

sub check-edges(%props) {
    for %props.pairs {
        my $key = .key;
        my $value = .value;
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

