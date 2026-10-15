unit grammar Test::CSS::Aural::Border::Gen::Grammar;
#| border-color: [ <color> | transparent ]{1,4}
rule decl:sym<border-color> { :i ("border-color") ":" <val(/<prop-val-border-color>** 1..4 /, &?ROUTINE.WHY)>}
rule prop-val-border-color { :i [<color> || [transparent & <keyw> ] ] }
#| border-top-color: <color> | transparent
rule decl:sym<border-top-color> { :i ("border-top-color") ":" <val(/<prop-val-border-top-color> /, &?ROUTINE.WHY)>}
rule prop-val-border-top-color { :i <color> || [transparent & <keyw> ] }
#| border-top-color: <color> | transparent
rule decl:sym<border-right-color> { :i ("border-right-color") ":" <val(/<prop-val-border-right-color> /, &?ROUTINE.WHY)>}
rule prop-val-border-right-color { :i <color> || [transparent & <keyw> ] }
#| border-top-color: <color> | transparent
rule decl:sym<border-bottom-color> { :i ("border-bottom-color") ":" <val(/<prop-val-border-bottom-color> /, &?ROUTINE.WHY)>}
rule prop-val-border-bottom-color { :i <color> || [transparent & <keyw> ] }
#| border-top-color: <color> | transparent
rule decl:sym<border-left-color> { :i ("border-left-color") ":" <val(/<prop-val-border-left-color> /, &?ROUTINE.WHY)>}
rule prop-val-border-left-color { :i <color> || [transparent & <keyw> ] }
