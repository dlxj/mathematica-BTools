(* ::Package:: *)

(* Autogenerated Package *)

Newlineate::usage=
	"Spreads an iterable out over newlines";
NewlineateInput::usage=
	"Spreads like Input";
NewlineateCode::usage=
	"Spreads like Code";
NewlineateRecursive::usage=
	"Applies NewlineateRecursively";
NewlineateCodeRecursive::usage=
	"Spreads like Code recursively";
NewlineateInputRecursive::usage=
	"Spreads like Input recursively";


BoxQ::usage="Alias for a different BoxQ";
BoxesToString::usage="";


PrettyString::usage="";


Begin["`Private`"];


(* ::Subsection:: *)
(*Boxes*)



(* ::Subsubsection::Closed:: *)
(*BoxQ*)



Clear@BoxQ;
BoxQ[_GraphicsBox]:=True;
BoxQ[_RasterBox]:=True;
BoxQ[e_]:=
	Replace[
		System`Convert`TeXFormDump`BoxQ[e],
		False:>StringMatchQ[ToString@Head[e],"*Box"]
		];


(* ::Subsubsection::Closed:: *)
(*BoxesToString*)



BoxesToString[b_]:=
	FrontEndExecute[
		ExportPacket[
			Cell[
				BoxData@b,
				"Input"
				],
			"InputText"
			]
		][[1]]


(* ::Subsection:: *)
(*Newlineate*)



$indentingNewLine="\[IndentingNewLine]";


(* ::Subsubsection::Closed:: *)
(*Newlineate*)



Newlineate//Clear;
Newlineate[l_List,
	openChar:_String|{___String},
	endChar:_String|{___String},
	newline:_String|{___String},
	riffle:_String|{___String}:",",
	every_Integer
	]:=
	Block[{newLineateCounter=1},
		ReplaceAll[
			RowBox@
				Flatten[
					Flatten@
						ReplaceRepeated[
							ToBoxes@Range[Length@l],
							RowBox[r_]:>r
							]/.{
					"{":>
						Sequence@@{openChar,newline},
					",":>
						If[Mod[newLineateCounter++,every]===0,
							newLineateCounter=1;
							Sequence@@{riffle,newline},
							riffle
							],
					"}":>
						Sequence@@{newline,endChar}
					}
				],
			MapThread[Rule,{
				ToString/@Range[Length@l],
				If[MatchQ[#,RowBox[{___,"&"}]],
					RowBox[{"(",#,")"}],
					#
					]&@ToBoxes@Unevaluated@#&/@l
				}]
			]
		]//RawBoxes;
Newlineate[l_List,newLine:{___String}|_?BoxQ:"\n\t",every:_Integer:1]:=
	Newlineate[l,"{","}",newLine,every];
Newlineate[a_Association,
	newLine:{___String}|_?BoxQ:"\n\t",
	every:_Integer:1
	]:=
	Newlineate[
		If[AssociationQ@a,Normal@a,List@@a],
		"<|","|>",
		newLine,every];
Newlineate[r_Rule,newLine:{___String}|_?BoxQ:"\n\t",every:_Integer:1]:=
	Newlineate[List@@r,"","",
		"",
		{"->",If[StringEndsQ[newLine,"\t"],newLine<>"\t",newLine]},
		every];
Newlineate[
	e:Except[_List|_Association|_Rule|_?(MatchQ[ToBoxes[#],_String]&)],
	newLine:{___String}|_?BoxQ:"\n\t",every:_Integer:1]:=
	With[{list=List@@e,h=ToString@Head@e<>"["},
		Newlineate[list,h,"]",newLine,every]
		];
HoldPattern[Newlineate[newline:{___String}|_?BoxQ][
	e:Except[_?(Length@#===0&)],
	every:_Integer:1]
	]:=
	Newlineate[e,
		Replace[newline,{
			"Input"->
				$indentingNewLine,
			"Code"->
				"\n\t",
			_->newline
			}],
		every
		];


(* ::Subsubsection::Closed:: *)
(*NewlineateInput*)



NewlineateInput[
	e:Except[_?(Length@#===0&)],
	every:_Integer:1
	]:=
	Newlineate["Input"][e,every];
NewlineateInput[s_?(Length@#===0&),every:_Integer:1]:=
	s;


(* ::Subsubsection::Closed:: *)
(*NewlineateCode*)



NewlineateCode[
	e:Except[_?(Length@#===0&)],
	every:_Integer:1
	]:=
	Newlineate["Code"][e,every];
NewlineateCode[
	s_?(Length@#===0&),
	every:_Integer:1
	]:=
	s


(* ::Subsection:: *)
(*NewlineateRecursive*)



(* ::Subsubsection::Closed:: *)
(*NewlineateRecursive*)



NewlineateRecursive[
	expr_?(Function[Null,Length@Unevaluated@#>0,HoldFirst]),
	newline:_String:"\n",
	indent:_String:"\t",
	every:_Integer:1,
	match:_?(Length@#>0&):_List,
	ignore:_Symbol|_?(Length@#>0&):None
	]:=
	Block[{
		$newlineIndentationLevel=
			If[IntegerQ@$newlineIndentationLevel,
				$newlineIndentationLevel+1,
				1]
		},
		Which[
			MatchQ[Unevaluated@expr,ignore],
				Replace[
					Function[Null,
						NewlineateRecursive[#,
							newline,
							indent,
							every,
							match
							],
						HoldFirst
						]/@Replace[Hold[expr],Hold[_[a___]]:>Hold[a]],
					Hold[a__]:>
							RuleCondition[
								With[{
									h=Head[Unevaluated[expr]],
									p=List[a]
									},
									Replace[p,
										{b__}:>
											RawBoxes@ToBoxes@h[b]
										]
									],
								True
								]
					],
			MatchQ[Unevaluated@expr,match],
				Newlineate[
					Replace[
						Function[Null,
							NewlineateRecursive[#,
								newline,
								indent,
								every,
								match
								],
							HoldFirst
							]/@Replace[Hold[expr],Hold[_[a___]]:>Hold[a]],
						Hold[a__]:>
							RuleCondition[
								With[{
									h=Head[Unevaluated[expr]],
									p=List[a]
										},
										Replace[p,
											{b__}:>Unevaluated@h[b]
											]
										],
									True
									]
							],
						newline<>
							StringRepeat[indent,
								$newlineIndentationLevel
								],
						every
						],
				True,
					RawBoxes@ToBoxes@Unevaluated[expr]
				]
		];
NewlineateRecursive[a_?(
	Function[Null,
		Length@Unevaluated[#]===0,
		HoldFirst
		]),___]:=
	RawBoxes@ToBoxes@Unevaluated@a;
NewlineateRecursive~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*NewlineateCodeRecursive*)



NewlineateCodeRecursive[expr_,
	every:_Integer:1,
	match:_?((Length@#>0)&):_List,
	ignore:_Symbol|_?(Length@#>0&):None
	]:=
	NewlineateRecursive[expr,
		"\n",
		"\t",
		every,
		match
		];


(* ::Subsubsection::Closed:: *)
(*NewlineateInputRecursive*)



NewlineateInputRecursive[expr_,
	every:_Integer:1,
	match:_?(Length@#>0&):_List,
	ignore:_Symbol|_?(Length@#>0&):None
	]:=
	NewlineateRecursive[expr,
		$indentingNewLine,
		"",
		every,
		match
		]


(* ::Subsection:: *)
(*PrettyString*)



PrettyString[
	expr_,
  elementsPerLine : _?IntegerQ : 1,
  dataType : TextData | BoxData : BoxData,
  cellStyle : _String : "Input",
  ops : OptionsPattern[Cell]
  ]:=
	 StringDelete[
	  FrontEndExecute[
	    FrontEnd`ExportPacket[
	     Cell[
	      dataType@
	        GeneralUtilities`PrettyFormBoxes[expr, elementsPerLine]/.
							TemplateBox[
		         {sym_, ___},
		         "DefinitionSymbol", 
		         ___
		         ]:>sym, 
	      cellStyle,
	      ops,
	      PageWidth -> Infinity
	      ],
	     "PlainText"
	     ]
	   ][[1]],
	 "\\" ~~ "\n"
	 ]


End[];



