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
        ast   => :keyw<thin>,
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
        input => '<a> | !<b> | <c> | !<d>',
        ast => :alt[ :rule<b>, :rule<d>, :rule<a>, :rule<c> ],
        rule-refs => ["a", "b", "c", "d"],
        DEPARSE => '<b> || <d> || <a> || <c>',
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
        input => q{<'font-variant'=.font-variant-css2>},
        ast => :alias{ :ref<prop-val-font-variant>, :rule<font-variant-css2> },
        rule-refs => ["font-variant-css2"],
        DEPARSE => '<prop-val-font-variant=.font-variant-css2>',
    },
    'values' => {
        input => q{<'grid-template'=.'grid-template-rows'>},
        ast => :alias{ :ref<prop-val-grid-template>, :rule<prop-val-grid-template-rows> },
        rule-refs => ["prop-val-grid-template-rows"],
        DEPARSE => '<prop-val-grid-template=.prop-val-grid-template-rows>',
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
        DEPARSE => '<length> +% <op(",")>?',
        rule-refs => ['length'],
    },
    'values' => {
        input => '<length>#{1,4}',
        ast => :occurs[[1, 4, ','], :rule<length>],
        DEPARSE => '<length> ** 1..4% <op(",")>?',
        rule-refs => ['length'],
    },
    'values' => {
        input => '[<generic-voice> | <specific-voice> ]#',
        ast => :occurs[",", :group(:alt[:rule("generic-voice"), :rule("specific-voice")])],
        DEPARSE => '[<generic-voice> || <specific-voice> ] +% <op(",")>?',
        rule-refs => ['generic-voice', 'specific-voice'],
    },
    'values' => {
        input => 'attr(<identifier>)',
        ast => :func<attr>,
        DEPARSE => '<attr>',
        func-refs => ['attr'],
        protos => {:attr{:func<attr>, :signature{ :args[:rule<identifier>] }, :synopsis('attr(<identifier>)')}},
        rule-refs => ['identifier'],
    },
    'values' => {
        input => '<a>#? , <b>',
        ast => :seq[:occurs["?", :occurs[",", :rule<a>], :trailing<,>], :rule<b>],
        DEPARSE => '[:!r <a> +% <op(",")> <op(",")>]? <b>',
        rule-refs => ['a', 'b'],
    },
   'values' => {
        input => '<bg-layer>#? , <final-bg-layer>',
        ast => :seq[:occurs["?", :occurs[",", :rule<bg-layer>], :trailing<,>], :rule<final-bg-layer>],
        DEPARSE => '[:!r <bg-layer> +% <op(",")> <op(",")>]? <final-bg-layer>',
        rule-refs => ['bg-layer', 'final-bg-layer'],
    },
   'values' => {
        input => '[ <angle> | <zero> | to <side-or-corner> ]? , <color-stop-list>',
        ast => :seq[:occurs["?", :group(:alt[:rule<angle>, :rule<zero>, :seq[:keyw<to>, :rule<side-or-corner>]]), :trailing<,>], :rule<color-stop-list>],
        DEPARSE => '[[<angle> || <zero> || to & <keyw> <side-or-corner>  ] <op(",")>]? <color-stop-list>',
        rule-refs => ["angle", "color-stop-list", "side-or-corner", "zero"]
    },
    'values' => {
        input => 'example( first? , second? , third? )',
        ast => :func<example>,
        protos => {:example{:func<example>, :signature{ :args[ :optional[ :keyw<first>,  :keyw<second>, :keyw<third>]]}, :synopsis("example( first? , second? , third? )")}},
        DEPARSE => '<example>',
        func-refs => ["example"],
    },
    'prop-spec' => {
        input => "'direction'	ltr | rtl | inherit	ltr	all elements, but see prose	yes",
        ast => :prop-spec{
            :props['direction'],
            :default<ltr>,
            :spec(:keywords["ltr", "rtl", "inherit"]),
            :synopsis("ltr | rtl | inherit"),
            :inherit
        },
        DEPARSE => join(
            "\n",
            q<#| direction: ltr | rtl | inherit>,
            q<rule decl:sym<direction> { :i (direction) ":" <val(/<prop-val-direction> /, &?ROUTINE.WHY)>}>,
            q<rule prop-val-direction { :i [ltr | rtl | inherit ]& <keyw>  }>
        ),
    },
    'prop-spec' => {
        input => join(
            "\t", q<'voice-family'>, q<[<generic-voice> | <specific-voice> ]#>, q<depends on user agent> ),
        ast => :prop-spec{
:default("depends on user agent"), :props($["voice-family"]), :spec(:occurs([",", :group(:alt([:rule("generic-voice"), :rule("specific-voice")]))])), :synopsis("[<generic-voice> | <specific-voice> ]#"),
           },
        rule-refs => ["generic-voice", "specific-voice"],
        DEPARSE => join(
            "\n",
            q<#| voice-family: [<generic-voice> | <specific-voice> ]#>,
            q<rule decl:sym<voice-family> { :i ("voice-family") ":" <val(/<prop-val-voice-family> /, &?ROUTINE.WHY)>}>,
            q<rule prop-val-voice-family { :i [<generic-voice> || <specific-voice> ] +% <op(",")>? }>
        ),
    },

    'func-spec' => {
        # structured
        input => '<example()> = example(a, b, c?, d?)',
        ast => :func-spec{:func<example>, :signature{:args[:keyw<a>, :keyw<b>, :optional[:keyw<c>, :keyw<d>]]}, :synopsis("example(a, b, c?, d?)")},
        protos => {:example{:func<example>, :signature{:args[:keyw<a>, :keyw<b>, :optional[:keyw<c>, :keyw<d>]]}, :synopsis("example(a, b, c?, d?)")}},
        DEPARSE => join(
            "\n",
            '#| example(a, b, c?, d?)',
            'rule example { :i "example(" [a & <keyw> "," b & <keyw> ["," c & <keyw> ]? ["," d & <keyw> ]?  || <usage(&?ROUTINE.WHY)> ] ")" }'
        ),
    },
    'func-spec' => {
        # unstructured
        input => '<rect()> = rect([<length> | auto]#{4,4})',
        ast => :func-spec{:func<rect>, :signature{:occurs[[4, 4, ","], :group(:alt[:rule<length>, :keyw<auto>])]}, :synopsis("rect([<length> | auto]#\{4,4})")},
        protos => {:rect{:func<rect>, :signature{:occurs[[4, 4, ","], :group(:alt[:rule<length>, :keyw<auto>])]}, :synopsis("rect([<length> | auto]#\{4,4})")}},
        DEPARSE => join("\n",
                        '#| rect([<length> | auto]#{4,4})',
                        'rule rect { :i "rect(" [[<length> || auto & <keyw> ] ** 4% ","? || <usage(&?ROUTINE.WHY)> ] ")" }',
                       ),
        rule-refs => ["length"],
    },
##    # precedence tests taken from: https://developer.mozilla.org/en-US/docs/CSS/Value_definition_syntax
    'values' => {
        input => 'bold thin && <length>',
        ast => :required[:seq[:keyw<bold>, :keyw<thin>], :rule("length")],
        :tidy,
        DEPARSE => '[bold & <keyw> thin & <keyw> :my $*A; <!{ $*A++ }>|| <length> :my $*B; <!{ $*B++ }>]** 2',
        rule-refs => ['length'],
    },
    'values' => {
        input => 'bold || thin && <length>',
        ast => :combo[:keyw<bold>, :required[:keyw<thin>, :rule("length")]],
        :tidy,
        DEPARSE => '[bold & <keyw> :my $*A; <!{ $*A++ }>|| [thin & <keyw> :my $*C; <!{ $*C++ }>|| <length> :my $*D; <!{ $*D++ }>]** 2 :my $*B; <!{ $*B++ }>]+',
        rule-refs => ['length'],
    },
    'rule-spec' => {
        input => '<reversed-counter-name> = reversed( <counter-name> )',
        ast => :func-spec{:func<reversed>, :rule<reversed-counter-name>, :signature{:args[:rule<counter-name>]}, :synopsis("reversed( <counter-name> )")},
        rule-refs => ['counter-name'],
        DEPARSE => join("\n",
                        q<#| reversed( <counter-name> )>,
                        q<rule reversed-counter-name { :i "reversed(" [<counter-name> || <usage(&?ROUTINE.WHY)> ] ")" }>
                       ),
    },
    'prop-spec' => {
        input => join("\t", 'border-color','<color>{1,4}', 'transparent'),
        ast => :prop-spec{
            :props['border-color'],
            :default<transparent>,
            :synopsis('<color>{1,4}'),
            :spec(:occurs[[1, 4], :rule<color>]),
        },
        rule-refs => ['color'],
        DEPARSE => join("\n",
                        '#| border-color: <color>{1,4}',
                        'rule decl:sym<border-color> { :i ("border-color") ":" <val(/<prop-val-border-color>** 1..4 /, &?ROUTINE.WHY)>}',
                        'rule prop-val-border-color { :i <color> }'),
    },
   'prop-spec' => {
        input => "font\t<'font-size'> [ / <'line-height'> ]? <'font-family'>#\t",
    },
   'prop-spec' => {
        input => "'min-width'\t<length> | <percentage> | inherit\t0",
        ast => :prop-spec{
            :props['min-width'],
            :default<0>,
            :synopsis("<length> | <percentage> | inherit"),
            :spec(:alt[:rule("length"), :rule("percentage"), :keyw<inherit>]),
        },
        rule-refs => ['length', 'percentage'],
        DEPARSE => join("\n",
                        '#| min-width: <length> | <percentage> | inherit',
                        'rule decl:sym<min-width> { :i ("min-width") ":" <val(/<prop-val-min-width> /, &?ROUTINE.WHY)>}',
                        'rule prop-val-min-width { :i <length> || <percentage> || inherit & <keyw>  }',
                       ),
    },
    'prop-spec' => {input => "'content'\tnormal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit\tnormal	:before and :after pseudo-elements	no",
                        :ast(:prop-spec{:props['content'],
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
                                          {:keyw<inherit>},
                                      ]
                             },
                             :synopsis('normal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit'),
                             :!inherit,
                            }),
                        rule-refs => [<counter identifier string uri>],
                        func-refs => ['attr'],
                        protos => {:attr{:func<attr>, :signature{ :args[:rule<identifier>] }, :synopsis('attr(<identifier>)')}},
                        DEPARSE => join("\n",
                                        '#| content: normal | none | [ <string> | <uri> | <counter> | attr(<identifier>) | open-quote | close-quote | no-open-quote | no-close-quote ]+ | inherit',
                                        'rule decl:sym<content> { :i (content) ":" <val(/<prop-val-content> /, &?ROUTINE.WHY)>}',
                                        'rule prop-val-content { :i [normal | none ]& <keyw>  || [<string> || <uri> || <counter> || <attr> || ["open-quote" | "close-quote" | "no-open-quote" | "no-close-quote" ]& <keyw>  ] + || inherit & <keyw>  }',
                                       ),

    },
    # css1 spec with property name and '*' junk
    prop-spec => {input => "'width' *\t<length> | <percentage> | auto	auto	all elements but non-replaced inline elements, table rows, and row groups	no",
                      ast => :prop-spec{:props["width"], :spec(:alt[:rule("length"), :rule("percentage"), :keyw<auto>]), :synopsis("<length> | <percentage> | auto"), :default("auto"), :inherit(False), },
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
        my @*DECL-NAMES = [];

        my CSS::Specification::Actions $actions .= new;
        my $*VAR = 'A';
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
