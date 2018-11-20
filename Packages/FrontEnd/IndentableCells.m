(* ::Package:: *)



MakeIndentable::usage="Makes a cell or notebook in/dedentable";


(*IndentationDecrease::usage="Dedents lines in cell";
IndentationIncrease::usage="Indents lines";
*)


(*
IndentingNewLineReplace::usage=
	"The core function that replaces indenting new lines in RowBoxes";
IndentingNewLineRestore::usage=
	"Restores NewLines";
	*)


(*IndentationReplace::usage=
	"Replaces all indenting new lines with appropriate indentation";
IndentationRestore::usage=
	"Replaces all raw newlines and indentation with indenting new lines";*)


IndentationEvent::usage=
  "Adds/Removes/Toggles indents in a notebook";
BatchIndentationEvent::usage=
  "Applies an IndentationEvent in batch to a notebook";


Begin["`Private`"];


$IndentationCharDefault="\t";
GetIndentationChar[nb:(_NotebookObject|Automatic):Automatic]:=
  Set[$IndentationChar, 
    Replace[
      CurrentValue[
        Replace[nb, Automatic:>InputNotebook[]], 
        {TaggingRules, "IndentCharacter"}
        ],
      Except[_String]->$IndentationCharDefault
      ]
    ];
If[!ValueQ@$IndentationChar, $IndentationChar:=GetIndentationChar[]]


(* ::Subsection:: *)
(*Make Indentable*)



