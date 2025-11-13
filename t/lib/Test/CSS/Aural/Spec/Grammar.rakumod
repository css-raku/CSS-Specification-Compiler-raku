grammar Test::CSS::Aural::Spec::Grammar {
    #| azimuth: <angle> | [[ left-side | far-left | left | center-left | center | center-right | right | far-right | right-side ] || behind ] | leftwards | rightwards
    rule decl:sym<azimuth> {     :i (azimuth) ":" <val(/<expr=.prop-val-azimuth> /, &?ROUTINE.WHY)>}
    rule prop-val-azimuth { :i <angle> || [[[["left-side" | "far-left" | left | "center-left" | center | "center-right" | right | "far-right" | "right-side" ]& <keyw> ] :my $*A; <!{
        $*A++
    }>| behind & <keyw>  :my $*B; <!{
        $*B++
    }>]+] || [leftwards | rightwards ]& <keyw>   }
    #| cue-after: <uri> | none
    rule decl:sym<cue-after> {     :i ("cue-after") ":" <val(/<expr=.prop-val-cue-after> /, &?ROUTINE.WHY)>}
    rule prop-val-cue-after { :i <uri> || none & <keyw>   }
    #| cue-before: <uri> | none
    rule decl:sym<cue-before> {     :i ("cue-before") ":" <val(/<expr=.prop-val-cue-before> /, &?ROUTINE.WHY)>}
    rule prop-val-cue-before { :i <uri> || none & <keyw>   }
    #| cue: [ 'cue-before' || 'cue-after' ]
    rule decl:sym<cue> {     :i (cue) ":" <val(/<expr=.prop-val-cue> /, &?ROUTINE.WHY)>}
    rule prop-val-cue { :i [[<prop-val-cue-before> :my $*A; <!{
        $*A++
    }>| <prop-val-cue-after> :my $*B; <!{
        $*B++
    }>]+] }
    #| elevation: <angle> | below | level | above | higher | lower
    rule decl:sym<elevation> {     :i (elevation) ":" <val(/<expr=.prop-val-elevation> /, &?ROUTINE.WHY)>}
    rule prop-val-elevation { :i <angle> || [below | level | above | higher | lower ]& <keyw>   }
    #| pause: [ [<time> | <percentage>]{1,2} ]
    rule decl:sym<pause> {     :i (pause) ":" <val(/<expr=.prop-val-pause> /, &?ROUTINE.WHY)>}
    rule prop-val-pause { :i [[<time> || <percentage> ] ** 1..2] }
    #| pause-after: <time> | <percentage>
    rule decl:sym<pause-after> {     :i ("pause-after") ":" <val(/<expr=.prop-val-pause-after> /, &?ROUTINE.WHY)>}
    rule prop-val-pause-after { :i <time> || <percentage>  }
    #| pause-before: <time> | <percentage>
    rule decl:sym<pause-before> {     :i ("pause-before") ":" <val(/<expr=.prop-val-pause-before> /, &?ROUTINE.WHY)>}
    rule prop-val-pause-before { :i <time> || <percentage>  }
    #| pitch-range: <number>
    rule decl:sym<pitch-range> {     :i ("pitch-range") ":" <val(/<expr=.prop-val-pitch-range> /, &?ROUTINE.WHY)>}
    rule prop-val-pitch-range { :i <number> }
    #| pitch: <frequency> | x-low | low | medium | high | x-high
    rule decl:sym<pitch> {     :i (pitch) ":" <val(/<expr=.prop-val-pitch> /, &?ROUTINE.WHY)>}
    rule prop-val-pitch { :i <frequency> || ["x-low" | low | medium | high | "x-high" ]& <keyw>   }
    #| play-during: <uri> [ mix || repeat ]? | auto | none
    rule decl:sym<play-during> {     :i ("play-during") ":" <val(/<expr=.prop-val-play-during> /, &?ROUTINE.WHY)>}
    rule prop-val-play-during { :i <uri> [[mix & <keyw>  :my $*A; <!{
        $*A++
    }>| repeat & <keyw>  :my $*B; <!{
        $*B++
    }>]+] ?  || [auto | none ]& <keyw>   }
    #| richness: <number>
    rule decl:sym<richness> {     :i (richness) ":" <val(/<expr=.prop-val-richness> /, &?ROUTINE.WHY)>}
    rule prop-val-richness { :i <number> }
    #| speak: normal | none | spell-out
    rule decl:sym<speak> {     :i (speak) ":" <val(/<expr=.prop-val-speak> /, &?ROUTINE.WHY)>}
    rule prop-val-speak { :i [normal | none | "spell-out" ]& <keyw>  }
    #| speak-header: once | always
    rule decl:sym<speak-header> {     :i ("speak-header") ":" <val(/<expr=.prop-val-speak-header> /, &?ROUTINE.WHY)>}
    rule prop-val-speak-header { :i [once | always ]& <keyw>  }
    #| speak-numeral: digits | continuous
    rule decl:sym<speak-numeral> {     :i ("speak-numeral") ":" <val(/<expr=.prop-val-speak-numeral> /, &?ROUTINE.WHY)>}
    rule prop-val-speak-numeral { :i [digits | continuous ]& <keyw>  }
    #| speak-punctuation: code | none
    rule decl:sym<speak-punctuation> {     :i ("speak-punctuation") ":" <val(/<expr=.prop-val-speak-punctuation> /, &?ROUTINE.WHY)>}
    rule prop-val-speak-punctuation { :i [code | none ]& <keyw>  }
    #| speech-rate: <number> | x-slow | slow | medium | fast | x-fast | faster | slower
    rule decl:sym<speech-rate> {     :i ("speech-rate") ":" <val(/<expr=.prop-val-speech-rate> /, &?ROUTINE.WHY)>}
    rule prop-val-speech-rate { :i <number> || ["x-slow" | slow | medium | fast | "x-fast" | faster | slower ]& <keyw>   }
    #| stress: <number>
    rule decl:sym<stress> {     :i (stress) ":" <val(/<expr=.prop-val-stress> /, &?ROUTINE.WHY)>}
    rule prop-val-stress { :i <number> }
    #| voice-family: [<generic-voice> | <specific-voice> ]#
    rule decl:sym<voice-family> {     :i ("voice-family") ":" <val(/<expr=.prop-val-voice-family> /, &?ROUTINE.WHY)>}
    rule prop-val-voice-family { :i [<generic-voice> || <specific-voice> ] +% <op(",")> }
    #| <generic-voice> = male | female | child
    rule generic-voice {     :i [male | female | child ]& <keyw>  }
    #| <specific-voice> = <identifier> | <string>
    rule specific-voice {     :i <identifier> || <string>  }
    #| volume: <number> | <percentage> | silent | x-soft | soft | medium | loud | x-loud
    rule decl:sym<volume> {     :i (volume) ":" <val(/<expr=.prop-val-volume> /, &?ROUTINE.WHY)>}
    rule prop-val-volume { :i <number> || <percentage> || [silent | "x-soft" | soft | medium | loud | "x-loud" ]& <keyw>   }
    #| border-color: [ <color> | transparent ]{1,4}
    rule decl:sym<border-color> {     :i ("border-color") ":" <val(/<expr=.prop-val-border-color>** 1..4 /, &?ROUTINE.WHY)>}
    rule prop-val-border-color { :i [<color> || transparent & <keyw>  ] }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-top-color> {     :i ("border-top-color") ":" <val(/<expr=.prop-val-border-top-color> /, &?ROUTINE.WHY)>}
    rule prop-val-border-top-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-right-color> {     :i ("border-right-color") ":" <val(/<expr=.prop-val-border-right-color> /, &?ROUTINE.WHY)>}
    rule prop-val-border-right-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-bottom-color> {     :i ("border-bottom-color") ":" <val(/<expr=.prop-val-border-bottom-color> /, &?ROUTINE.WHY)>}
    rule prop-val-border-bottom-color { :i <color> || transparent & <keyw>   }
    #| border-top-color: <color> | transparent
    rule decl:sym<border-left-color> {     :i ("border-left-color") ":" <val(/<expr=.prop-val-border-left-color> /, &?ROUTINE.WHY)>}
    rule prop-val-border-left-color { :i <color> || transparent & <keyw>   }
}