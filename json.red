Red [
	Title: "ReAdABLE Human Format - JSON Decoder/Encoder"
	Author: "Christopher Ross-Gill"
	Adaptation: "Lépine KONG"
	Build: 0.0.0.2
	Builds: [
		0.0.0.2 {from-json alias}
		0.0.0.1 {Initial version}
	]
	Date: 12-Sep-2017
	Home: http://www.ross-gill.com/page/JSON_and_Rebol
	File: %.system.libraries.reAdABLE-json.red.red
	Version: 0.3.6.3
	Purpose: "Convert a Red block to a JSON string"
	Rights: http://opensource.org/licenses/Apache-2.0
	Type: 'module
	Name: 'rgchris.altjson
	Exports: [load-json to-json]
	History: [
		12-Sep-2017 0.3.6.1 "Red Compatibilities"
		18-Sep-2015 0.3.6 "Non-Word keys loaded as strings"
		17-Sep-2015 0.3.5 "Added GET-PATH! lookup"
		16-Sep-2015 0.3.4 "Reinstate /FLAT refinement"
		21-Apr-2015 0.3.3 {
			- Merge from Reb4.me version
			- Recognize set-word pairs as objects
			- Use map! as the default object type
			- Serialize dates in RFC 3339 form
		}
		14-Mar-2015 0.3.2 "Converts Json input to string before parsing"
		07-Jul-2014 0.3.0 "Initial support for JSONP"
		15-Jul-2011 0.2.6 "Flattens Flickr '_content' objects"
		02-Dec-2010 0.2.5 "Support for time! added"
		28-Aug-2010 0.2.4 "Encodes tag! any-type! paired blocks as an object"
		06-Aug-2010 0.2.2 "Issue! composed of digits encoded as integers"
		22-May-2005 0.1.0 "Original Version"
	]
	Notes: {
		- Converts date! to RFC 3339 Date String
	}
]

if not value? 'use [
	use: func [locals [block!] body [block!]][
		do bind body make object! collect [
			forall locals [keep to set-word! locals/1]
			keep none
		]
	]
]

