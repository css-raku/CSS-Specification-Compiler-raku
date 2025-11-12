#!/usr/bin/env perl6

use Test;
use CSS::Grammar::Test;

use CSS::Specification;
use CSS::Specification::Actions;
use CSS::Specification::Compiler;
use CSS::Specification::Compiler::Actions;
use CSS::Specification::Compiler::Grammars :&compile;
use experimental :rakuast;

sub tidy($_) {
    .subst: /\s+/, ' ', :g
}

lives-ok {require CSS::Grammar:ver(v0.3.0..*) }, "CSS::Grammar version";

for (
    'values' => {
        input => 'thin',
        ast   => :keywords['thin'],
        DEPARSE => 'thin & <keyw>',
    },
    'values' => {
        input => 'thin?',
        ast   => :occurs['?', :keyw<thin>],
        DEPARSE => '[thin & <keyw>] ?',
    },
    'values' => {
        input => 'thick | thin',
        ast => :keywords[ 'thick', 'thin' ],
        DEPARSE => '[thick | thin ]& <keyw>',
    },
    'values' => {
        input => '35 | 7',
        ast => :numbers[ 35, 7 ],
        DEPARSE => '[35 | 7 ]& <number>',
    },
    'values' => {
        input => '35 | 7 | 42?',
        ast => :alt[:numbers[35, 7], :occurs["?", :num(42)]],
        DEPARSE => '[35 | 7 ]& <number> || [42 & <number>] ?',
    },
    'values' => {
        input => "<rule-ref>",
        ast => :rule<rule-ref>,
        DEPARSE => "<rule-ref>",
        rule-refs => ['rule-ref'],
    },
    'values' => {
        input => "'css21-prop'",
        ast => :rule<prop-val-css21-prop>,
        DEPARSE => "<prop-val-css21-prop>",
        rule-refs => ['prop-val-css21-prop'],
    },
    'values' => {
        input => "<rule> [ 'css21-prop' <'css3-prop'> ] ?",
        ast => :seq[:rule<rule>, :occurs["?", :group( :seq[:rule<prop-val-css21-prop>, :rule<prop-val-css3-prop> ]) ] ],
        DEPARSE => "<rule> [<prop-val-css21-prop> <prop-val-css3-prop> ] ?",
        rule-refs => ["prop-val-css21-prop", "prop-val-css3-prop", "rule"],
    },
    'values' => {
        input => "<rule> [, [ 'css21-prop' | <'css3-prop'> ] ]*",
        ast => :seq[ :rule<rule>, :occurs["*", :group( :seq[:op<,>, :group(:alt[:rule<prop-val-css21-prop>, :rule<prop-val-css3-prop>])])]],
        DEPARSE => '<rule> [<op(",")> [<prop-val-css21-prop> || <prop-val-css3-prop> ] ] *',
        rule-refs => ["prop-val-css21-prop", "prop-val-css3-prop", "rule"],
    },
    'values' => {
        input => '<length>{4}',
        ast => :occurs[[4,4], :rule<length>],
        DEPARSE => '<length> ** 4',
        rule-refs => ['length'],
    },
    'values' => {
        input => '<length>#',
        ast => :occurs[',', :rule<length>],
        DEPARSE => '<length> +% <op(",")>',
        rule-refs => ['length'],
    },
    'values' => {
        input => '<length>#{1,4}',
        ast => :occurs[[1, 4, ','], :rule<length>],
        DEPARSE => '<length> ** 1..4% <op(",")>',
        rule-refs => ['length'],
    },
    'values' => {
        input => '[<generic-voice> | <specific-voice> ]#',
        ast => :occurs[",", :group(:alt[:rule("generic-voice"), :rule("specific-voice")])],
        DEPARSE => '[<generic-voice> || <specific-voice> ] +% <op(",")>',
        rule-refs => ['generic-voice', 'specific-voice'],
    },
    'values' => {
        input => 'attr(<identifier>)',
        ast => :func<attr>,
        DEPARSE => '<attr>',
        func-refs => ['attr'],
        protos => {:attr{:func<attr>, :signature(:rule<identifier>), :synopsis('attr(<identifier>)')}},
        rule-refs => ['identifier'],
    },
    'property-spec' => {
        input => "'direction'	ltr | rtl | inherit	ltr	all elements, but see prose	yes",
        ast => {
            :props['direction'],
            :default<ltr>,
            :spec(:keywords["ltr", "rtl", "inherit"]),
            :synopsis("ltr | rtl | inherit"),
            :inherit
        },
    },
##    # precedence tests taken from: https://developer.mozilla.org/en-US/docs/CSS/Value_definition_syntax
    'values' => {
        input => 'bold thin && <length>',
        ast => :required[:seq[:keywords["bold"], :keywords["thin"]], :rule("length")],
        :tidy,
        DEPARSE => '[bold & <keyw> thin & <keyw> :my $*A ; <!{ $*A++ }>| <length> :my $*B ; <!{ $*B++ }>]** 2',
        rule-refs => ['length'],
    },
    'values' => {
        input => 'bold || thin && <length>',
        ast => :combo[:keywords["bold"], :required[:keywords["thin"], :rule("length")]],
        :tidy,
        DEPARSE => '[bold & <keyw> :my $*A ; <!{ $*A++ }>| [thin & <keyw> :my $*A ; <!{ $*A++ }>| <length> :my $*B ; <!{ $*B++ }>]** 2 :my $*B ; <!{ $*B++ }>]+',
        rule-refs => ['length'],
    },
    'property-spec' => {
        input => join("\t", 'border-color','<color>{1,4}', 'transparent'),
        ast => {
            :props['border-color'],
            :default<transparent>,
            :synopsis('<color>{1,4}'),
            :spec(:occurs[[1, 4], :rule<color>]),
        },
        rule-refs => ['color'],
        DEPARSE => join("\n",
                        '#| border-color: <color>{1,4}',
                        'rule decl:sym<border-color> { :i ("border-color") ":" <val(/<expr=.prop-val-border-color>** 1..4 /, &?ROUTINE.WHY)>}',
                        'rule prop-val-border-color { :i <color> }'),
    },
   'property-spec' => {
        input => "'min-width'\t<length> | <percentage> | inherit\t0",
        ast => {
            :props['min-width'],
            :default<0>,
            :synopsis("<length> | <percentage> | inherit"),
            :spec(:alt[:rule("length"), :rule("percentage"), :keywords["inherit"]]),
        },
        rule-refs => ['length', 'percentage'],
        DEPARSE => join("\n",
                        '#| min-width: <length> | <percentage> | inherit',
                        'rule decl:sym<min-width> { :i ("min-width") ":" <val(/<expr=.prop-val-min-width> /, &?ROUTINE.WHY)>}',
                        'rule prop-val-min-width { :i <length> || <percentage> || inherit & <keyw>   }',
                       ),
    },
    'property-spec' => {input => "'content'\tnormal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit\tnormal	:before and :after pseudo-elements	no",
                        :ast{:props['content'],
                             :default<normal>,
                             :spec{
                                 :alt[
                                          {:keywords<normal none>},
                                          {:occurs["+",
                                                   {:group{
                                                        :alt[{:rule<string>}, {:rule<uri>}, {:rule<counter>}, {:func<attr>}, {:keywords<open-quote close-quote no-open-quote no-close-quote>}]}
                                                   },
                                                  ]
                                          },
                                          {:keywords["inherit"]},
                                      ]
                             },
                             :synopsis('normal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit'),
                             :!inherit,
                            },
                        rule-refs => [<counter identifier string uri>],
                        func-refs => ['attr'],
                        protos => {:attr{:func<attr>, :signature(:rule<identifier>), :synopsis('attr(<identifier>)')}},
                        DEPARSE => join("\n",
                                        '#| content: normal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit',
                                        'rule decl:sym<content> { :i (content) ":" <val(/<expr=.prop-val-content> /, &?ROUTINE.WHY)>}',
                                        'rule prop-val-content { :i [normal | none ]& <keyw>  || [<string> || <uri> || <counter> || <attr> || ["open-quote" | "close-quote" | "no-open-quote" | "no-close-quote" ]& <keyw>  ] + || inherit & <keyw>   }',
                                       ),

    },
    # css1 spec with property name and '*' junk
    property-spec => {input => "'width' *\t<length> | <percentage> | auto	auto	all elements but non-replaced inline elements, table rows, and row groups	no",
                      ast => {:props["width"], :spec(:alt[:rule("length"), :rule("percentage"), :keywords["auto"]]), :synopsis("<length> | <percentage> | auto"), :default("auto"), :inherit(False), },
                      rule-refs => ["length", "percentage"],
    },
    ) {

    my $rule := .key;
    my $expected := .value;
    my $input := $expected<input>;
    my $deparse := $expected<DEPARSE>;
    my $rule-refs := $expected<rule-refs>;
    my $func-refs := $expected<func-refs>;
    my $protos    := $expected<protos>;

    subtest $input, {
        my @*PROP-NAMES = [];

        my CSS::Specification::Actions $actions .= new;
        my $*VAR = 'a';
        my $*ACTIONS = $actions;

        my $parse = CSS::Grammar::Test::parse-tests(
            CSS::Specification, $input,
            :$rule,
            :$actions,
            :suite<spec>,
            :$expected
        );

        with $deparse {
            my $AST = RakuAST::StatementList.new: |compile(|$parse.ast);

            my $s = $AST.DEPARSE;
            $s .= &tidy if $expected<tidy>;
            is $s.trim, $_, 'deparse';
        }

        my @refs = $actions.rule-refs.keys.sort.Array;
        if @refs || $rule-refs {
            is-deeply @refs, $rule-refs, "rule-refs";
        }
        @refs = $actions.func-refs.keys.sort.Array;
        if @refs || $func-refs {
            is-deeply @refs, $func-refs, "func-refs";
        }
        my %protos-got = $actions.protos;
        if $protos || %protos-got {
            is-deeply %protos-got, $protos, "protos";
        }
    }
}

done-testing;
