grammar Test::CSS::Aural::Spec::Grammar {
    #| azimuth: <angle> | [[ left-side | far-left | left | center-left | center | center-right | right | far-right | right-side ] || behind ] | leftwards | rightwards
    rule decl:sym<azimuth> {     :i (azimuth) ":" <val(/<expr=.val-azimuth> /, &?ROUTINE.WHY)>}
    rule val-azimuth { :i <angle> || [[[["left-side" | "far-left" | left | "center-left" | center | "center-right" | right | "far-right" | "right-side" ]& <keyw> ] :my $a; <!{
        $a++
    }>| behind & <keyw>  :my $b; <!{
        $b++
    }>]+] || [leftwards | rightwards ]& <keyw>   }
    #| cue-after: <uri> | none
    rule decl:sym<cue-after> {     :i ("cue-after") ":" <val(/<expr=.val-cue-after> /, &?ROUTINE.WHY)>}
    rule val-cue-after { :i <uri> || none & <keyw>   }
    #| cue-before: <uri> | none
    rule decl:sym<cue-before> {     :i ("cue-before") ":" <val(/<expr=.val-cue-before> /, &?ROUTINE.WHY)>}
    rule val-cue-before { :i <uri> || none & <keyw>   }
    #| cue: [ 'cue-before' || 'cue-after' ]
    rule decl:sym<cue> {     :i (cue) ":" <val(/<expr=.val-cue> /, &?ROUTINE.WHY)>}
    rule val-cue { :i [[<val-cue-before> :my $a; <!{
        $a++
    }>| <val-cue-after> :my $b; <!{
        $b++
    }>]+] }
    #| elevation: <angle> | below | level | above | higher | lower
    rule decl:sym<elevation> {     :i (elevation) ":" <val(/<expr=.val-elevation> /, &?ROUTINE.WHY)>}
    rule val-elevation { :i <angle> || [below | level | above | higher | lower ]& <keyw>   }
    #| pause: [ [<time> | <percentage>]{1,2} ]
    rule decl:sym<pause> {     :i (pause) ":" <val(/<expr=.val-pause> /, &?ROUTINE.WHY)>}
    rule val-pause { :i [[<time> || <percentage> ] ** 1..2] }
    #| pause-after: <time> | <percentage>
    rule decl:sym<pause-after> {     :i ("pause-after") ":" <val(/<expr=.val-pause-after> /, &?ROUTINE.WHY)>}
    rule val-pause-after { :i <time> || <percentage>  }
    #| pause-before: <time> | <percentage>
    rule decl:sym<pause-before> {     :i ("pause-before") ":" <val(/<expr=.val-pause-before> /, &?ROUTINE.WHY)>}
    rule val-pause-before { :i <time> || <percentage>  }
    #| pitch-range: <number>
    rule decl:sym<pitch-range> {     :i ("pitch-range") ":" <val(/<expr=.val-pitch-range> /, &?ROUTINE.WHY)>}
    rule val-pitch-range { :i <number> }
    #| pitch: <frequency> | x-low | low | medium | high | x-high
    rule decl:sym<pitch> {     :i (pitch) ":" <val(/<expr=.val-pitch> /, &?ROUTINE.WHY)>}
    rule val-pitch { :i <frequency> || ["x-low" | low | medium | high | "x-high" ]& <keyw>   }
    #| play-during: <uri> [ mix || repeat ]? | auto | none
    rule decl:sym<play-during> {     :i ("play-during") ":" <val(/<expr=.val-play-during> /, &?ROUTINE.WHY)>}
    rule val-play-during { :i <uri> [[mix & <keyw>  :my $a; <!{
        $a++
    }>| repeat & <keyw>  :my $b; <!{
        $b++
    }>]+] ?  || [auto | none ]& <keyw>   }
    #| richness: <number>
    rule decl:sym<richness> {     :i (richness) ":" <val(/<expr=.val-richness> /, &?ROUTINE.WHY)>}
    rule val-richness { :i <number> }
    #| speak: normal | none | spell-out
    rule decl:sym<speak> {     :i (speak) ":" <val(/<expr=.val-speak> /, &?ROUTINE.WHY)>}
    rule val-speak { :i [normal | none | "spell-out" ]& <keyw>  }
    #| speak-header: once | always
    rule decl:sym<speak-header> {     :i ("speak-header") ":" <val(/<expr=.val-speak-header> /, &?ROUTINE.WHY)>}
    rule val-speak-header { :i [once | always ]& <keyw>  }
    #| speak-numeral: digits | continuous
    rule decl:sym<speak-numeral> {     :i ("speak-numeral") ":" <val(/<expr=.val-speak-numeral> /, &?ROUTINE.WHY)>}
    rule val-speak-numeral { :i [digits | continuous ]& <keyw>  }
    #| speak-punctuation: code | none
    rule decl:sym<speak-punctuation> {     :i ("speak-punctuation") ":" <val(/<expr=.val-speak-punctuation> /, &?ROUTINE.WHY)>}
    rule val-speak-punctuation { :i [code | none ]& <keyw>  }
    #| speech-rate: <number> | x-slow | slow | medium | fast | x-fast | faster | slower
    rule decl:sym<speech-rate> {     :i ("speech-rate") ":" <val(/<expr=.val-speech-rate> /, &?ROUTINE.WHY)>}
    rule val-speech-rate { :i <number> || ["x-slow" | slow | medium | fast | "x-fast" | faster | slower ]& <keyw>   }
    #| stress: <number>
    rule decl:sym<stress> {     :i (stress) ":" <val(/<expr=.val-stress> /, &?ROUTINE.WHY)>}
    rule val-stress { :i <number> }
    #| voice-family: [<generic-voice> | <specific-voice> ]#
    rule decl:sym<voice-family> {     :i ("voice-family") ":" <val(/<expr=.val-voice-family> /, &?ROUTINE.WHY)>}
    rule val-voice-family { :i [<generic-voice> || <specific-voice> ] +% <op(",")> }
    #| male | female | child
    rule generic-voice {     :i [male | female | child ]& <keyw>  }
    #| <identifier> | <string>
    rule specific-voice {     :i <identifier> || <string>  }
    #| volume: <number> | <percentage> | silent | x-soft | soft | medium | loud | x-loud
    rule decl:sym<volume> {     :i (volume) ":" <val(/<expr=.val-volume> /, &?ROUTINE.WHY)>}
    rule val-volume { :i <number> || <percentage> || [silent | "x-soft" | soft | medium | loud | "x-loud" ]& <keyw>   }
    #| border-color: [ <color> | transparent ]{1,4}
    rule decl:sym<border-color> {     :i ("border-color") ":" <val(/<expr=.val-border-color>** 1..4 /, &?ROUTINE.WHY)>}
    rule val-border-color { :i [<color> || transparent & <keyw>  ] }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-top-color> {     :i ("border-top-color") ":" <val(/<expr=.val-border-top-color> /, &?ROUTINE.WHY)>}
    rule val-border-top-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-right-color> {     :i ("border-right-color") ":" <val(/<expr=.val-border-right-color> /, &?ROUTINE.WHY)>}
    rule val-border-right-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-bottom-color> {     :i ("border-bottom-color") ":" <val(/<expr=.val-border-bottom-color> /, &?ROUTINE.WHY)>}
    rule val-border-bottom-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-left-color> {     :i ("border-left-color") ":" <val(/<expr=.val-border-left-color> /, &?ROUTINE.WHY)>}
    rule val-border-left-color { :i <color> || transparent & <keyw>   }
}