load-json: use [
	tree branch here val is-flat emit new-child to-parent neaten-one neaten-two word to-word
	space comma number string block object _content value ident
][
	branch: make block! 10

	emit: func [val][here: insert/only here val]
	new-child: quote (insert/only branch insert/only here here: make block! 10)
	to-parent: quote (here: take branch)
	neaten-one: quote (new-line/all head here true)
	neaten-two: quote (new-line/all/skip head here true 2)

	to-word: use [word1 word+][
		; upper ranges borrowed from AltXML
		word1: charset [
			"!&*=?ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz|~"
			#"^(C0)" - #"^(D6)" #"^(D8)" - #"^(F6)" #"^(F8)" - #"^(02FF)"
			#"^(0370)" - #"^(037D)" #"^(037F)" - #"^(1FFF)" #"^(200C)" - #"^(200D)"
			#"^(2070)" - #"^(218F)" #"^(2C00)" - #"^(2FEF)" #"^(3001)" - #"^(D7FF)"
			#"^(f900)" - #"^(FDCF)" #"^(FDF0)" - #"^(FFFD)"
		]

		word+: charset [
			"!&'*+-.0123456789=?ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz|~"
			#"^(B7)" #"^(C0)" - #"^(D6)" #"^(D8)" - #"^(F6)" #"^(F8)" - #"^(037D)"
			#"^(037F)" - #"^(1FFF)" #"^(200C)" - #"^(200D)" #"^(203F)" - #"^(2040)"
			#"^(2070)" - #"^(218F)" #"^(2C00)" - #"^(2FEF)" #"^(3001)" - #"^(D7FF)"
			#"^(f900)" - #"^(FDCF)" #"^(FDF0)" - #"^(FFFD)"
		]

		func [text [string!]][
			all [
				parse text [word1 any word+]
				to word! text
			]
		]
	]

	space: use [space][
		space: charset " ^-^/^M"
		[any space]
	]

	comma: [space #"," space]

	number: use [dg ex nm as-num][
		dg: charset "0123456789"
		ex: [[#"e" | #"E"] opt [#"+" | #"-"] some dg]
		nm: [opt #"-" some dg opt [#"." some dg] opt ex]

		as-num: func [val [string!]][
			case [
				not parse val [opt "-" some dg][to float! val]
				not integer? try [val: to integer! val][to issue! val]
				val [val]
			]
		]

		[copy val nm (val: as-num val)]
	]

	string: use [ch es hx mp decode-surrogate decode][
		ch: complement charset {\"}
		hx: charset "0123456789ABCDEFabcdef"
		mp: #(#"^"" "^"" #"\" "\" #"/" "/" #"b" "^H" #"f" "^L" #"r" "^M" #"n" "^/" #"t" "^-")
		es: charset words-of mp

		decode-surrogate: func [char [string!]][
			char: debase/base char 16
			to char! 65536
				+ (shift/left 1023 and to integer! take/part char 2 10)
				+ (1023 and to integer! char)
		]

		decode: use [char escape][
			escape: [
				change [
					#"\" [
						char: es (char: select mp char/1)
						|
						#"u" copy char [
							#"d" [#"8" | #"9" | #"a" | #"b"] 2 hx
							"\u"
							#"d" [#"c" | #"d" | #"e" | #"f"] 2 hx
						] (
							char: decode-surrogate head remove remove skip char 4
						)
						|
						#"u" copy char 4 hx (
							char: to char! to integer! to issue! char
						)
					]
				] (char)
			]

			func [text [string! none!]][
				either none? text [make string! 0][
					all [parse text [any [to "\" escape] to end] text]
				]
			]
		]

		[#"^"" copy val [any [some ch | #"\" [#"u" 4 hx | es]]] #"^"" (val: decode val)]
	]

	block: use [list][
		list: [space opt [value any [comma value]] space]

		[#"[" new-child list #"]" neaten-one to-parent]
	]

	_content: [#"{" space {"_content"} space #":" space value space "}"] ; Flickr

	object: use [name list as-map][
		name: [
			string space #":" space (
				emit either is-flat [
					;to tag! val
					to-set-word val
				][
					any [
						to-word val
						val
					]
				]
			)
		]
		list: [space opt [name value any [comma name value]] space]
		as-map: [(unless is-flat [here: change back here make map! pick back here 1])]

		[#"{" new-child list #"}" neaten-two to-parent as-map]
	]

	ident: use [initial ident][
		initial: charset ["$_" #"a" - #"z" #"A" - #"Z"]
		ident: union initial charset [#"0" - #"9"]

		[initial any ident]
	]

	value: [
		  "null" (emit none)
		| "true" (emit true)
		| "false" (emit false)
		| number (emit val)
		| string (emit val)
		| _content
		| object | block
	]

	func [
		"Convert a JSON string to Rebol data"
		json [string!] "JSON string"
		/flat "Objects are imported as tag-value pairs"
		/padded "Loads JSON data wrapped in a JSONP envelope"
	][
		is-flat: :flat
		tree: here: make block! 0

		either parse json either padded [
			[space ident space "(" space opt value space ")" opt ";" space]
		][
			[space opt value space]
		][
			pick tree 1
		][
			do make error! "Not a valid JSON string"
		]
	]
]

to-json: use [
	json emit escape emit-string emit-issue emit-date
	here lookup comma block object block-of-pairs value
][
	emit: func [data][repend json data]

	escape: use [mp ch to-char encode][
		mp: #(#"^/" "\n" #"^M" "\r" #"^-" "\t" #"^"" "\^"" #"\" "\\" #"/" "\/")
		ch: intersect ch: charset [#" " - #"~"] difference ch charset words-of mp

		to-char: func [char [char!]][
			rejoin ["\u" skip tail form to-hex to integer! char -4]
		]

		encode: use [mark][
			[
				change mark: skip (
					case [
						find mp mark/1 [select mp mark/1]
						mark/1 < 10000h [to-char mark/1]
						mark/1 [
							rejoin [
								to-char mark/1 - 10000h / 400h + D800h
								to-char mark/1 - 10000h // 400h + DC00h
							]
						]
						/else ["\uFFFD"]
					]
				)
			]
		]

		func [text][
			also text parse text [any [some ch | encode]]
		]
	]

	emit-string: func [data][emit {"} emit data emit {"}]

	emit-issue: use [dg nm mk][
		dg: charset "0123456789"
		nm: [opt #"-" some dg]

		quote (either parse next form here/1 [copy mk nm][emit mk][emit-string here/1])
	]

	emit-date: use [second][
		quote (
			emit-string rejoin collect [
				keep reduce [
					pad/left/with here/1/year 4 #"0"
					#"-" pad/left/with here/1/month 2 #"0"
					#"-" pad/left/with here/1/day 2 #"0"
				]
				if here/1/time [
					keep reduce [
						#"T" pad/left/with here/1/hour 2 #"0"
						#":" pad/left/with here/1/minute 2 #"0"
						#":"
					]
					keep pad/left/with to integer! here/1/second 2 #"0"
					any [
						".0" = second: find form round/to here/1/second 0.000001 #"."
						keep second
					]
					keep either any [
						none? here/1/zone
						zero? here/1/zone
					][#"Z"][
						reduce [
							either here/1/zone/hour < 0 [#"-"][#"+"]
							pad/left/with absolute here/1/zone/hour 2 #"0"
							#":" pad/left/with here/1/zone/minute 2 #"0"
						]
					]
				]
			]
		)
	]

	lookup: [
		change [get-word! | get-path!] (reduce reduce [here/1])
	]

	comma: quote (unless tail? here [emit ","])

	block: [
		(emit #"[") any [here: value here: comma] (emit #"]")
	]

	block-of-pairs: [
		  some [set-word! skip]
		| some [tag! skip]
	]

	object: [
		(emit "{")
		any [
			here: [set-word! (change here to word! here/1) | any-string! | any-word!]
			(emit [{"} escape to string! here/1 {":}])
			here: value here: comma
		]
		(emit "}")
	]

	value: [
		  lookup fail ; resolve a GET-WORD! reference
		| number! (emit here/1)
		| [logic! | 'true | 'false] (emit to string! here/1)
		| [none! | 'none | 'none] (emit "null")
		| date! emit-date
		| issue! emit-issue
		| [
			any-string! | word! | lit-word! | tuple! | pair! | time!
		] (emit-string escape form here/1)
		| any-word! (emit-string escape form to word! here/1)

		| ahead [object! | map!] (change/only here body-of first here) into object
		| ahead into block-of-pairs (change/only here copy first here) into object
		| ahead any-block! (change/only here copy first here) into block

		| any-type! (emit-string to tag! type? first here)
	]

	func [data][
		json: make string! 1024
		if parse compose/only [(data)][here: value][json]
	]
]

.from-json: function[json-string][

{Example:
	from-json: :.from-json
	data: from-json read https://api.coinmarketcap.com/v1/ticker/bitcoin/?convert=USD
	price: to-float data/price_usd
	?? price
}	

	data: load-json json-string
	if block? data [
		if (length? data) = 1 [
			data: pick data 1
		]
	]
	return data
]

from-json: :.from-json




