{
  "azimuth": {
    "default": "center",
    "inherit": true,
    "synopsis": "<angle> | [[ left-side | far-left | left | center-left | center | center-right | right | far-right | right-side ] || behind ] | leftwards | rightwards"
  },
  "border-bottom-color": {
    "default": "the value of the 'color' property",
    "edge": "border-color",
    "inherit": false,
    "synopsis": "<color> | transparent"
  },
  "border-color": {
    "box": true,
    "edges": [
      "border-top-color",
      "border-right-color",
      "border-bottom-color",
      "border-left-color"
    ],
    "inherit": false,
    "synopsis": "[ <color> | transparent ]{1,4}"
  },
  "border-left-color": {
    "default": "the value of the 'color' property",
    "edge": "border-color",
    "inherit": false,
    "synopsis": "<color> | transparent"
  },
  "border-right-color": {
    "default": "the value of the 'color' property",
    "edge": "border-color",
    "inherit": false,
    "synopsis": "<color> | transparent"
  },
  "border-top-color": {
    "default": "the value of the 'color' property",
    "edge": "border-color",
    "inherit": false,
    "synopsis": "<color> | transparent"
  },
  "cue": {
    "children": [
      "cue-before",
      "cue-after"
    ],
    "inherit": false,
    "synopsis": "[ 'cue-before' || 'cue-after' ]"
  },
  "cue-after": {
    "default": "none",
    "inherit": false,
    "synopsis": "<uri> | none"
  },
  "cue-before": {
    "default": "none",
    "inherit": false,
    "synopsis": "<uri> | none"
  },
  "elevation": {
    "default": "level",
    "inherit": true,
    "synopsis": "<angle> | below | level | above | higher | lower"
  },
  "pause": {
    "inherit": false,
    "synopsis": "[ [<time> | <percentage>]{1,2} ]"
  },
  "pause-after": {
    "default": "0",
    "inherit": false,
    "synopsis": "<time> | <percentage>"
  },
  "pause-before": {
    "default": "0",
    "inherit": false,
    "synopsis": "<time> | <percentage>"
  },
  "pitch": {
    "default": "medium",
    "inherit": true,
    "synopsis": "<frequency> | x-low | low | medium | high | x-high"
  },
  "pitch-range": {
    "default": "50",
    "inherit": true,
    "synopsis": "<number>"
  },
  "play-during": {
    "default": "auto",
    "inherit": false,
    "synopsis": "<uri> [ mix || repeat ]? | auto | none"
  },
  "richness": {
    "default": "50",
    "inherit": true,
    "synopsis": "<number>"
  },
  "speak": {
    "default": "normal",
    "inherit": true,
    "synopsis": "normal | none | spell-out"
  },
  "speak-header": {
    "default": "once",
    "inherit": true,
    "synopsis": "once | always"
  },
  "speak-numeral": {
    "default": "continuous",
    "inherit": true,
    "synopsis": "digits | continuous"
  },
  "speak-punctuation": {
    "default": "none",
    "inherit": true,
    "synopsis": "code | none"
  },
  "speech-rate": {
    "default": "medium",
    "inherit": true,
    "synopsis": "<number> | x-slow | slow | medium | fast | x-fast | faster | slower"
  },
  "stress": {
    "default": "50",
    "inherit": true,
    "synopsis": "<number>"
  },
  "voice-family": {
    "default": "depends on user agent",
    "inherit": true,
    "synopsis": "[<generic-voice> | <specific-voice> ]#"
  },
  "volume": {
    "default": "medium",
    "inherit": true,
    "synopsis": "<number> | <percentage> | silent | x-soft | soft | medium | loud | x-loud"
  }
}