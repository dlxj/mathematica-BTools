(* ::Package:: *)



AutoFunctionInfo::usage=
  "AutoFunctionInfo[function, ops] generates the front-end integration info
AutoFunctionInfo[{fns...}] generates a combined expression for all fns
AutoFunctionInfo[stringPat] generates for Names[stringPat]";


AddFunctionUsageTemplate::usage="";
AddFunctionAutocompletions::usage=
  "Adds autocompletion data to a pattern";
AddFunctionSyntaxInformation::usage="";
AddFunctionArgCount::usage="";


SetAutocompletions::usage="Straight-up sets autocompletions";
SetArgCount::usage="Straight-up sets the arg-count";


GenerateFunctionInfo::usage=
  "Extracts function information";


Begin["`Private`"];


(* ::Subsection:: *)
(*CodeValues*)



(* ::Subsubsection::Closed:: *)
(*getCodeValues*)



getCodeValues[f_Symbol,
  vs :
  {Repeated[
      OwnValues | DownValues | SubValues | UpValues]} : {OwnValues, 
    DownValues, SubValues, UpValues}
  ] :=
Select[
  If[Intersection[Attributes@f, { ReadProtected, Locked}] === { 
      Locked, ReadProtected},
    {},
    Join @@ Map[#[f] &, vs]
    ],
  FreeQ[ArgumentCountQ]
  ];
getCodeValues~SetAttributes~HoldFirst


(* ::Subsection:: *)
(*Usage*)



(* ::Subsubsection::Closed:: *)
(*usagePatternReplace*)



$privateWorkingCont=$Context<>"Working`";


extractorLocalized[s_] :=
  Block[{$ContextPath = {"System`"}, $Context = $privateWorkingCont},
    Internal`WithLocalSettings[
      BeginPackage[$privateWorkingCont];
      Off[General::shdw];,
      ToExpression[s],
      On[General::shdw];
      EndPackage[]
      ]
    ];
$usageTypeReplacements =
  {
    Integer -> extractorLocalized["int"],
    Real -> extractorLocalized["float"],
    String -> extractorLocalized["str"],
    List -> extractorLocalized["list"],
    Association -> extractorLocalized["assoc"],
    Symbol -> extractorLocalized["sym"]
    };
$usageSymNames =
  {
    Alternatives -> extractorLocalized["alt"],
    PatternTest -> extractorLocalized["test"],
    Condition -> extractorLocalized["cond"],
    s_Symbol :>
    RuleCondition[
      extractorLocalized@
      ToLowerCase[StringTake[SymbolName[Unevaluated@s], UpTo[3]]],
      True
      ]
    };
symbolUsageReplacementPattern[names_, conts_] :=
  s_Symbol?(
    GeneralUtilities`HoldFunction[
      ! MatchQ[Context[#], conts] &&
      ! 
      MemberQ[$ContextPath, Context[#]] &&
      ! 
      KeyMemberQ[names, SymbolName@Unevaluated[#]]
      ]
    ) :>
  RuleCondition[
    ToExpression@
      Evaluate[$Context <>
        With[{name = SymbolName@Unevaluated[s]},
          If[StringLength@StringTrim[name, "$"] > 0,
            StringTrim[name, "$"],
            name
            ]
          ]
        ],
    True];
usagePatternReplace[
  vals_,
  reps_: {}
  ] :=
With[{
    names = AssociationMap[Null &, {}(*Names[]*)],
    conts = 
    Alternatives @@ {
      "System`", "FrontEnd`", 
      "PacletManager`", "Internal`"
      },
    repTypes=Alternatives@@Map[Blank, Keys@$usageTypeReplacements]
    },
  Replace[
    Replace[
      #,
      {
        Verbatim[HoldPattern][a___] :> a
        },
      {2, 10}
      ],
    Join[$usageTypeReplacements, $usageSymNames],
    Depth[#]
    ] &@
  ReplaceRepeated[
    FixedPoint[
      Replace[
        #,
        {
          Verbatim[Pattern][_, e_] :>
          e,
          Verbatim[HoldPattern][Verbatim[Pattern][_, e_]] :>
          HoldPattern[e],
          Verbatim[HoldPattern][Verbatim[HoldPattern][e_]] :>
          HoldPattern[e]
          },
        1
        ] &,
      vals
      ],
    Flatten@{
      reps,
      Verbatim[PatternTest][_, ColorQ] :>
      extractorLocalized@"color",
      Verbatim[PatternTest][_, ImageQ] :>
      extractorLocalized@"img",
      Verbatim[Optional][name_, _] :>
      name,
      Verbatim[Pattern][_, _OptionsPattern] :>
      Sequence[],
      Verbatim[Pattern][name_, _] :>
      name,
      Verbatim[PatternTest][p_, _] :>
      p,
      Verbatim[Condition][p_, _] :>
      p,
      (* for dispatching functions by Alternatives *)
      Verbatim[Alternatives][a_, ___][___] |
      Verbatim[Alternatives][a_, ___][___][___] |
      Verbatim[Alternatives][a_, ___][___][___][___] |
      Verbatim[Alternatives][a_, ___][___][___][___][___] |
      Verbatim[Alternatives][a_, ___][___][___][___][___][___] :>
      a,
      Verbatim[Alternatives][a_, ___] :>
      RuleCondition[
        Blank[
          Replace[
            Hold@a,
            {
              Hold[p : Verbatim[HoldPattern][_]] :>
              p,
              Hold[repTypes]:>Head[a],
              Hold[e_[___]] :> e,
              _ :> a
              }
            ]
          ],
        True
        ],
      Verbatim[Verbatim][p_][a___] :>
      p,
      Verbatim[Blank][] :>
      extractorLocalized@"expr",
      Verbatim[Blank][
        t : Alternatives @@ Keys[$usageTypeReplacements]] :>
      
      RuleCondition[
        Replace[t,
          $usageTypeReplacements
          ],
        True
        ],
      Verbatim[Blank][t_] :>
      t,
      Verbatim[BlankSequence][] :>
      
      Sequence @@ extractorLocalized[{"expr1", "expr2"}],
      Verbatim[BlankNullSequence][] :>
      Sequence[],
      symbolUsageReplacementPattern[names, conts],
      h_[a___, Verbatim[Sequence][b___], c___] :> h[a, b, c]
      }
    ]
  ];


(* ::Subsubsection::Closed:: *)
(*generateSymbolUsage*)



$defaultUsageTemplate = "`` has no usage message";


generateSymbolUsage[
  f_Symbol, 
  defaultMessages : {(_Rule | _RuleDelayed) ...} : {},
  uTemp:_String|Automatic:Automatic
  ] :=
With[
  {
    ut=
      Replace[uTemp, Automatic->$defaultUsageTemplate], 
    uml =
      Replace[defaultMessages,
        {
          (h : Rule | RuleDelayed)[Verbatim[HoldPattern][pat___], m_] :>
            h[HoldPattern[Verbatim[HoldPattern][pat]], m],
          (h : Rule | RuleDelayed)[pat___, m_] :>
            h[Verbatim[HoldPattern][pat], m],
          _ -> Nothing
          },
        {1}
        ]
    },
  DeleteDuplicates@Flatten@
  Replace[
    DeleteDuplicates@usagePatternReplace[Keys@getCodeValues[f]],
    {
      Verbatim[HoldPattern][s_[a___]]:>
      With[
        {
          (* original usage message *)
          uu =
            StringTrim@
              Replace[HoldPattern[s[a]] /. uml,
                Except[_String] :>
                Replace[Quiet@s::usage, Except[_String] -> ""]
                ],
          sn = ToString[Unevaluated@s],
          (* head for the usage message I'm going to add*)
          meuu = 
            StringReplace[
              ToString[Unevaluated[s[a]], InputForm], 
              $privateWorkingCont -> ""
              ]
          },
        Which[!StringContainsQ[uu, StringSplit[meuu, "["][[1]]<>"[" ],
          Which[
            uu == "",
              TemplateApply[ut, meuu], 
            ! StringStartsQ[uu, sn],
              meuu<>" "<>uu,
            True,
              {uu, TemplateApply[ut, meuu]}
            ],
          !StringContainsQ[uu, meuu],
            TemplateApply[ut, meuu],
          True,
            StringCases[
              uu, 
              (StartOfLine | StartOfString) ~~ 
                Except["\n"]... ~~ meuu ~~
                Except["\n"]... ~~ EndOfLine,
              1
              ][[1]]
          ]
        ],
      _ -> Nothing
      },
    {1}
    ]
  ];
generateSymbolUsage~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*AddFunctionUsageTemplate*)



AddFunctionUsageTemplate::baduse="Couldn't set usage string to ``";


Options[AddFunctionUsageTemplate]:=
  {
    "UsageMessages"->{},
    "UsageTemplate"->Automatic
    };
AddFunctionUsageTemplate[
  f_Symbol, 
  head:Except[_?OptionQ]:Identity,
  ops:OptionsPattern[]
  ]:=
  Module[
    {
      um=
        generateSymbolUsage[
          f,
          Cases[
            Flatten@List[OptionsPattern["UsageMessages"]],
            _Rule | _RuleDelayed
            ],
          OptionValue["UsageTemplate"]
          ],
      flag
      },
    If[MatchQ[um, {__String}], um=StringRiffle[um, "\n"]];
    flag=StringQ@um&&StringLength[um]>0;
    If[!flag, Message[AddFunctionUsageTemplate::baduse, um]];
    head@Set[f::usage, um]/;flag
    ];
AddFunctionUsageTemplate~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*AutoComplete*)



(* ::Subsubsection::Closed:: *)
(*autoCompletionsExtractSeeder*)



Attributes[autoCompletionsExtractSeeder] =
{
  HoldFirst
  };
autoCompletionsExtractSeeder[
  HoldPattern[Verbatim[PatternTest][_, ColorQ]] |
  (Blank | BlankSequence)[Hue | RGBColor | XYZColor | LABColor],
  n_
  ] := Sow[n -> "Color"];
autoCompletionsExtractSeeder[
  HoldPattern[Verbatim[PatternTest][_, DirectoryQ]],
  n_
  ] := Sow[n -> "Directory"];
autoCompletionsExtractSeeder[
  HoldPattern[Verbatim[PatternTest][_, FileExistsQ]] |
  (Blank | BlankSequence)[File] | _File,
  n_
  ] := Sow[n -> "FileName"];
autoCompletionsExtractSeeder[
  Verbatim[Alternatives][s__String],
  n_
  ] :=
Sow[n -> {s}];
autoCompletionsExtractSeeder[
  Verbatim[Pattern][_, b_],
  n_
  ] := autoCompletionsExtractSeeder[b, n];
autoCompletionsExtractSeeder[
  Verbatim[Optional][a_, ___],
  n_
  ] := autoCompletionsExtractSeeder[a, n];


(* ::Subsubsection::Closed:: *)
(*autoCompletionsExtract*)



Attributes[autoCompletionsExtract] =
{
  HoldFirst
  };
autoCompletionsExtract[Verbatim[HoldPattern][_[a___]]] :=
{ReleaseHold@
  MapIndexed[
    Function[Null, autoCompletionsExtractSeeder[#, #2[[1]]], 
      HoldAllComplete],
    Hold[a]
    ]
  };
autoCompletionsExtract[f_Symbol] :=
 Flatten@
Reap[
  autoCompletionsExtract /@
  Replace[
    Keys@getCodeValues[f, {DownValues, SubValues, UpValues}],
    {
      Verbatim[HoldPattern][
        HoldPattern[
          f[a___][___]|
          f[a___][___][___]|
          f[a___][___][___][___]|
          f[a___][___][___][___][___]|
          f[a___][___][___][___][___][___]
          ]
        ]:>HoldPattern[f[a]],
      Verbatim[HoldPattern][
        HoldPattern[
          _[___, f[a___], ___]|
          _[___, f[a___][___], ___]|
          _[___, f[a___][___][___], ___]|
          _[___, f[a___][___][___][___], ___]|
          _[___, f[a___][___][___][___][___], ___]|
          _[___, f[a___][___][___][___][___][___],  ___]
          ]
        ]:>HoldPattern[f[a]]
      },
    {1}
    ]
  ][[2]]


(* ::Subsubsection::Closed:: *)
(*generateAutocompletions*)



generateAutocompletions[
  f : _Symbol : None, 
  otherAutos : {(_Integer -> _) ...} : {}
  ] :=
With[
  {
    gg =
    Join[
      GroupBy[
        If[Unevaluated[f] =!= None,
          autoCompletionsExtract[f],
          {}
          ],
        First -> Last,
        Replace[{s_, ___} :> s]
        ],
      GroupBy[
        otherAutos,
        First -> Last
        ]
      ]
    },
  With[{km = Max@Append[Keys@gg, 0]},
    Table[
      Lookup[gg, i, None],
      {i, km}
      ]
    ]
  ];
SetAttributes[generateAutocompletions, HoldFirst];


(* ::Subsection:: *)
(*Autocompletions*)



ClearAttributes[AddFunctionAutocompletions, HoldFirst]


(* ::Subsubsection::Closed:: *)
(*Formats*)



$FEAutoCompletionFormats=
  Alternatives@@
    Join[
      {
        _String?(FileExtension[#]==="trie"&),
        {
          _String|(Alternatives@@Range[0,9])|{__String},
          (("URI"|"DependsOnArgument")->_)...
          },
        {
          _String|(Alternatives@@Range[0,9])|{__String},
          (("URI"|"DependsOnArgument")->_)...,
          (_String|(Alternatives@@Range[0,9])|{__String})
          },
        {
          __String
          }
        },
      Range[0,9],
      {
        "codingNoteFontCom",
        "ConvertersPath",
        "ExternalDataCharacterEncoding",
        "MenuListCellTags",
        "MenuListConvertFormatTypes",
        "MenuListDisplayAsFormatTypes",
        "MenuListFonts",
        "MenuListGlobalEvaluators",
        "MenuListHelpWindows",
        "MenuListNotebookEvaluators",
        "MenuListNotebooksMenu",
        "MenuListPackageWindows",
        "MenuListPalettesMenu",
        "MenuListPaletteWindows",
        "MenuListPlayerWindows",
        "MenuListPrintingStyleEnvironments",
        "MenuListQuitEvaluators",
        "MenuListScreenStyleEnvironments",
        "MenuListStartEvaluators",
        "MenuListStyleDefinitions",
        "MenuListStyles",
        "MenuListStylesheetWindows",
        "MenuListTextWindows",
        "MenuListWindows",
        "PrintingStyleEnvironment",
        "ScreenStyleEnvironment",
        "Style"
        }
      ];


(* ::Subsubsection::Closed:: *)
(*SetAutocompletions*)



SetAutocompletions[pats:{__Rule}]:=
  If[$Notebooks&&
      Internal`CachedSystemInformation["FrontEnd","VersionNumber"]>10.0,
      FrontEndExecute@FrontEnd`Value@
        Map[
          FEPrivate`AddSpecialArgCompletion[#]&,
          pats
          ],
      $Failed
      ];
SetAutocompletions[a_->b_]:=
  SetAutocompletions[{a->b}]


(* ::Subsubsection::Closed:: *)
(*AddFunctionAutocompletions Base*)



AddFunctionAutocompletions[
  pats:{(_String->{$FEAutoCompletionFormats..})..},
  head_:Identity
  ]:=
  head@SetAutocompletions[pats];
AddFunctionAutocompletions[
  pat:(_String->{$FEAutoCompletionFormats..}), 
  head_:Identity
  ]:=
  AddFunctionAutocompletions[{pat}, head];


(* ::Subsubsection::Closed:: *)
(*AddFunctionAutocompletions Helpers*)



$FEAutocompletionAliases=
  {
    "None"|None|Normal->0,
    "AbsoluteFileName"|AbsoluteFileName->2,
    "FileName"|File|FileName->3,
    "Color"|RGBColor|Hue|XYZColor->4,
    "Package"|Package->7,
    "Directory"|Directory->8,
    "Interpreter"|Interpreter->9,
    "Notebook"|Notebook->"MenuListNotebooksMenu",
    "StyleSheet"->"MenuListStylesheetMenu",
    "Palette"->"MenuListPalettesMenu",
    "Evaluator"|Evaluator->"MenuListGlobalEvaluators",
    "FontFamily"|FontFamily->"MenuListFonts",
    "CellTag"|CellTags->"MenuListCellTags",
    "FormatType"|FormatType->"MenuListDisplayAsFormatTypes",
    "ConvertFormatType"->"MenuListConvertFormatTypes",
    "DisplayAsFormatType"->"MenuListDisplayAsFormatTypes",
    "GlobalEvaluator"->"MenuListGlobalEvaluators",
    "HelpWindow"->"MenuListHelpWindows",
    "NotebookEvaluator"->"MenuListNotebookEvaluators",
    "PrintingStyleEnvironment"|PrintingStyleEnvironment->
      "PrintingStyleEnvironment",
    "ScreenStyleEnvironment"|ScreenStyleEnvironment->
      ScreenStyleEnvironment,
    "QuitEvaluator"->"MenuListQuitEvaluators",
    "StartEvaluator"->"MenuListStartEvaluators",
    "StyleDefinitions"|StyleDefinitions->
      "MenuListStyleDefinitions",
    "CharacterEncoding"|CharacterEncoding|
      ExternalDataCharacterEncoding->
      "ExternalDataCharacterEncoding",
    "Style"|Style->"Style",
    "Window"->"MenuListWindows"
    };


(* ::Subsubsection::Closed:: *)
(*AutocompletionPreCompile*)



AutocompletionPreCompile[v : Except[{__Rule}, _List | _?AtomQ]] :=
  Replace[
    Flatten[{v}, 1],
    $FEAutocompletionTable,
    {1}
    ];
AutocompletionPreCompile[o : {__Rule}] :=
  Replace[o,
    (s_ -> v_) :>
      (
        Replace[s, _Symbol :> SymbolName[s]] ->
          AutocompletionPreCompile[v]
        ),
    1
    ];


AutocompletionPreCompile[s : Except[_List], v_] :=
  AutocompletionPreCompile[{s -> v}];


AutocompletionPreCompile[l_, v_] :=
  AutocompletionPreCompile@
    Flatten@{
      Quiet@
        Check[
          Thread[l -> v],
          Map[l -> # &, v]
          ]
      };


(* ::Subsubsection::Closed:: *)
(*AddFunctionAutocompletions*)



AddFunctionAutocompletions::badcomp=
  "Couldn't add autocompletions for ``";


$FEAutocompletionTable=
  {
    f:$FEAutoCompletionFormats:>
      f,
    Sequence@@$FEAutocompletionAliases,
    s_String:>{s}
    };


AddFunctionAutocompletions[
  o:{__Rule},
  head_:Identity
  ]/;(!TrueQ@$recursionProtect):=
  Block[{$recursionProtect=True},
    Replace[
      AddFunctionAutocompletions[
        AutocompletionPreCompile[o]//Evaluate,
        head
        ],
      HoldPattern[AddFunctionAutocompletions[l_, _]]:>
        (
          Message[AddFunctionAutocompletions::badcomp, l];
          $Failed
          )
      ]
    ];


AddFunctionAutocompletions[l:_String|{__String}, v_, head_:Identity]:=
  AddFunctionAutocompletions[
    AutocompletionPreCompile[l, v]//Evaluate,
    head
    ];


AddFunctionAutocompletions[l_Symbol, v_, head_:Identity]:=
  AddFunctionAutocompletions[SymbolName[Unevaluated@l]//Evaluate, v, head];
AddFunctionAutocompletions[{l__Symbol}, v_, head_:Identity]:=
  AddFunctionAutocompletions[
    List@@Function[Null,SymbolName@Unevaluated[#], HoldFirst]/@Hold[l]//Evaluate, 
    v, 
    head
    ];
AddFunctionAutocompletions[e__]/;(!TrueQ@$eTrueProtection):=
  With[{eTrue={e}},
    Block[{$eTrueProtection=True},
      AddFunctionAutocompletions@@eTrue
      ]
    ];


AddFunctionAutocompletions~SetAttributes~HoldFirst


(* ::Subsection:: *)
(*Pattern Parsing*)



(* ::Subsubsection::Closed:: *)
(*reducePatterns*)



reducePatterns[p_] :=
  Replace[
    p,
    {
      Except[
        _Pattern | _Optional | _Blank | _BlankSequence | 
        _BlankNullSequence | _PatternSequence | _OptionsPattern |
        _Repeated | _RepeatedNull | _Default | _PatternTest | _Condition | 
        _List
        ] -> _
      },
    {2, Infinity}
    ] //. {
    _Blank -> "Blank",
    _BlankSequence -> "BlankSequence",
    _BlankNullSequence -> "BlankNullSequence",
    _OptionsPattern :> "OptionsPattern",
    Verbatim[HoldPattern][
      Verbatim[Pattern][a_, b_]
      ] | Verbatim[Pattern][a_, b_] :> b,
    (PatternTest | Condition)[a_, b_] :> a,
    Verbatim[Optional][a_, ___] :> "Optional"[a],
    _Default -> "Default",
    Verbatim[Repeated][_] -> "Repeated"[\[Infinity]],
    Verbatim[RepeatedNull][_] -> "RepeatedNull"[\[Infinity]],
    Verbatim[Repeated][_, s_] :> "Repeated"[s],
    Verbatim[RepeatedNull][_, s_] :> "RepeatedNull"[s]
    };


(* ::Subsubsection::Closed:: *)
(*extractArgStructureHead*)



(* ::Text:: *)
(*Done in multiple arguments for (assumed) dispatch efficiency*)



extractArgStructureHead[f_, Verbatim[HoldPattern][f_[a___][___]]]:=
  HoldPattern[f[a]];
extractArgStructureHead[f_, Verbatim[HoldPattern][f_[a___][___][___]]]:=
  HoldPattern[f[a]];
extractArgStructureHead[f_, Verbatim[HoldPattern][f_[a___][___][___][___]]]:=
  HoldPattern[f[a]];
extractArgStructureHead[f_, Verbatim[HoldPattern][f_[a___][___][___][___][___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][f_[a___][___][___][___][___][___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][_[___, f_[a___], ___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][_[___, f_[a___][___], ___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][_[___, f_[a___][___][___], ___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][_[___, f_[a___][___][___][___], ___]]]:=
  HoldPattern@f[a];
extractArgStructureHead[f_, Verbatim[HoldPattern][_[___, f_[a___][___][___][___][___], ___]]]:=
  HoldPattern[f[a]];
extractArgStructureHead[f_, e:Except[_List]]:=e;


extractArgStructureHead~SetAttributes~{Listable, HoldFirst}


(* ::Subsubsection::Closed:: *)
(*reconstructPatterns*)



reconstructPatterns[p_] :=
  Flatten[
    p //. {
      "Optional"[a_] :> Optional[a],
      "Default" -> _.,
      "OptionsPattern" -> OptionsPattern[],
      "Blank" -> _,
      "BlankSequence" -> __,
      "BlankNullSequence" -> ___,
      "Repeated"[\[Infinity]] -> Repeated[_],
      "RepeatedNull"[\[Infinity]] -> RepeatedNull[_],
      "Repeated"[s_] :> Repeated[_, s],
      "RepeatedNull"[s_] :> RepeatedNull[_, s]
      },
    1
    ];


(* ::Subsubsection::Closed:: *)
(*argPatPartLens*)



argPathDispatch=
  Dispatch[
    {
      _Blank -> 1 ;; 1,
      _BlankSequence -> 1 ;; \[Infinity],
      _BlankNullSequence -> 0 ;; \[Infinity],
      Verbatim[Repeated][_] -> 1 ;; \[Infinity],
      Verbatim[RepeatedNull][_] -> 0 ;; \[Infinity],
      Verbatim[Repeated][_, {M_}] :> 1 ;; M,
      Verbatim[RepeatedNull][_, {M_}] :> 0 ;; M,
      (Repeated | RepeatedNull)[_, {M_}] :> ;; M,
      (Repeated | RepeatedNull)[_, {m_, M_}] :> m ;; M,
      _Optional -> 0 ;; 1,
      _Default -> 0 ;; 1,
      _OptionsPattern -> 0 ;; \[Infinity],
      l_List :> iArgPatLens[l],
      _ -> 1 ;; 1
      }
  ];
iArgPatLens[patList_]:=
  Replace[
  patList,
  argPathDispatch,
  {1}
  ]


argPatPartLens[patList_] :=
  Thread[ patList -> iArgPatLens[patList] ];


(* ::Subsubsection::Closed:: *)
(*argPatSimplifyDispatch*)



argPatSimplifyDispatch=
  Dispatch@
    {
      Verbatim[Repeated][_, {1,1}]->_
      }


(* ::Subsubsection::Closed:: *)
(*mergeArgPats*)



mergeArgPats[pats_, returnNum : False | True : False] :=
  Module[
    {
      reppedPats = argPatPartLens /@ pats,
      mlen,
      paddies,
      werkit = True,
      patMaxes,
      patMins,
      patListPatsNums,
      patChoices,
      patNs,
      patCho,
      patListing
      },
    mlen = Max[Length /@ reppedPats];
    paddies = PadRight[#, mlen, _. -> 0 ;; 1] & /@ reppedPats;
    patListing=
    MapThread[
      Function[
        patMins = 
          MinimalBy[{##},  
            If[ListQ@#[[2]], 1, #[[2, 1]]] &
            ];
        patMaxes = 
          MaximalBy[{##}, 
            If[ListQ@#[[2]], 1, #[[2, 2]]]&
            ];
        patChoices = Intersection[patMins, patMaxes];
        patListPatsNums = Length/@Cases[patChoices, {___, _List, ___}];
        patChoices= 
        SortBy[patChoices,
          Replace[
            {
              l_List:>
              Depth[l]*(Max[patListPatsNums] - Length[l]),
              _->0
              }
            ]
          ];
        patNs = 
        {
          If[ListQ@patMins[[1, 1]], 1, patMins[[1, 2, 1]]], 
          If[ListQ@patMaxes[[1, 1]], 1, patMaxes[[1, 2, 2]]]
          };
        patCho =
        If[Length@patChoices > 0,
          SortBy[patChoices,
            Replace[#[[1]],
              {
                _OptionsPattern->
                0,
                _RepeatedNull | _Repeated->
                1,
                _Optional | _Default->
                2,
                _->
                3
                }
              ] &
            ][[1, 1]],
          Replace[ 
            patNs,
            {
              {0, 1} -> _.,
              {1, \[Infinity]} -> __,
              {0, \[Infinity]} -> ___,
              {m_, n_} :> Repeated[_, {m, n}]
              }
            ]
          ];
        If[returnNum, patCho -> patNs, patCho]
        ],
      paddies
      ];
    If[Length@patListing>1,
      ReplaceAll[Most[patListing], _OptionsPattern->___]
      ~Append~
      Last[patListing],
      patListing
      ]/.argPatSimplifyDispatch
    ]


(* ::Subsubsection::Closed:: *)
(*generateArgPatList*)



generateArgPatList[f_, dvs_]:=
  DeleteDuplicates[
    reconstructPatterns /@
      ReplaceAll[
        reducePatterns /@ extractArgStructureHead[f, dvs],
        {
          (HoldPattern[f] | HoldPattern) -> List
          }
        ]
    ];
generateArgPatList~SetAttributes~HoldFirst


(* ::Subsection:: *)
(*SyntaxInfo*)



(* ::Subsubsection::Closed:: *)
(*generateSIArgPat*)



generateSIArgPat[f_] :=
  With[{dvs = Keys@getCodeValues[f, {DownValues, SubValues, UpValues}]},
    mergeArgPats@generateArgPatList[f, dvs]
    ];
generateSIArgPat~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*generateSILocVars*)



generateSILocVars[f_] :=
  With[
    {
      att = Attributes[f], 
      dvs = Keys@getCodeValues[f, {DownValues}]
      },
    Which[
      MemberQ[att, HoldAll],
        {1, Infinity},
      MemberQ[att, HoldRest],
        {2, Infinity},
      MemberQ[att, HoldFirst],
        {1},
      True,
        None
      ]
    ];
generateSILocVars~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*generateSIColEq*)



generateSIColEq[f_] :=
  With[{dvs = Keys@getCodeValues[f, {DownValues}]},
    Replace[{a_, ___} :> a]@
      MaximalBy[
        MinMax@Flatten@Position[#, _Equal, 1] & /@ dvs,
        Apply[Subtract]@*Reverse
        ]
    ];
generateSIColEq~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*generateSIOpNames*)



generateSIOpNames[f_] :=
  ToString[#, InputForm] & /@ Keys@Options[Unevaluated@f];
generateSIOpNames~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*generateSyntaxInformation*)



Options[generateSyntaxInformation] =
  {
    "ArgumentsPattern" -> Automatic,
    "LocalVariables" -> None,
    "ColorEqualSigns" -> None,
    "OptionNames" -> Automatic
    };
Attributes[generateSyntaxInformation] =
  {
    HoldFirst
    };
generateSyntaxInformation[
  f_,
  ops : OptionsPattern[]
  ] :=
  {
    "ArgumentsPattern" ->
    Replace[OptionValue["ArgumentsPattern"],
      Automatic :> generateSIArgPat[f]
      ],
    "LocalVariables" ->
    Replace[OptionValue["LocalVariables"],
      Automatic :> generateSILocVars[f]
      ],
    "ColorEqualSigns" ->
    Replace[OptionValue["LocalVariables"],
      Automatic :> generateSIColEq[f]
      ],
    "OptionNames" ->
    Replace[OptionValue["OptionNames"],
      Automatic :> generateSIOpNames[f]
      ]
    };


(* ::Subsubsection::Closed:: *)
(*AddFunctionSyntaxInformation*)



Options[AddFunctionSyntaxInformation]=
  Options[generateSyntaxInformation];
AddFunctionSyntaxInformation[
  f_Symbol,  
  head:Except[_?OptionQ]:Identity,
  ops:OptionsPattern[]
  ]:=
  Replace[
    generateAutoFunctionInfo[f, ops],
    {
      (Except[_String] -> _) -> Nothing,
      (k_ -> None) :> k -> {}
      },
    {1}
    ];
AddFunctionSyntaxInformation~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*ArgCount*)



(* ::Subsubsection::Closed:: *)
(*generateArgCount*)



generateArgCount[f_] :=
  Module[
    {
      dvs = Keys@getCodeValues[f, {DownValues, SubValues, UpValues}],
      patsNums,
      patsMax,
      patsMin,
      patsTypes,
      doNonOp = False
      },
    dvs=
    extractArgStructureHead[f, dvs];
    patsNums =
    mergeArgPats[generateArgPatList[f, dvs], True];
    patsTypes = patsNums[[All, 1]];
    patsMin =
    Block[{noopnoop = False},
      MapThread[
        If[noopnoop,
          0,
          If[MatchQ[#, _OptionsPattern],
            doNonOp = True;
            noopnoop = True;
            0,
            #2
            ]
          ] &,
        {
          patsTypes,
          patsNums[[All, 2, 1]]
          }
        ]
      ];
    patsMax =
    Block[{noopnoop = False},
      MapThread[
        If[noopnoop,
          0,
          If[MatchQ[#, _OptionsPattern],
            doNonOp = True;
            noopnoop = True;
            0,
            #2
            ]
          ] &,
        {
          patsTypes,
          patsNums[[All, 2, 2]]
          }
        ]
      ];
    {"MinArgs" -> Total[patsMin], "MaxArgs" -> Total[patsMax], 
      "OptionsPattern" -> doNonOp}
    ];
generateArgCount~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*setArgCount*)



setArgCount[
  f_Symbol, 
  minA : _Integer, 
  maxA : _Integer|Infinity, 
  noo : True | False
  ] :=
  With[{wasProt=MemberQ[Attributes[f], Protected]},
    If[wasProt, Unprotect[f]];
    DownValues[f]=
      Cases[DownValues[f], 
        Except[
          Verbatim[HoldPattern][
            HoldPattern[Verbatim[Condition][f[___], (_ArgumentCountQ;False)]]
            ]:>_Failure
          ]
        ];
    SetArgCount[f, {minA, maxA}, noo];
    If[wasProt, Protect[f]];
    ];
setArgCount~SetAttributes~HoldFirst


SetArgCount[
  f_, 
  {minA : _Integer, maxA : _Integer|Infinity}, 
  noo : True | False
  ] :=
  (
    f[argPatLongToNotDupe___] /; (
      ArgumentCountQ[
        f,
        Length@
          If[noo,
            Replace[
              Hold[argPatLongToNotDupe], 
              Hold[argPatLongToNotDupe2___, 
                (_Rule | _RuleDelayed | {(_Rule | _RuleDelayed) ..}) ...
                ] :> Hold[argPatLongToNotDupe2]
              ], 
            Hold[argPatLongToNotDupe]
            ], 
        minA, 
        maxA
        ]; 
      False
      ) := 
    Failure["Bad Definition",
      "If you're seeing this we have a bug; Raise an issue on GitHub"
      ];
    )


(* ::Subsubsection::Closed:: *)
(*AddFunctionArgCount*)



Options[AddFunctionArgCount]=
  Options[generateArgCount]
AddFunctionArgCount[f_Symbol, ops:OptionsPattern[]]:=
  With[{argC=generateArgCount[f, ops]},
    setArgCount[
      f,
      Lookup[argC, "MinArgs"],
      Lookup[argC, "MaxArgs"],
      Lookup[argC, "OptionsPattern"]
      ]
    ];
AddFunctionArgCount~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*Details*)



(* ::Subsubsection::Closed:: *)
(*contextNames*)



contextNames[s_String]:=
  FixedPoint[
    ToExpression[
      Names[s<>"*"],
      StandardForm,
      Function[Null,
        If[
          MatchQ[dgSymValues[#,OwnValues],
            {_:>Verbatim[Condition][_System`Dump`AutoLoad,_]}
            ],
          #
          ],
        HoldFirst
        ]
      ];
    Names[s<>"*"]&,
    None
    ];


(* ::Subsubsection::Closed:: *)
(*relatedFunctionNames*)



relatedFunctionNamesTrimmed[s_]:=
  With[{trimmed=StringTrim[s, "$"]},
        Replace[StringPosition[trimmed,_?LowerCaseQ],{
          {{three_?(GreaterThan[2]),_},___}:>
            StringTake[trimmed, three-2],
          {__}:>
            Replace[
              StringPosition[StringDrop[trimmed,1],
                _?(Not@*LowerCaseQ)],{
              {{two_,_},___}:>
                StringTake[trimmed,two],
              _:>
                If[StringLength[trimmed]>=3,StringTake[trimmed,3],trimmed]
              }],
          _:>If[StringLength[trimmed]>=3,StringTake[trimmed,3],trimmed]
          }]
        ]


relatedFunctionNames[s_String,c:_String|Automatic:Automatic]:=
  With[{
    wordStart=relatedFunctionNamesTrimmed@s,
    cont=
      Replace[c,
        Automatic:>
          ToExpression[s,StandardForm,Context]
        ]
    },
    Select[
      StringTrim[Names[cont<>"*"],cont],
      #!=s&&
      StringMatchQ[StringTrim[#,"$"],
        wordStart~~(""|(_?(Not@*LowerCaseQ)~~___))]&
      ]
    ];
relatedFunctionNames[s_Symbol,c:_String|Automatic:Automatic]:=
  relatedFunctionNames[Evaluate@ToString@Unevaluated[s],
    Replace[c,
      Automatic:>Context[s]
      ]];
relatedFunctionNames~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*novelFunctionOptions*)



$filterOutOps=
  {
    Graphics,Graphics3D,
    Framed,Style,Cell,
    CloudDeploy,Button,
    Pane,Panel,ActionMenu,
    PopupMenu,Column,
    Row,Grid,CreateDocument,
    Notebook,Plot,Plot3D,
    DialogInput,MeshRegion
    };


novelFunctionOptions[sym_,others_:$filterOutOps]:=
  With[{
    o=Options@Unevaluated[sym],
    tests=
      Replace[First/@Options@#,
        s_Symbol:>
          SymbolName@s,
        1]&/@others},
    With[{selected=
      Flatten@
        Select[tests,
          With[{k=
            Replace[Keys@o,
              s_Symbol:>
                SymbolName@s,
              1]},
              Complement[#,k]=={}&
            ]
          ]
      },
      DeleteCases[o,
        _[_?(MemberQ[selected,Replace[#,_Symbol:>SymbolName[#]]]&),_]
      ]
    ]
  ];
novelFunctionOptions[s:Except[_Symbol]?(MatchQ[#,_Symbol]&)]:=
  novelFunctionOptions@Evaluate@s;
novelFunctionOptions~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*containedFunctionOptions*)



containedFunctionOptions[sym_,others_:$filterOutOps]:=
  With[{o=Options@Unevaluated[sym]},
    Select[others,
      With[{k=
        Replace[Keys@o,
          s_Symbol:>
            SymbolName@s,
          1]},
          With[{ops=
            Replace[First/@Options@#,
              s_Symbol:>
                SymbolName@s,
              1]
            },
            Complement[ops,k]=={}
            ]&
        ]
      ]
    ];
containedFunctionOptions[s:Except[_Symbol]?(MatchQ[#,_Symbol]&)]:=
  containedFunctionOptions@Evaluate@s;
containedFunctionOptions~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*generateDetails*)



(* ::Text:: *)
(*
	Should find a nice way to have some parts of this done with boxes... (or be box compatible)
*)



$generateDetailsMap=
  <|
    "has"->"has",
    "hasInt"->"has an internal",
    "ovs"->"immediate value",
    "dvs"->"call",
    "svs"->"SubValues",
    "uvs"->"UpValues",
    "ops"->"Options",
    "msg"->"Messages",
    "attrs"->"Attributes"
    |>


generateDetails[sym_Symbol]:=
  Module[{
    $=$generateDetailsMap,
    ovs=getCodeValues[sym,OwnValues],
    dvs=getCodeValues[sym,DownValues],
    uvs=getCodeValues[sym,UpValues],
    svs=getCodeValues[sym,SubValues],
    fvs=getCodeValues[sym,FormatValues],
    hovs=System`Private`HasOwnCodeQ[sym],
    hdvs=System`Private`HasDownCodeQ[sym],
    huvs=System`Private`HasUpCodeQ[sym],
    hsvs=System`Private`HasSubCodeQ[sym],
    hfvs=System`Private`HasSubCodeQ[sym],
    ops,
    conts,
    attrs=Flatten@{Attributes[sym]},
    msgs=
      DeleteCases[Messages[sym],
        Verbatim[HoldPattern][
          HoldPattern@MessageName[_,"usage"|"usages"]
          ]:>_
        ],
    sname=SymbolName[Unevaluated[sym]]
    },
    ops=If[Length@ovs==0,novelFunctionOptions[sym],{}];
    conts=If[Length@ovs==0,containedFunctionOptions[sym],{}];
    {
      Replace[Length@ovs,{
        0->Nothing,
        1->{sname, $["has"], "an", $["ovs"]},
        n_:>{sname, $["has"], n, $["ovs"]<>"s"}
        }],
      If[hovs,
        {sname, $["hasInt"], $["ovs"]},
        Nothing
        ],
      If[Length@dvs>0,
        {sname, $@"has", Length@dvs, $["dvs"], "pattern"<>If[Length@dvs>1,"s",""]},
        Nothing
        ],
      If[hdvs,
        {sname, $@"hasInt", $["dvs"], "pattern"},
        Nothing
        ],
      If[Length@uvs>0,
        {sname, $@"has", Length@dvs, $["uvs"], "pattern"<>If[Length@dvs>1,"s",""]},
        Nothing
        ],
      If[hdvs,
        {sname, $@"hasInt", $["uvs"], "pattern"},
        Nothing
        ],
      If[Length@svs>0,
        {sname, $@"has", Length@dvs, $["svs"], "pattern"<>If[Length@dvs>1,"s",""]},
        Nothing
        ],
      If[hsvs,
        {sname, $@"hasInt", $["svs"], "pattern"},
        Nothing
        ],
      If[Length@ops>0,
        Join[
          {sname, $@"has", "the following", $@"ops"},
          Map[
            {
              ToString[#[[1]], InputForm],
              Extract[#,2,
                Function[Null, ToString[Unevaluated[#], InputForm], HoldFirst]
                ]
              }&,
            ops
            ]
          ],
        Nothing
        ],
      If[Length@conts>0,
        Join[
          {sname, "can take", $@"ops", "from the following"},
          Map[
            {ToString[#, InputForm]}&,
            ops
            ]
          ],
        Nothing
        ],
      If[Length@msgs>0,
        {
          {sname, $@"has", "the following", $@"msg"},
          Map[
            {
              Replace[First@#,
                Verbatim[HoldPattern][m_MessageName]:>
                  ToString[Unevaluated[m], InputForm]
                ],
                Last@#
              }&,
            msgs
            ]
          },
        Nothing
        ],
      If[Length@attrs>0,
        {
          {sname, "has the following", $@"attrs"},
          Map[
            {ToString[#, InputForm]}&,
            attrs
            ]
          },
        Nothing
        ],
      If[Length@fvs>0||hfvs,
        {sname, "is a formatted symbol"},
        Nothing
        ]
      }
    ];
generateDetails~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*Examples*)



(* ::Text:: *)
(*
	mostly still need to do this...
*)



(* ::Subsubsection::Closed:: *)
(*generateExamples*)



generateExamples[sym_,defer:True|False:False]:=
  With[
    {
    vals=
      Map[First,
        Join@@
          Map[codeValues[sym,#]&, {UpValues,DownValues,SubValues}]
        ]},
    Flatten@{
      With[{c=Context[sym]},
        If[MemberQ[$ContextPath,c]&&Not@MatchQ[c,"Global`"|"System`"],
          {
            Cell["Load "<>StringTrim[c,"`"]<>":","ExampleText"],
            If[!defer,
              ToExpression@RowBox@{"Needs","[","\""<>c<>"\"","]"}
              ];
            Cell[BoxData@RowBox@{"Needs","[","\""<>c<>"\"","]"},
              "ExamplesInput",
              InitializationCell->True
              ]
            },
          Nothing
          ]
        ],
      Flatten@Riffle[
        Cell[TextData@{"From ",
          inlineRefBox@Replace[usagePatternReplace@#,
              Verbatim[HoldPattern][e_]:>{
                toSafeBoxes[Unevaluated[e],StandardForm]
              }],":"},
          "ExampleText"
          ]&/@vals,
        If[defer,
          Cell[
            BoxData@
              Replace[#,{
                Verbatim[HoldPattern][e_]:>
                  toSafeBoxes[Unevaluated@e,StandardForm]
                }],
            "ExamplesInput"
            ],
          Cell[CellGroupData[{
            Cell[
              BoxData@
                Replace[#,{
                  Verbatim[HoldPattern][e_]:>
                    toSafeBoxes[Unevaluated@e,StandardForm]
                  }],
              "ExamplesInput"
              ],
            Cell[
              BoxData@
                Replace[#,{
                  Verbatim[HoldPattern][e_]:>
                    ToBoxes[e]
                  }],
              "ExamplesOutput"
              ]
            },Open]]
          ]&/@callPatternReplace[vals]
          ],
      AutoGenerateOptionExamples[sym,defer],
      Cell[CellGroupData[{
        Cell["Definitions","ExampleSection"],
        Cell["Examine all definitions:","ExampleText"],
        Cell[
          BoxData@
            RowBox@{
              "GeneralUtilities`PrintDefinitionsLocal",
              "[",
              Block[{$ContextPath},ToString[Unevaluated@sym,InputForm]],
              "]"
              },
          "ExamplesInput"
          ]
        }]]
      }
    ];
generateExamples[
  e:Except[_Symbol]?(MatchQ[#,_Symbol]&),
  defer:True|False:False]:=
  generateExamples[System`Evaluate@e,defer];
generateExamples~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*AutoGenerateOptionExamples*)



generateOptionExamples[sym_Symbol,defer:True|False:False]:=
  With[{
    u=
      FirstCase[First/@dgSymValues[sym,DownValues],
        Verbatim[HoldPattern][
          _[
            ___,
            Verbatim[OptionsPattern][]|
            Verbatim[Pattern][_,Verbatim[OptionsPattern][]],
            ___
            ]
          ],
        HoldPattern[sym[OptionsPattern[]]]
        ],
    ops=If[Length@dgSymValues[sym,OwnValues]==0,novelFunctionOptions[sym],{}]
    },
    With[{usages=
      Map[
        First@#->
          callPatternReplace[u,
            Verbatim[OptionsPattern][]->#
            ]&,
        ops
        ]
      },
      If[Length@usages>0,
        Cell[CellGroupData[Flatten@{
          Cell["Options","ExampleSection"],
          Map[
            Cell@
              CellGroupData[Flatten@{
                Cell[ToString@First@#,"ExampleSubsection"],
                If[defer,
                  Cell[
                    BoxData@
                      Replace[Last@#,{
                        Verbatim[HoldPattern][e_]:>
                          toSafeBoxes[Unevaluated@e,StandardForm]
                        }],
                    "ExamplesInput"
                    ],
                  With[{
                    res=
                      Replace[Last@#,{
                        Verbatim[HoldPattern][e_]:>
                          e
                        }]
                    },
                    Cell[CellGroupData[{
                      Cell[
                        BoxData@ToBoxes@
                          Replace[Last@#,{
                            Verbatim[HoldPattern][e_]:>
                              toSafeBoxes[Unevaluated@e,StandardForm]
                            }],
                        "ExamplesInput"
                        ],
                      Cell[
                        BoxData@ToBoxes@res,
                        "ExamplesOutput"
                        ]
                      },Open]]
                    ]
                  ]
                },
                Closed]&,
            usages
            ]
          },Closed]
          ],
        Nothing
        ]
      ]
    ];
generateOptionExamples[e:Except[_Symbol]?(MatchQ[#,_Symbol]&),
  defer:True|False:False]:=
  generateOptionExamples[System`Evaluate@e,defer];
generateOptionExamples~SetAttributes~HoldFirst


(* ::Subsection:: *)
(*AutoFunctionInfo*)



(* ::Subsubsection::Closed:: *)
(*generateAutoFunctionInfo*)



Options[generateAutoFunctionInfo] =
  {
    "SyntaxInformation" -> {},
    "Autocompletions" -> {},
    "UsageMessages" -> {},
    "UsageTemplate" -> Automatic,
    "ArgCount" -> Automatic,
    "Details"->Automatic,
    "Examples"->Automatic
    };
generateAutoFunctionInfo[
  f_Symbol,
  keys_:{"UsageMessages", "SyntaxInformation", "ArgCount"},
  ops : OptionsPattern[]
  ] :=
  KeyValueMap[Rule, KeyTake[#, keys]]&@
    <|
      "UsageMessages" :>
        generateSymbolUsage[
          f,
          Cases[
            Flatten@List[OptionsPattern["UsageMessages"]],
            _Rule | _RuleDelayed
            ],
          OptionValue["UsageTemplate"]
          ],
      "SyntaxInformation" :>
        generateSyntaxInformation[f,
          OptionValue["SyntaxInformation"]
          ],
      "Autocompletions" :>
        generateAutocompletions[f,
          OptionValue["Autocompletions"]
          ],
      "ArgCount" :>
        Replace[OptionValue@"ArgCount",
          Except[
            KeyValuePattern[
              {"MinArgs" -> _Integer, "MaxArgs" -> _Integer | Infinity, 
                "OptionsPattern" -> (True | False)}
              ]
            ] :> generateArgCount[f]
          ],
      "Details":>
        Replace[OptionValue@"Details",
          Except[{__List}]:> generateDetails[f]
          ]
      |>;
generateAutoFunctionInfo~SetAttributes~HoldFirst


Options[GenerateFunctionInfo]=
  {
    "Keys"->{"UsageMessages", "Details", "SyntaxInformation", "ArgCount"},
    "Defaults"->{}
    };
GenerateFunctionInfo[s_Symbol,
  ops:OptionsPattern[]
  ]:=
  Replace[
    generateAutoFunctionInfo[s, OptionValue["Keys"], OptionValue["Defaults"]],
    Except[_?OptionQ]->$Failed
    ];
GenerateFunctionInfo~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*AutoFunctionInfo*)



AutoFunctionInfo//Clear


$AutoFunctionInfoBatchCall=False;


Options[AutoFunctionInfo] =
  {
    "SyntaxInformation" -> {},
    "Autocompletions" -> {},
    "UsageMessages" -> {},
    "ArgCount"->{},
    "SetInfo" -> False,
    "GatherInfo" -> True,
    "ReturnInfo" -> False,
    "DumpFile"->None
    };
AutoFunctionInfo[f_Symbol, o : OptionsPattern[]] :=
 Module[
    {
      sinfBase =
        If[OptionValue["GatherInfo"] =!= False,
          generateAutoFunctionInfo[f, 
            FilterRules[{o}, Options[generateAutoFunctionInfo]]], 
          Flatten[{o, Options[AutoFunctionInfo]}]
          ],
      sops = 
        FilterRules[{o}, Options[generateAutoFunctionInfo]],
      as = {},
      si,
      um,
      ac,
      argX,
      set = 
        TrueQ@OptionValue["SetInfo"],
      dumpFile =
        OptionValue["DumpFile"],
      dump,
      dumpExpr,
      retInfo,
      info
      },
      si =
        Replace[
          Replace[Lookup[sinfBase, "SyntaxInformation"],
            Except[{(_String -> _) ..}] :>
            Lookup[as, "SyntaxInformation",
              Lookup[Set[as, generateAutoFunctionInfo[f, sops]], 
                "SyntaxInformation"]
              ]
            ],
          {
            (Except[_String] -> _) -> Nothing,
            (k_ -> None) :> k -> {}
            },
          {1}
          ];
    um =
      Replace[Lookup[sinfBase, "UsageMessages"],
        Except[{__String}] :>
        Lookup[as, "UsageMessages",
          Lookup[Set[as, generateAutoFunctionInfo[f, sops]], 
            "UsageMessages"]
          ]
        ];
    um = 
      StringRiffle[um, "\n"];
    ac =
      Replace[Lookup[sinfBase, "Autocompletions"],
        Except[_List] :>
        Lookup[as, "Autocompletions",
          Lookup[Set[as, generateAutoFunctionInfo[f, sops]], 
            "Autocompletions"]
          ]
        ];
    argX =
      Association@
        Replace[Lookup[sinfBase, "ArgCount"],
          Except[{"MinArgs" -> _Integer, 
              "MaxArgs" -> _Integer | \[Infinity], 
              "OptionsPattern" -> True | False}] :>
          Lookup[as, "ArgCount",
            Lookup[Set[as, generateAutoFunctionInfo[f, sops]], "ArgCount"]
            ]
          ];
    retInfo=TrueQ@OptionValue@"ReturnInfo";
    If[retInfo,
      info=
        {
          "SyntaxInformation" -> si,
          "Autocompletions" -> ac,
          "UsageMessage" -> um,
          "ArgCount"->Normal@argX
          }
      ];
    If[set,
      SyntaxInformation[Unevaluated@f] = si;
      If[StringLength@um > 0, f::usage = um];
      If[Length@ac > 0, AddFunctionAutocompletions[f, ac]];
      setArgCount[f, argX["MinArgs"], argX["MaxArgs"], argX["OptionsPattern"]]
      ];
    dump=MatchQ[dumpFile, _String?(Not@*StringMatchQ[Whitespace|""])|_File];
    If[(Not@set&&Not@retInfo)||dump,
      (* dump to held expression for writing to file *)
      dumpExpr=
        With[
          {
            si2 = si,
            um2 = um,
            acpat = AutocompletionPreCompile[ac],
            minA = argX["MinArgs"],
            maxA = argX["MaxArgs"],
            noo = argX["OptionsPattern"]
            },
          Hold[
            {
              "FunctionInfo",
              HoldComplete[f],
              MapThread[#2[f, Sequence@@#[[2]]]&,
                {
                  {
                    "SyntaxInfo"->{si2},
                    "UsageMessages"->{um2},
                    "Autocompletions"->{acpat},
                    "ArgCounts"->{minA, maxA, noo}
                    },
                  {
                    Function[Null,
                      SyntaxInformation[Unevaluated[#]] = #2,
                      HoldFirst
                      ],
                    Function[Null,
                      If[StringLength@#2 > 0, Set[#::usage, #2]],
                      HoldFirst
                      ],
                    Function[Null,
                      If[Length@#2>0,
                        If[$Notebooks &&
                          Internal`CachedSystemInformation[
                            "FrontEnd", "VersionNumber"] > 10.0,
                          FE`Evaluate[
                            FEPrivate`AddSpecialArgCompletion[
                              ToString[Unevaluated[#]] -> #2]
                            ]
                          ],
                        Null
                        ],
                      HoldFirst
                      ],
                    Function[Null,
                      If[#3>0&&(#3=!=\[Infinity]&&#2==0),
                        SetDelayed[
                          #[argPatLongToNotDupe___],
                          (
                            1 /; (ArgumentCountQ[#,
                                Length@
                                If[#4,
                                  Replace[Hold[argPatLongToNotDupe], 
                                    Hold[argPatLongToNotDupe2___, 
                                      (_Rule | _RuleDelayed | {(_Rule | _RuleDelayed) ..}) ...
                                      ] :> Hold[argPatLongToNotDupe2]
                                    ], 
                                  Hold[argPatLongToNotDupe]
                                  ], #2, #3]; False)
                              )
                            ]
                        ],
                      HoldFirst
                      ]
                    }
                  }]
                };
            ]
        ]
      ];
    If[dump&&Not@TrueQ[$AutoFunctionInfoBatchCall], 
      Replace[dumpExpr,
        Hold[{_, _, d_};]:>
          Block[{$ContextPath={"System`"}, $Context="System`"},
            Put[Unevaluated[d], dumpFile]
            ]
        ];
      ];
    Which[
      dump&&TrueQ@$AutoFunctionInfoBatchCall,
        dumpExpr,
      retInfo,
        info,
      set,
        Null,
      True,
        dumpExpr
      ]
    ]


AutoFunctionInfo[dymbshyt:{s__Symbol}, ops:OptionsPattern[]]:=
  Block[
    {$AutoFunctionInfoBatchCall=True},
  Module[
    {
      comp=
        List@@
          Map[
            Function[Null, 
              AutoFunctionInfo[#, ops], 
              HoldFirst
              ], 
            Hold[s]
            ],
      dumpFile=
        OptionValue["DumpFile"],
      dump=
        MatchQ[OptionValue["DumpFile"], _String?(Not@*StringMatchQ[Whitespace|""])|_File],
      retInfo=
        TrueQ@OptionValue["ReturnInfo"],
      compiledComp
      },
      If[MatchQ[comp, {__Hold}],
        compiledComp=
          With[
            {
              pats=
                Replace[comp, 
                  Hold[
                    {
                      _,
                      HoldComplete[f_],
                      MapThread[_,
                        {
                          data_,
                          _
                          }
                        ]
                      };
                    ]:>
                      If[Values@data==
                          {
                            {
                              {
                                "ArgumentsPattern"->{},"LocalVariables"->{},
                                "ColorEqualSigns"->{},"OptionNames"->{}
                                }
                              },
                            {""},
                            {{}},
                            {0,0,False}
                            }, 
                        Nothing,
                        Hold[f]->Values@data
                        ],
                  1
                  ],
                fns=
                  Replace[comp[[1]],
                    Hold[
                      {
                        _,
                        _,
                        MapThread[_,
                          {
                            _,
                            fns_
                            }
                          ]
                        };
                      ]:>fns
                    ]
                },
            Hold[
              {
                "FunctionInfo",
                With[
                  {
                      fs=fns,
                      fpats=pats
                      },
                  Replace[fpats,
                    (Hold[func_]->vals_):>
                      MapThread[
                        #2[func, Sequence@@#]&,
                        {
                          vals,
                          fs
                          }
                        ],
                    1
                    ]
                  ]
                };
              ]
            ]
          ];
      If[dump,
        Replace[compiledComp,
          Hold[{_, d_};]:>
            Block[{$ContextPath={"System`"}, $Context="System`"},
              Put[Unevaluated[d], dumpFile]
              ]
          ];
        ];
      Which[
        retInfo,
          Thread[Thread[Hold[{s}]]->comp],
        TrueQ@OptionValue["SetInfo"],
          Null,
        True,
          compiledComp
        ]
      ]
    ];


AutoFunctionInfo[
  conto:Except[_Symbol, _?StringPattern`StringPatternQ],
  ops:OptionsPattern[]
  ]:=
  Replace[
    ToExpression[
      Names[If[StringQ@conto&&StringEndsQ[conto, "`"], conto<>"*", conto]], 
      StandardForm, 
      Hold
      ],
    {
      l:{__Hold}:>
        Apply[
          Function[Null,
            AutoFunctionInfo[#, ops],
            HoldFirst
            ],
          Thread[l, Hold]
          ],
      {}->Hold[{}]
      }
    ];


AutoFunctionInfo[
  ughwhy:{conto:Except[_Symbol, _?StringPattern`StringPatternQ]..},
  ops:OptionsPattern[]
  ]:=
  AutoFunctionInfo[Alternatives[conto], ops];


AutoFunctionInfo[
  e:Except[{__Symbol}|_String|{__String}|_Symbol|_Pattern],
  ops:OptionsPattern[]
  ]/;!TrueQ@$recursionProtectMe:=
  Block[{$recursionProtectMe=True},
    AutoFunctionInfo[Evaluate@e, ops]
    ];


AutoFunctionInfo~SetAttributes~HoldFirst


End[];