With[{pkg=$PackageName<>"`"},
Options[MakeIndentable]=
  {
    "IndentCharacter"->Automatic
    };
MakeIndentable[
  nb:_NotebookObject|Automatic:Automatic,
  cell:_String|All|{(All|_String)..}|_CellObject|{__CellObject}:All,
  ops:OptionsPattern[]
  ]:=
  Replace[
    Replace[Flatten@List@cell,
      Except[{__CellObject}]:>
        StyleSheetCells[nb, cell,
          "MakeCell"->True,
          "DetectStylesheet"->True
          ]
      ],{
    s:{__CellObject}:>
      CompoundExpression[
        StyleSheetEdit[s,{
          AutoIndent->True,
          LineIndent->1,
          TabSpacings->1.5
          }];
        Replace[OptionValue["IndentCharacter"],
          t_String:>
            StyleSheetEditTaggingRules[
              s,
              {
                "IndentCharacter"->t
                }
              ]
          ];
        StyleSheetEditEvents[s,{
          {"MenuCommand","SelectionCloseAllGroups"}:>
            Quiet@Check[
              Needs[pkg];
              Replace[
                Join[
                  Names[pkg<>"IndentationEvent"],
                  Names[pkg<>"*`IndentationEvent"]
                 ],
               {
                 f:{__}:>
                   SelectFirst[ToExpression[f], Length@DownValues[#]>0&]["Indent"],
                 _:>SetAttributes[EvaluationCell[],CellEventActions->None]
                 }
                ],
              SetAttributes[EvaluationCell[],CellEventActions->None]
              ],
          {"MenuCommand","SelectionOpenAllGroups"}:>
            Quiet@Check[
              Needs[pkg];
              Replace[
                Join[
                  Names[pkg<>"IndentationEvent"],
                  Names[pkg<>"*`IndentationEvent"]
                 ],
               {
                 f:{__}:>
                   SelectFirst[ToExpression[f], Length@DownValues[#]>0&]["Dedent"],
                 _:>SetAttributes[EvaluationCell[],CellEventActions->None]
                 }
                ],
              SetAttributes[EvaluationCell[],CellEventActions->None]
              ],
          {"MenuCommand","InsertMatchingBrackets"}:>
          Quiet@Check[
              Needs[pkg];
              Replace[
                Join[
                  Names[pkg<>"IndentationEvent"],
                  Names[pkg<>"*`IndentationEvent"]
                 ],
               {
                 f:{__}:>
                   SelectFirst[ToExpression[f], Length@DownValues[#]>0&]["Toggle"],
                 _:>SetAttributes[EvaluationCell[], CellEventActions->None]
                 }
                ],
              SetAttributes[EvaluationCell[], CellEventActions->None]
              ],
          PassEventsDown->False
          }]
        ],
      _->$Failed
      }
    ]
  ];


(* ::Subsection:: *)
(*Indentation Replacement*)



$indentingNewLine="\[IndentingNewLine]";


$rawNewLine="
]";


(* ::Subsubsection::Closed:: *)
(*Replace old indentation*)



indentingNewLineReplace[r:RowBox[data_]]:=
  RowBox@
    Replace[data,
      {
        k:"@"|"->"|"\[Rule]"|":>"|"\[RuleDelayed]"|"="|":=":>
          CompoundExpression[
            $indentationAddFlag=True,
            k
            ],
        k:"{"|"["|"(":>
          CompoundExpression[
            $indentationUnbalancedBrackets[k]++,
            k
            ],
        "}":>
          CompoundExpression[
            $indentationUnbalancedBrackets["{"]=
              Max@{$indentationUnbalancedBrackets["{"]-1,0},
            "}"
            ],
        "]":>
          CompoundExpression[
            $indentationUnbalancedBrackets["["]=
              Max@{$indentationUnbalancedBrackets["["]-1,0},
            "]"
            ],
        ")":>
          CompoundExpression[
            $indentationUnbalancedBrackets["("]=
              Max@{$indentationUnbalancedBrackets["("]-1,0},
            ")"
            ],
        e:"<|"|"\[LeftAssociation]":>
          CompoundExpression[
            $indentationUnbalancedBrackets["\[LeftAssociation]"]++,
            e
            ],
        e:"|>"|"\[RightAssociation]":>
          CompoundExpression[
            Max@{$indentationUnbalancedBrackets["\[LeftAssociation]"]-1,0},
            e
            ],
        r2_RowBox:>
          indentingNewLineReplace[r2],
        $indentingNewLine:>
          CompoundExpression[
            Map[
              Which[
                $indentationUnbalancedBrackets[#]>$intentationPreviousLevels[#],
                  $indentationLevel[#]++,
                $indentationUnbalancedBrackets[#]<$intentationPreviousLevels[#],
                  $indentationLevel[#]=
                    Max@{$indentationLevel[#]-1,0}
                ]&,
              Keys@$indentationLevel],
            $intentationPreviousLevels=$indentationUnbalancedBrackets,
            "\n"<>
              If[Total@$indentationLevel>0,
                StringRepeat[$IndentationChar, 
                  If[$indentationAddFlag, $indentationAddFlag=False;1, 0]+
                    Total@$indentationLevel
                  ],
                ""
                ]
            ],
        e_:>($indentationAddFlag=False;e)
        },
      1];


IndentingNewLineReplace[r:RowBox[data_]]:=
  Block[{
    $indentationAddFlag=False,
    $indentationUnbalancedBrackets=
      <|"\[LeftAssociation]"->0,"["->0,"{"->0,"("->0|>,
    $intentationPreviousLevels=
      <|"\[LeftAssociation]"->0,"["->0,"{"->0,"("->0|>,
    $indentationLevel=
      <|"\[LeftAssociation]"->0,"["->0,"{"->0,"("->0|>
    },
    indentingNewLineReplace[r]
    ];
IndentingNewLineReplace[s_String]:=
  s;


IndentationReplace[nb:(_NotebookObject|Automatic):Automatic]:=
  With[{inputNotebook=Replace[nb,Automatic:>InputNotebook[]]},
    With[{selection=IndentationSelection@inputNotebook},
      With[{write=IndentingNewLineReplace@selection},
        NotebookWrite[
          inputNotebook,
          write,
          If[MatchQ[write,_String?(StringMatchQ[Whitespace])],
            After,
            All],
          AutoScroll->False
          ]
        ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*Restore newlines*)



IndentingNewLineRestore[r:RowBox[data_]]:=
  Block[{repTabs=True},
    RowBox[
      Map[
        Switch[#,
          "\n"|$rawNewLine,
            repTabs=True;
            $indentingNewLine,
          _String?(repTabs&&StringMatchQ[#,$IndentationChar~~(""|Whitespace)]&),
            Nothing,
          _RowBox,
            repTabs=False;
            IndentingNewLineRestore[#],
          _,
            repTabs=False;
            #
          ]&,
        data
        ]
      ]
    ];
IndentingNewLineRestore[s_String]:=s;


IndentationRestore[nb:(_NotebookObject|Automatic):Automatic]:=
  With[{inputNotebook=Replace[nb,Automatic:>InputNotebook[]]},
    With[{selection=IndentationSelection@inputNotebook},
      With[{write=IndentingNewLineRestore@selection},
        NotebookWrite[
          inputNotebook,
          write,
          If[MatchQ[write,_String?(StringMatchQ[Whitespace])],
            After,
            All
            ],
          AutoScroll->False
          ]
        ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*Toggle*)



IndentationToggle[nb:(_NotebookObject|Automatic):Automatic]:=
  With[{no=Replace[nb, Automatic:>InputNotebook[]]},
    If[Not@FreeQ[IndentationSelection@no,$indentingNewLine],
      IndentationReplace[no],
      IndentationRestore[no]
      ]
    ]


(* ::Subsection:: *)
(*Indentation Code*)



(* ::Subsubsection::Closed:: *)
(*IndentationSelection*)



IndentationSelection[inputNotebook_]:=
  Replace[NotebookRead@inputNotebook,{
    Cell[BoxData[d_]|d_String,___]:>
      CompoundExpression[
        SelectionMove[First@SelectedCells[],All,CellContents],
        d]
    }];


(* ::Subsubsection::Closed:: *)
(*Indent	*)



indentationAddTabsRecursiveCall//Clear


indentationAddTabsRecursiveCall[RowBox[d:{___}]]:=
  RowBox@
    Replace[d,{
      r_RowBox:>
        indentationAddTabsRecursiveCall[r],
      s_String?(StringMatchQ[$indentingNewLine~~___]):>
        StringInsert[StringDrop[s,1],"\n"<>$IndentationChar,1],
      s_String?(StringMatchQ["\n"~~___]):>
        StringInsert[s,$IndentationChar,2]
        },
      1];
indentationAddTabsRecursiveCall[b_[d_RowBox, a___]]:=
  b[indentationAddTabsRecursiveCall[d], a];
indentationAddTabsRecursiveCall[e_]:=
  e;
indentationAddTabs[sel_]:=
  Replace[
    sel,{
      {}:>$IndentationChar,
    _String:>
      StringReplace[sel,{
        "\n":>"\n"<>$IndentationChar,
        StartOfString:>$IndentationChar
        }],
    _:>
      Replace[indentationAddTabsRecursiveCall[sel],
        RowBox[{data___}]:>
          RowBox[{$IndentationChar,data}]
          ]
    }];


IndentationIncrease[nb:(_NotebookObject|Automatic):Automatic]:=
With[{inputNotebook=Replace[nb,Automatic:>InputNotebook[]]},
With[{write=indentationAddTabs@IndentationSelection@inputNotebook},
NotebookWrite[
      inputNotebook,
      write,
If[MatchQ[write,_String?(StringMatchQ[Whitespace])],
After,
All],
      AutoScroll->False
      ]
]
];


(* ::Subsubsection::Closed:: *)
(*Dedent*)



(* ::Text:: *)
(*Need a way to make sure final lines aren\[CloseCurlyQuote]t ignored.*)



indentationDelTabsRecursiveCall//Clear
indentationDelTabsRecursiveCall[RowBox[d:{___}]]:=
  RowBox@
    Replace[d,{
      r_RowBox:>
        indentationDelTabsRecursiveCall[r],
      $indentingNewLine->
        "\n",
      "\n":>
        CompoundExpression[
          $dedentationRequired=True,
          "\n"
          ],
      s_String?(StringMatchQ[$IndentationChar~~___]):>
        CompoundExpression[
          If[$dedentationRequired,
            $dedentationRequired=False;
            StringDrop[s,StringLength[$IndentationChar]],
            s
            ]
          ]
        },
      1];
indentationDelTabsRecursiveCall[b_[d_RowBox, a___]]:=
  b[indentationDelTabsRecursiveCall[d], a];
indentationDelTabsRecursiveCall[e_]:=
  e;
indentationDelTabs[sel_]:=
  Replace[sel,
    {
    _String:>
      StringReplace[sel,{
        "\n"<>$IndentationChar:>"\n",
          StartOfLine~~$IndentationChar:>""
        }],
    {}:>"",
    _RowBox:>
      Block[{
        $dedentationRequired=True
        },
        indentationDelTabsRecursiveCall[sel]
        ]
    }];


IndentationDecrease[nb:(_NotebookObject|Automatic):Automatic]:=
  With[{inputNotebook=Replace[nb,Automatic:>InputNotebook[]]},
    With[{write=indentationDelTabs@IndentationSelection@inputNotebook},
      NotebookWrite[
        inputNotebook,write,
        If[MatchQ[write,_String?(StringMatchQ[Whitespace])],
          After,
          All
          ],
        AutoScroll->False
        ]
      ]
    ];


(* ::Subsection:: *)
(*Main handler*)



IndentationEvent[nb:(_NotebookObject|Automatic):Automatic, 
  mode:"Indent"|"Dedent"|"Replace"|"Restore"|"Toggle"
  ]:=
  With[{no=Replace[nb, Automatic:>EvaluationNotebook[]]},
    GetIndentationChar[no];
    Switch[
      mode,
      "Indent",
        If[Not@FreeQ[NotebookRead@no,$indentingNewLine],
          IndentationReplace[no],
          IndentationIncrease[no]
          ],
      "Dedent",
        IndentationDecrease[no],
      "Replace",
        IndentationReplace[no],
      "Restore",
        IndentationRestore[no],
      "Toggle",
        If[Not@FreeQ[NotebookRead@no,$indentingNewLine],
          IndentationReplace[no],
          IndentationRestore[no]
          ]
      ]
    ]


IndentationEvent[nb:(_NotebookObject|Automatic):Automatic]:=
  With[{no=Replace[nb, Automatic:>EvaluationNotebook[]]},
    If[AllTrue[
        {"OptionKey","ShiftKey"},
        CurrentValue[no,#]&
        ],
      IndentationEvent[no, "Toggle"],
      Which[
        Not@FreeQ[NotebookRead@no,$indentingNewLine],
          IndentationEvent[no, "Replace"],
        CurrentValue["OptionKey"],
          IndentationEvent[no, "Decrease"],
        True,
          IndentationEvent[no, "Increase"]
        ]
      ];
    ]


Options[batchIndentationEvent]=
  Options@Cells;
batchIndentationEvent[no_NotebookObject, 
  function_,
  ops:OptionsPattern[]
  ]:=
  Internal`WithLocalSettings[
    FrontEndExecute@
      FrontEnd`NotebookSuspendScreenUpdates[no],
    Map[
      Function[
        SelectionMove[#, All, CellContents,
          AutoScroll->False
          ];
        function[no]
        ],
      Cells[no, Sequence@@FilterRules[{ops}, Options@Cells]]
      ];,
    FrontEndExecute@
      FrontEnd`NotebookResumeScreenUpdates[no]
  ];


Options[BatchIndentationEvent]=
  Options[batchIndentationEvent];
BatchIndentationEvent[
  nb:(_NotebookObject|Automatic):Automatic,
  mode:"Indent"|"Dedent"|"Toggle"|"Replace"|"Restore",
  ops:OptionsPattern[]
  ]:=
  With[{no=Replace[nb, Automatic:>EvaluationNotebook[]]},
    GetIndentationChar[no];
    batchIndentationEvent[
      no,
      Switch[mode, 
        "Indent",
          IndentationIncrease,
        "Dedent",
          IndentationDecrease,
        "Replace",
          IndentationReplace,
        "Restore",
          IndentationRestore,
        "Toggle",
          IndentationToggle
        ],
      ops
      ]
    ]


End[];



