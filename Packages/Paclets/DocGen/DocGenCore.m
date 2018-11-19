(* ::Package:: *)



(* ::Subsubsection::Closed:: *)
(*General*)



DocGenSettingsLookup::usage=
  "Used to look up things in the $DocGenSettings";
$DocGenActive::usage=
  "The thing actively being documented";
$DocGenDirectory::usage=
  "The build directory for DocGen";
$DocGenTmpDirectory::usage=
  "The build directory for DocGen";
$DocGenWebDocsDirectory::usage=
  "";
$DocGenWebDocsTmpDirectory::usage=
  "";
$DocGenLine::usage=
  "The $Line for writing docs";
$DocGenColoring::usage=
  "The coloring table for auto-generated documentation";
$DocGenLinkBase::usage=
  "The ref link base for docs";


DocLinkBase::usage=
  "Wrapper function for $DocGenLinkBase";


$DocGenFooter::usage=
  "The default footer to use when making doc pages";


(* ::Subsubsection::Closed:: *)
(*Main*)



DocGenIndexDocumentation::usage=
  "Generates an index for documentation located in a directory";


DocGenGenerateDocumentation::usage=
  "Generates and documentation and saves it in a basic documentation paclet";


(*
	DocAddUsage::usage=
		"Adds a usage to the usages for a symbol";
	*)


(* ::Subsubsection::Closed:: *)
(*Utilities*)



DocMetadata::usage="";


Begin["`Private`"];


$DocGenVersionNumber=$VersionNumber;


(* ::Subsection:: *)
(*Config*)



(* ::Subsubsection::Closed:: *)
(*DocGenSettingsLookup*)



If[!TrueQ@$docGenInitialized,
  $DocGenBuildPermanent=
    False;
  If[FileExistsQ@PackageFilePath["Private", "DocGenConfig.wl"],
    Import@PackageFilePath["Private", "DocGenConfig.wl"]
    ];
  $docGenInitialized=False
  ];


DocGenSettingsLookup[key_]:=
  Lookup[
    Lookup[
      $DocGenSettings, 
      Replace[s_String:>StringTrim[FileBaseName[s], "Documentation_"]]@
        $DocGenSettings[Default, "CurrentPaclet"], 
      <||>
      ],
    key,
    Lookup[$DocGenSettings[Default], key]
    ]


(* ::Subsubsection::Closed:: *)
(*$DocGenRootDirectory*)



$DocGenRootDirectory:=  
  If[TrueQ@DocGenSettingsLookup["BuildPermanent"],
    DocGenSettingsLookup["RootDirectory"],
    DocGenSettingsLookup["TemporaryDirectory"]
    ];


(* ::Subsubsection::Closed:: *)
(*$DocGenDirectory*)



If[!StringQ@$DocGenDirectory,
  $DocGenDirectory:=  
    FileNameJoin@{
      $DocGenRootDirectory,
      DocGenSettingsLookup["PacletsExtension"]
      };
  If[DirectoryQ@$DocGenDirectory,
    PacletManager`PacletDirectoryAdd[$DocGenDirectory]
    ];
  ]


(* ::Subsubsection::Closed:: *)
(*$DocGenTmpDirectory*)



If[!StringQ@$DocGenTmpDirectory,
  $DocGenTmpDirectory:=  
    FileNameJoin@{
      DocGenSettingsLookup["TemporaryDirectory"],
      DocGenSettingsLookup["PacletsExtension"]
      };
  ]


(* ::Subsubsection::Closed:: *)
(*$DocGenWebDocsDirectory*)



If[!StringQ@$DocGenWebDocsDirectory,
  $DocGenWebDocsDirectory:=
    FileNameJoin@{
      $DocGenRootDirectory,
      DocGenSettingsLookup["WebExtension"]
      };
  ]


(* ::Subsubsection::Closed:: *)
(*$DocGenWebDocsTmpDirectory*)



If[!StringQ@$DocGenWebDocsTmpDirectory,
  $DocGenWebDocsTmpDirectory:=
    FileNameJoin@{
      DocGenSettingsLookup["TemporaryDirectory"],
      DocGenSettingsLookup["WebExtension"]
      };
  ]


(* ::Subsection:: *)
(*Utils*)



If[!IntegerQ@$DocGenLine, $DocGenLine=0];


(* ::Subsubsection::Closed:: *)
(*docGenBlock*)



$docGen="DocGen`Private`";
docGenBlock[cmd_]:=(
  Begin[$docGen];
  CheckAbort[(If[$Context==$docGen,End[]];#)&@cmd,
    If[$Context==$docGen,End[]]
    ]
  );
docGenBlock~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*$DocGenActive*)



findPacletDirectory[f_String]:=
  With[
    {
      d=
        NestWhile[
          DirectoryName,
          ExpandFileName@f,
          FileNameDepth[#]>0&&
            Not@FileExistsQ[FileNameJoin@{#, "PacletInfo.m"}]&
          ]
      },
    If[Not@FileExistsQ[FileNameJoin@{d, "PacletInfo.m"}],
      $Failed,
      d
      ]
    ];
  findPacletDirectory[___]:=$Failed


If[Length@OwnValues@$DocGenActive==0,
  $DocGenActive:=
    Replace[
      s_String?(PacletExecute["InstalledQ"]):>
        Lookup[
          Lookup[
            PacletExecute["Lookup", s, "Extensions", <||>],
            "Documentation",
            <||>
            ],
          "LinkBase",
          StringTrim[FileBaseName[s], "Documentation_"]
          ]
      ]@
    Replace[DocGenSettingsLookup["CurrentPaclet"],
      Except[_String]:>
        Replace[findPacletDirectory@Quiet@NotebookFileName[],
          {
            $Failed->"System"
            }
          ]
      ];
  $DocGenActive/:
    HoldPattern[Set[$DocGenActive,v_]]:=
      Set[$DocGenSettings[Default, "CurrentPaclet"], v];
  $DocGenActive/:
    HoldPattern[SetDelayed[$DocGenActive,v_]]:=
      SetDelayed[$DocGenSettings[Default, "CurrentPaclet"], v];
  $DocGenActive/:
    HoldPattern[Unset[$DocGenActive]]:=
      $DocGenSettings[Default, "CurrentPaclet"]=None;
  ];


(* ::Subsubsection::Closed:: *)
(*DocLinkBase*)



If[MatchQ[$DocGenLinkBase,Except[{__Rule}]],
  $DocGenLinkBase:=
    DocGenSettingsLookup["LinkBase"]
  ];


DocLinkBase[s_String]:=
  StringJoin@Most@
    StringSplit[
      Which[
        StringContainsQ[s,"`"],
          s,
        StringContainsQ[s,"\""],
          "Global`"<>s,
        True,
          ToExpression[s,StandardForm,
            GeneralUtilities`HoldFunction[
              Replace[Unevaluated[#],{
                sym_Symbol:>
                  Context[sym]<>"`bloobybloop",
                HoldPattern[MessageName[msgHead_,msgName_]]:>
                  Context[msgHead]<>"`bloobybloop",
                e_:>(
                  "System"
                  )
                }]
              ]
            ]
        ],
      "`"]/.
      Append[Replace[$DocGenLinkBase,Except[_List]:>{}],
        a_:>
          With[{app=Replace[a,"Global"|"DocGenPrivate":>$DocGenActive]},
            With[{pac=PacletManager`PacletFind[app]},
              If[Length[pac]>0,
                Replace[
                  PacletInfoAssociation[pac[[1]]]["Documentation","LinkBase"],{
                  Except[_String]->app
                  }],
                app
                ]
              ]
            ]
        ];
DocLinkBase[s_Symbol]:=
  DocLinkBase@Context@s;
DocLinkBase[HoldPattern[MessageName[msgName_,_]]]:=
  DocLinkBase[msgName];
DocLinkBase[e:Except[_Symbol|_String]]:=
  DocLinkBase@Evaluate[e];
DocLinkBase~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*docPatternNames*)



docPatternNames[s:{__String}]:=
  Flatten@Map[
    Which[
      StringEndsQ[#, "`"],
        Names[#<>"*"],
      Not@SyntaxQ[#],
        Names[#],
      True,
        #
      ]&,
    s
    ]


(* ::Subsubsection::Closed:: *)
(*docSymStringPat*)



docSymStringPat=
  StringMatchQ[
    ("$"|"`"|LetterCharacter)~~
      (("$"|"`"|WordCharacter)...)];


(* ::Subsubsection::Closed:: *)
(*docItalStringPat*)



docItalStringPat=
  StringMatchQ[("$"|"`"|WordCharacter)..~~(Whitespace|"")];


(* ::Subsubsection::Closed:: *)
(*dgQuietContext*)



dgQuietContext[s_]:=
  Quiet[Context[s],Context::ssle];
dgQuietContext~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*dgQuietSymbolName*)



dgQuietSymbolName[s_]:=
  Quiet[SymbolName@Unevaluated[s],SymbolName::sym];
dgQuietSymbolName~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*dgSymValues*)



dgSymValues[s_,f_]:=
  Quiet[
    Replace[f[s],
      Except[_List]->{}
      ],
    General::readp];
dgSymValues~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*makeRefTest*)



makeRefOverrides=
  {
    
    };


makeRefTest=(
  MemberQ[makeRefOverrides,#]||(
    docSymStringPat[#]&&
      Replace[
        ToExpression[#, StandardForm, Hold],
        Hold[s_]:>(
          MatchQ[
            dgQuietContext[s],
            "System`"|"Internal`"|"System`Private`"
            ]||
          Not@
            MatchQ[
              dgQuietContext[s],
              $Context(*|"Global`"*)
              ]&&(
            GeneralUtilities`HasDefinitionsQ[#]||
            System`Private`HasAnyCodesQ[s]||
            Length@Messages[s]>0||
            Length@DeleteCases[Attributes[#],Temporary]>0
            )
          )]
      )
    )&;


(* ::Subsubsection::Closed:: *)
(*inlineRefBox*)



inlineRefBox[b_]:=
  Cell[BoxData[
    FormBox[If[ListQ@b,RowBox@b,b], "InlineRef"]],
    FormatType->"InlineRef"]


(* ::Subsubsection::Closed:: *)
(*holdPatternStrippedBoxes*)



holdPatternStrippedBoxes[pattern_]:=
  Replace[Unevaluated[pattern],{
    Verbatim[HoldPattern][e_]:>
      holdPatternStrippedBoxes[e],
    e_:>
      ToBoxes@Unevaluated[e]
    }];
holdPatternStrippedBoxes~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*pacletLinkBuild*)



pacletLinkBuild//Clear;


pacletLinkBuild[s_,context_,type_]/;$pacletBuildLink:=
  URLDecode@
    URLBuild[<|
      "Scheme"->"paclet",
      "Path"->
        Flatten@{
          Replace[context,"System"->Nothing],
          Replace[ToLowerCase@type,{
            f:"format"|"message":>{"ref",f},
            Except["guide"|"tutorial"]->"ref"
            }],
          StringReplace[
            StringSplit[StringSplit[s,"`"]//Last,"::"],
            Except["$"|WordCharacter]->""
            ]
          }
      |>];
pacletLinkBuild[s_,type_]/;$pacletBuildLink:=
  With[{base=
    Replace[s,{
      Except[_String]:>
        $DocGenActive
      }]},
    pacletLinkBuild[s,
      If[MatchQ[type,"ref"|"format"|"message"|{"ref",___}],
        DocLinkBase@base,
        Replace[$DocGenActive,
          Except[_String]:>"System"
          ]
        ],
      type
      ]
    ];
pacletLinkBuild[s_]/;$pacletBuildLink:=
  Which[
    StringContainsQ[s,"::"],
      pacletLinkBuild[s,"message"],
    StringContainsQ[s,"\""],
      pacletLinkBuild[s,"format"],
    True,
      pacletLinkBuild[s,"ref"]
    ];
pacletLinkBuild[s_,e___]:=
  Which[
    MatchQ[s,_String?(StringMatchQ["paclet:*"])],
      s,
    Length@
      DeleteCases[""|_String?(StringMatchQ[Whitespace])]@
      URLParse[s,"Path"]>1,
      URLDecode@
        URLBuild@Prepend[URLParse[s],"Scheme"->"paclet"],
    True,
      Block[{$pacletBuildLink=True},
        pacletLinkBuild[s,e]
        ]
    ];


(* ::Subsubsection::Closed:: *)
(*$DocGenColoring*)



If[MatchQ[$DocGenColoring,{Except[_Rule]..}|Except[_List]],
  $DocGenColoring:=
    DocGenSettingsLookup["NameColoring"];
  ];


(* ::Subsubsection::Closed:: *)
(*$DocGenLinkStyle*)



If[MatchQ[$DocGenLinkStyle,{Except[_Rule]..}|Except[_List]],
  $DocGenLinkStyle:=
    DocGenSettingsLookup["LinkStyle"]
  ];


(* ::Subsubsection::Closed:: *)
(*docSymType*)



docSymType[sym_Symbol]:=
  Replace[
    StringTrim@
      StringReplace[
        Context@sym,
        {
          "`"->" ",
          Except[WordCharacter|"$"]->""
          }
        ],
    {
      "System"->
        "BUILT-IN SYMBOL"
      }
    ];
docSymType~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*docTypeColor*)



docTypeColor[s_]:=
  s/.Append[$DocGenColoring, _->Gray]


(* ::Subsubsection::Closed:: *)
(*docLinkType*)



docLinkType[sym_Symbol]:=
  Replace[DocLinkBase[sym],
    Nothing->"System"
    ]/.
    Append[$DocGenLinkStyle,
      _->"PackageLink"];
docLinkType~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*docArrow*)



docArrow=
  Cell@
    BoxData@
      GraphicsBox[
        {
          GrayLevel[0.66667],
          Thickness[0.13],
          LineBox[{{-1.8,0.5},{0,0},{1.8,0.5}}]
          }, 
        AspectRatio -> 1,
        ImageSize -> 20, 
        PlotRange -> {{-3, 4}, {-1, 1}}
        ];


(* ::Subsubsection::Closed:: *)
(*anchorBarActionMenu*)



anchorBarActionMenu[title_,ops_,style_]:=
  Cell[
    BoxData@
    TagBox[
      ActionMenuBox[
        FrameBox[
          Cell@TextData@{title," ",docArrow},
          StripOnInput->False
          ],
        ops,
        Appearance->None,
        MenuAppearance->Automatic,
        BaseStyle->"AnchorBarActionMenu",
        MenuStyle->style
        ],
      MouseAppearanceTag["LinkHand"]
      ],
    LineSpacing->{1.4, 0}
    ]


(* ::Subsubsection::Closed:: *)
(*anchorBarPacletCell*)



With[{spacerboxes=ToBoxes@Spacer[8]},
  anchorBarPacletCell[string_,bg_]:=
    DynamicBox[
      If[$VersionNumber<11.1,
        Cell[string,
          "PacletNameCell",
          TextAlignment->Center
          ],
        ItemBox[
          Cell[
            BoxData@
              RowBox@{
                spacerboxes,
                Cell[
                  string,
                  "PacletNameCell",
                  TextAlignment->Center
                  ],
                spacerboxes
                }
            ],
          Background->bg,
          ItemSize->Full
          ]
        ],
      UpdateInterval->Infinity
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*anchorBarCell*)



anchorBarCell[pacletArgs:{_,_},menus___List]:=
  Cell[
    BoxData@
      GridBox[{{
        GridBox[{{
          anchorBarPacletCell@@pacletArgs,
          ""
          }},
          GridBoxAlignment->{"Rows" -> {{Center}}},
          GridBoxItemSize->
            {
              "Columns" -> 
                {Full, Scaled[0.02]},
              "Rows" -> {{2.5}}
              }
          ],
        Cell[
          TextData@
            Riffle[
              anchorBarActionMenu@@@{menus},
              "\[ThickSpace]\[ThickSpace]\[ThickSpace]\[ThickSpace]\[ThickSpace]\[ThickSpace]"
              ],
          "AnchorBar"
          ]
        }}
      ],
    "AnchorBarGrid"
    ];


(* ::Subsubsection::Closed:: *)
(*DefaultURLBase*)



$DocGenURLBase=
  URLBuild@<|
    "Scheme"->"https",
    "Domain"->"www.wolframcloud.com",
    "Path"->{"objects","b3m2a1.docs","reference"}
    |>;


(* ::Subsubsection::Closed:: *)
(*DocGenRefLink*)



DocGenRefLink[s_String,cell:True|False:True]:=
  Cell@*BoxData@
    TemplateBox[
      {
        Cell[TextData[Last@StringSplit[s,"`"]]],
        pacletLinkBuild[s]
        },
      "RefLink",
      BaseStyle->{"InlineFormula"}
      ];
DocGenRefLink[s_Symbol]:=
  With[{sname=dgQuietSymbolName@Unevaluated[s]},
    DocGenRefLink[sname]
    ];
DocGenRefLink[h_Hyperlink]:=
  Cell[BoxData@ToBoxes@h,"Hyperlink"];
DocGenRefLink[e_?BoxQ]:=
  e/.s_String?makeRefTest:>DocGenRefLink[s];
DocGenRefLink~SetAttributes~HoldFirst


(* ::Subsubsection::Closed:: *)
(*parseRefText*)



parseRefText[t_]:=
  ReplaceAll[
    ReplaceAll[t,
      StyleBox[ital_?docSymStringPat,
        FontSlant->"Italic"]:>
          StyleBox[ital,"TI"]
      ],
    Cell[
      BoxData[FormBox[s_,_?(ToString[#]=="InlineRef"&)]],
      ___
      ]:>
      Replace[s,{
        _String?makeRefTest:>
          DocGenRefLink[s],
        "..."->
          StyleBox["...","TI"],
        SubscriptBox[a_,b_]:>
          Cell[
            BoxData@SubscriptBox[
              StyleBox[a,"TI"],
              StyleBox[b,"TI"]
              ],
            FormatType->TraditionalForm],
        Except[_TextData]:>
          Replace[{
            b_BoxData:>
              Cell[b,"InlineFormula"],
            b:Except[_Cell]:>
              Cell[BoxData[b],"InlineFormula"]
            }]@
            ReplaceAll[s,{
              hold:TemplateBox[___,"RefLink",___]:>
                hold,
              hold:(StyleBox|FormBox)[f_,e___]:>
                StyleBox[parseRefText[f],e],
              ref_String?makeRefTest:>
                DocGenRefLink[ref],
              r_String?(StringMatchQ["\"*\""]):>
                Cell[
                  BoxData@
                    StyleBox[r,"InlineFormula",ShowAutoStyles->True],
                  FormatType->StandardForm
                  ],
              SubscriptBox[a_,b_]:>
                Cell[
                  BoxData@SubscriptBox[
                    StyleBox[a,"TI"],
                    StyleBox[b,"TI"]
                    ],
                  FormatType->TraditionalForm
                  ]
              }]
        }]
    ];


(* ::Subsubsection::Closed:: *)
(*generateSymRefs*)



generateSymRefs[seeAlso_]:=
  With[{
    names=
      Replace[
        Replace[Thread[Hold[seeAlso]],
          Hold[h_Hold]:>h,
          1],{
        Hold[s_String]:>
          ToExpression[s,StandardForm,dgQuietSymbolName],
        Hold[s_Symbol]:>
          dgQuietSymbolName@Unevaluated[s],
        Hold[k_->v_String]:>
          k->"paclet:"<>v
        },
        1]},
    Replace[names,{
      s_String:>
        With[{p=pacletLinkBuild[s,"ref"]},
          "\""<>s<>"\"":>Documentation`HelpLookup[p]
          ],
      (k_->v_):>
        "\""<>ToString@k<>"\"":>Documentation`HelpLookup[v]
      },
      1]
    ];
generateSymRefs~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*generateGuideRefs*)



generateGuideRefs[guides_]:=
  With[{g=pacletLinkBuild[Last@#,"guide"]},
    "\""<>First@#<>"\"":>Documentation`HelpLookup[g,EvaluationNotebook[]]
    ]&/@
    Replace[guides,
      s_String:>(s->s),
      1];


(* ::Subsubsection::Closed:: *)
(*generateUrlRefs*)



generateUrlRefs[refString_String]:=
  With[{url=
    If[StringStartsQ[refString,"ref"|"guide"|"tutorial"],
      URLBuild[{"http://reference.wolfram.com/language",refString}],
      URLBuild@{$DocGenURLBase,refString}
      ]
    },
    {
      refString:>None,
      "Copy Documentation Center URI":>CopyToClipboard@refString,
      Delimiter,
      "Copy web URL":>
        CopyToClipboard@Hyperlink[url],
      "Go to URL":>
        SystemOpen@url
      }
    ];
generateUrlRefs[ref:_Symbol|_MessageName]:=
  generateUrlRefs@
    Evaluate@
      StringTrim[pacletLinkBuild@ToString@Unevaluated[ref],
        "paclet:"
        ];
generateUrlRefs~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*docToString*)



docSymbolNameToString[sym_Symbol]:=
  dgQuietSymbolName@Unevaluated[sym];
docSymbolNameToString[s_]:=
  ToString@Unevaluated[s];
docSymbolNameToString~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*opener*)



sectionOpener=
  Style[
   Graphics[{
     Thickness[0.18],
     RGBColor[0.8509803921568627, 0.396078431372549, 0],
     Line[{{-1.8, 0.5}, {0, 0}, {1.8, 0.5}}]}, 
       AspectRatio -> 1, PlotRange -> {{-3, 4}, {-1, 1}},
     ImageSize -> 20],
   Magnification -> 0.68*Inherited
   ];


With[{sectionOpener=sectionOpener},
  sectionsToggler[sectionIDs__]:=
    With[{list=DeleteCases[{TaggingRules, "Openers", sectionIDs},None]},
      Toggler[
        Dynamic[
          MatchQ[
            CurrentValue[EvaluationNotebook[],list,Closed],
            Open|True
            ],
          CurrentValue[EvaluationNotebook[],list]=#;&,
          ImageSizeCache->{14.,{5.,9.}}
          ],
        Thread[{True,False}->{sectionOpener,Rotate[sectionOpener,\[Pi]/2,{-1.65,-1}]}]
        ]
      ]
  ]


(* ::Subsubsection::Closed:: *)
(*openerText*)



openerText[text_,ids__]:=
  TextData@{
    Cell@BoxData@
      With[{toggle=sectionsToggler[ids]},
        DynamicBox[
          If[ $VersionNumber < 11.1,
            "",
            Cell[BoxData@ToBoxes@toggle]
            ],
        UpdateInterval->Infinity
        ]
      ],
    text
    };


(* ::Subsubsection::Closed:: *)
(*openerCell*)



openerCell[text_,style_,id:_String|None:None,ops___?OptionQ]:=
  Cell[openerText[text,style,id],
    style,
    System`WholeCellGroupOpener->True,
    ops
    ];


(* ::Subsubsection::Closed:: *)
(*openerCellGroup*)



openerCellGroup[{text_,style_,id:_String|None:None,ops___?OptionQ},
  subcells___
  ]:=
  Cell@
    CellGroupData[Flatten@{
      openerCell[text,style,id,ops],
      subcells
      },
        With[{idlist=
          If[id===None,
            {TaggingRules, "Openers",style},
            {TaggingRules, "Openers",style,id}
            ]},
          Dynamic@
            CurrentValue[EvaluationNotebook[],
              idlist,
              Closed
              ]
          ]
      ];


(* ::Subsubsection::Closed:: *)
(*generateDetailsSection*)



generateDetailsSection[sec:Except[_List]]:=
  Cell[
    Replace[sec,
      Except[_TextData|_BoxData]:>
        TextData@Replace[sec,Except[_String]:>ToBoxes[sec]]
      ],
    "Notes"
    ];
generateDetailsSection[sec:{__List}]:=
  Cell[
    BoxData@
      GridBox[
        Map[
          Prepend[
            Replace[#,{
              s:_String|_BoxData|_TextData:>
                Cell[s,"TableText"],
              c_Cell:>
                c,
              e_:>
                Cell[BoxData@ToBoxes[e],"TableText"]
              },
              1],
            Cell["      ", "TableRowIcon"]
            ]&,
          sec],
      GridBoxDividers->{
        "Rows" -> ConstantArray[True,Length@sec]
        }
      ],
    ToString[Length@First@sec]<>"ColumnTableMod"
    ];
generateDetailsSection[{note:Except[_List],grid_List}]:=
  Cell[CellGroupData[{
    generateDetailsSection[note],
    generateDetailsSection[grid]
    },Closed]];


(* ::Subsubsection::Closed:: *)
(*DocMetadata*)



docMetadata=DocMetadata;


$docMetaMap=
  <|
    "context"->"Context","language"->"Language","paclet"->"Paclet",
    "type"->"Type","label"->"Label","uri"->"URI","summary"->"Summary",
    "status"->"Status","title"->"Title","titlemodifier"->"TitleModifier",
    "windowtitle"->"WindowTitle","keywords"->"Keywords","synonyms"->"Synonyms",
    "index"->"Index","built"->"Built","history"->"History","tabletags"->"TableTags",
    "tutorialcollectionlinks"->"TutorialCollectionLinks",
    "specialkeywords"->"SpecialKeywords"
    |>;
Options[DocMetadata]=
  {
    "Built"->Automatic,
    "History"->Automatic,
    "Context"->Automatic,
    "Keywords"->Automatic,
    "SpecialKeywords"->Automatic,
    "TutorialCollectionLinks"->Automatic,
    "Index"->Automatic,
    "Label"->Automatic,
    "Language"->Automatic,
    "Paclet"->Automatic,
    "Status"->Automatic,
    "Summary"->Automatic,
    "Synonyms"->Automatic,
    "TableTags"->Automatic,
    "Title"->Automatic,
    "TitleModifier"->Automatic,
    "WindowTitle"->Automatic,
    "Type"->Automatic,
    "URI"->Automatic
    };
DocMetadata[ops:OptionsPattern[]]:=
  iDocMetadata@
    FilterRules[
      Normal@
        KeyMap[
          Replace[#, $docMetaMap]&,
          Association[
            Flatten@Normal@{ops}
            ]
          ],
      Options[iDocMetadata]
      ];
DocMetadata[nb:
  _NotebookObject|
  _FrontEnd`EvaluationNotebook[]|_FrontEnd`InputNotebook[]
  ]:=
  DocMetadata@
    Replace[Except[_List]->{}]@CurrentValue[nb, {TaggingRules, "Metadata"}];


Options[iDocMetadata]=
  Options[DocMetadata];
iDocMetadata[ops:OptionsPattern[]]:=
  Module[
    {
      sname,
      ctx,
      kw,
      spkw,
      type,
      lab,
      title,
      sum
      },
    ctx=
      Replace[OptionValue["Context"],
        Except[_String?(StringEndsQ["`"])]:>
          StringTrim[Replace[$DocGenActive, Except[_String]->"System"],"`"]<>"`"
        ];
    sname=
      Replace[OptionValue["Label"],
        Except[_String]->"Symbol"
        ];
    type=
      Replace[OptionValue["Type"],
        Except[_String]->"Symbol"
        ];
    sum=
      First@Flatten@List@
        Replace[OptionValue["Summary"],
          Except[_String|{__String}]->{""}
          ];
    kw=
      Replace[OptionValue["Keywords"],{
        Except[_String|{__String}]:>StringSplit@sum
        }];
    kw=
      Replace[Except[_List]->{}]@
        Flatten@
          Map[
            ToLowerCase@
              Flatten@{
                #,
                Map[
                  StringJoin,
                  DeleteCases[{Break}]@
                    SplitBy[
                      Flatten@
                        StringSplit[#,
                          l_?LowerCaseQ~~b:LetterCharacter?(Not@*LowerCaseQ):>
                          {l,Break,b}
                          ],
                      MatchQ[Break]
                      ]
                  ]
                }&,
            Flatten@{kw}
            ];
    spkw=
      Replace[Except[_List]->{}]@
      Replace[OptionValue["SpecialKeywords"],{
        strs:_String|{__String}:>
          Flatten@
            Map[
              ToLowerCase@
                Flatten@{
                  #,
                  Map[
                    StringJoin,
                    DeleteCases[{Break}]@
                      SplitBy[
                        Flatten@
                          StringSplit[#,
                            l_?LowerCaseQ~~b:LetterCharacter?(Not@*LowerCaseQ):>
                            {l,Break,b}
                            ],
                        MatchQ[Break]
                        ]
                    ]
                  }&,
              Flatten@{strs}
              ]
        }];
    lab=
      Replace[OptionValue["Label"],
        Except[_String]->sname
        ];
    title=
      Replace[OptionValue["Title"],
        Except[_String]:>lab
        ];
  {
    "built"->
      Replace[OptionValue["Built"],
        Automatic->ToString@First@DateObject[]
        ],
    "history"->
      Replace[OptionValue["History"],
        Automatic->{ToString@$VersionNumber,"",""}
        ],
    "context"->ctx,
    "keywords"->kw,
    "specialkeywords"->spkw,
    "tutorialcollectionlinks"->
      Replace[OptionValue["TutorialCollectionLinks"],
        Except[{__String}]:>{}
        ],
    "index"->
      Replace[OptionValue["Index"],
        Except[True|False]->True
        ],
    "label"->lab,
    "language"->
      Replace[OptionValue["Language"],
        Except[_String]->"en"
        ],
    "paclet"->
      Replace[OptionValue["Paclet"],
        Except[_String]->"Mathematica"
        ],
    "status"->
      Replace[OptionValue["Status"],
        Except[_String]->"None"],
    "summary"->sum,
    "synonyms"->
      Replace[OptionValue["Synonyms"],
        Except[{__String}]->{}
        ],
    "tabletags"->
      Replace[OptionValue["TableTags"],
        Except[{__String}]->{}
        ],
    "title"->title,
    "titlemodifier"->
      Replace[OptionValue["TitleModifier"],Except[_String]->""],
    "windowtitle"->
      Replace[OptionValue["WindowTitle"],
        Except[_String]:>Replace[title, "No title..."->sname]
        ],
    "type"->type,
    "uri"->
      StringReplace[
        StringReplace[
          StringTrim[
            Replace[OptionValue["URI"],
              {
                s_String?(Not@StringContainsQ[#,"/"]&):>
                  pacletLinkBuild[
                    s,
                    ToLowerCase@type
                    ],
                Except[_String]:>
                  ctx<>"/"<>
                    Replace[type, {"Guide"->"guide", "Tutorial"->"tutorial", _->"ref"}]<>
                    "/"<>sname
                }
              ],
            "paclet:"
            ],
          Except["/"|WordCharacter|"$"]->""
          ],
        StartOfString~~"System/"->""
        ]
    } 
  ]


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
    DialogInput,BoundaryMeshRegion
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


(*$knownUsageReplaceableSymbols=
	Alternatives@@{
		Symbol,
		Integer,
		Real,
		String,
		List,
		Association
		};*)


(*usagePatternReplace[
	vals_,
	reps_:{}
	]:=
	With[{
		names=AssociationMap[Null&,{}(*Names[]*)],
		conts=Alternatives@@{"System`","FrontEnd`","PacletManager`","Internal`"}
		},
		ReplaceRepeated[
			FixedPoint[
				Replace[
					#,{
						Verbatim[Pattern][_,e_]\[RuleDelayed]
							e,
						Verbatim[HoldPattern][Verbatim[Pattern][_,e_]]:>
							HoldPattern[e],
						Verbatim[HoldPattern][Verbatim[HoldPattern][e_]]:>
							HoldPattern[e]
						},
					1
					]&,
				vals
				],
			Flatten@{
				reps,
				Verbatim[Optional][name_,_]\[RuleDelayed]
					name,
				Verbatim[Pattern][name_,_]\[RuleDelayed]
					name,
				Verbatim[PatternTest][p_,_]\[RuleDelayed]
					p,
				Verbatim[Condition][p_,_]\[RuleDelayed]
					p,
				Verbatim[Alternatives][a_,___]\[RuleDelayed]
					a,
				Verbatim[Blank][]:>
					expr,
				Verbatim[Blank][t:$knownUsageReplaceableSymbols]:>
					RuleCondition[
						Replace[t,{
							Integer\[RuleDelayed]int,
							Real\[RuleDelayed]float,
							String\[RuleDelayed]str,
							List:>list,
							Association:>assoc
							}],
						True
						],
				Verbatim[Blank][t_]:>
					t[],
				Verbatim[BlankSequence][]:>
					Sequence@@ToExpression[{"expr1","expr2"}],
				Verbatim[BlankNullSequence][]:>
					Sequence[],
				symbolUsageReplacementPattern[names,conts]
				}
			]
		]*)


(*symbolUsageReplacementPattern[names_,conts_]:=
	s_Symbol?(
		GeneralUtilities`HoldFunction[
			!MatchQ[Context[#],conts]&&
			!MemberQ[$ContextPath,Context[#]]&&
				!KeyMemberQ[names,SymbolName@Unevaluated[#]]
			]
		)\[RuleDelayed]
		RuleCondition[
			ToExpression@
				Evaluate[$Context<>
					With[{name=SymbolName@Unevaluated[s]},
						If[StringLength@StringTrim[name,"$"]>0,
							StringTrim[name,"$"],
							name
							]
						]
					],
			True]*)


(* ::Subsubsection::Closed:: *)
(*usagePatternReplace*)



$privateWorkingCont = "DocGen`Private`";


extractorLocalized[s_] :=
  Block[{$Context = $privateWorkingCont},
    Internal`WithLocalSettings[
      System`Private`NewContextPath[{"System`", $privateWorkingCont}],
      ToExpression[s],
      System`Private`RestoreContextPath[]
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
          If[StringStartsQ[#, LetterCharacter?(Not@*LowerCaseQ)], 
            ToLowerCase@StringTake[#, 1]<>StringDrop[#, 1], 
            #
            ]&@
            SymbolName[Unevaluated@s]
            (*ToLowerCase[StringTake[SymbolName[Unevaluated@s], UpTo[3]]]*),
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
      Replace[#,
        Verbatim[HoldPattern][h_][a___]:>
          HoldPattern[h[a]]
        ],
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
          Verbatim[HoldPattern][a___][b___]:>
            HoldPattern[a[b]],
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
      Verbatim[HoldPattern][a___][b___]:>
        HoldPattern[a[b]],
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
(*toSafeBoxes*)



(*toSafeBoxes[e_,___]/;!TrueQ[$eToSafeBoxes]:=
	toSafeTagBoxesTag[
		HoldComplete[e],
		RandomInteger[{100000,1000000}]
		];
toSafeTagBoxesTag/;TrueQ[$eToSafeBoxes]:=
	*)
toSafeBoxes[e_,___]:=
  ReplaceAll[
    FE`reparseBoxStructure[
      StringDelete[
        StringReplace[
          ToString[Unevaluated@e, InputForm],
          Shortest[
            "HoldPattern["~~innards__~~"]"/;(
              Count[innards, "]"]==Count[innards, "["]
              )
            ]:>
              innards
          ],
        $privateWorkingCont
        ],
      StandardForm
      ],
    RowBox[{"Removed","[",o_,"]"}]:>ToExpression@o
    ];
toSafeBoxes~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*callPatternReplace*)



$knownCallReplaceableSymbolsList=
  Alternatives@@{
    Integer,
    String,
    List,
    Association,
    Symbol,
    Notebook,
    NotebookObject
    };


callPatternReplace[vals_,
  reps_:{}
  ]:=
  DeleteCases[
    ReplaceRepeated[
      FixedPoint[
        Replace[
          #,{
            Verbatim[Pattern][_,e_]:>
              e,
            Verbatim[HoldPattern][Verbatim[Pattern][_,e_]]:>
              HoldPattern[e],
            Verbatim[HoldPattern][Verbatim[HoldPattern][e_]]:>
              HoldPattern[e]
            },
          1
          ]&,
        vals
        ],
      Flatten@
        {
          reps,
          Verbatim[Pattern][p_Symbol,Verbatim[Blank][]]:>
            RuleCondition[
              ToExpression[
                SymbolName@Unevaluated[p]
                ],
              True
              ],
          Verbatim[Pattern][p_,Verbatim[Blank][]]:>
            RuleCondition[
              ToString@Unevaluated[p],
              True
              ],
          Verbatim[Pattern][p_,
            Verbatim[Blank][t:$knownCallReplaceableSymbolsList]
            ]:>
            RuleCondition[
              With[{pstring=
                Replace[Unevaluated[p],{
                  _Symbol:>
                    SymbolName[p],
                  _:>
                    ToString[Unevaluated[p]]
                  }]
                },
                Replace[Unevaluated@t,{
                  Symbol->
                    Replace[Unevaluated[p],{
                      _Symbol:>
                        Block[{$Context="Global`"},
                          ToExpression@SymbolName[p]
                          ],
                      _:>
                        Block[{$Context="Global`"},
                          ToExpression@"sym"
                          ]
                      }],
                  Integer->1,
                  String->pstring,
                  List->{pstring},
                  Association:>
                    <|pstring->pstring|>,
                  Notebook:>
                    Notebook[{}],
                  NotebookObject:>
                    FrontEnd`InputNotebook[]
                  }]
                ],
              True],
          Verbatim[Pattern][p_,Verbatim[Blank][t_]]:>
            t[],
          Verbatim[Pattern][p_,
            Verbatim[BlankSequence][t:Integer|String|List|Association]]:>
            RuleCondition[
              With[{pstring=
                Replace[Unevaluated[p],{
                  _Symbol:>
                    SymbolName[p],
                  _:>
                    ToString[Unevaluated[p]]
                  }]
                },
              Replace[t,{
                Integer->Sequence[0,1],
                String:>
                  Sequence[
                    pstring<>"1",
                    pstring<>"2"
                    ],
                List:>
                  Sequence[{pstring},{pstring}],
                Association->Sequence[<||>,<||>]
                }]
                ],
              True],
          Verbatim[Pattern][p_,Verbatim[BlankSequence][t_]]:>
            Sequence[t[1],t[2]],
          Verbatim[Blank][t_]:>
            RuleCondition[
              Pattern@@{expr,Blank[t]},
              True
              ],
          Verbatim[BlankSequence][t_]:>
            RuleCondition[
              Pattern@@{expr,Blank[t]},
              True
              ],
          Verbatim[BlankNullSequence][t_]:>
            Sequence[],
          Verbatim[Repeated][t_,___]:>
            t,
          Verbatim[RepeatedNull][___]:>
            Sequence[],
          Verbatim[Pattern][_,p_]:>
            Unevaluated@p,
          Verbatim[PatternTest][p_,
            s:StringQ|IntegerQ|AssociationQ|ListQ
            ]:>
            RuleCondition[
              Pattern@@List[p,
                Blank[
                  Replace[s,{
                    StringQ->String,
                    IntegerQ->Integer,
                    AssociationQ->Association,
                    ListQ->List
                    }]
                  ]
                ],
              True
              ],
          Verbatim[PatternTest][p_,_]:>
            Unevaluated@p,
          Verbatim[Alternatives][a_,___]:>
            a,
          Verbatim[Optional][_,v_]:>
            Unevaluated@v,
          Verbatim[Blank][]:>
            RuleCondition[
              ToExpression["expr",
                StandardForm
                ],
              True
              ],
          Verbatim[BlankSequence][]:>
            RuleCondition[
              Sequence[
                ToExpression["expr1",
                  StandardForm
                  ],
                ToExpression["expr2",
                  StandardForm
                  ]
                ],
              True
              ],
          (Verbatim[BlankNullSequence]|Verbatim[OptionsPattern])[]:>
            Sequence[],
          h_[a___,Verbatim[Sequence][e__],b___]:>
            h[a,e,b]
          }
      ],
    Verbatim[Sequence][],
    \[Infinity]
    ];


(* ::Subsubsection::Closed:: *)
(*generateBasicExample*)



Clear@generateBasicExample;


generateBasicExample[
  expression:Except[_String|_Cell|_BoxData|_TextData|Delimiter]
  ]:=
  Cell[
    CellGroupData[{
      Cell[BoxData@
        Replace[Hold[expression],{
          Hold[(Hold|HoldPattern)[e_]]:>ToBoxes@Unevaluated[e],
          Hold[e_]:>ToBoxes@Unevaluated[e]
          }],
        "Input",
        CellLabel->(
          If[!IntegerQ@$DocGenLine,$DocGenLine=1];
          TemplateApply["In[``]:=",$DocGenLine]
          )
        ],
      With[{e=
        Replace[Hold[expression],{
          Hold[(Hold|HoldPattern)[e_]]:>e,
          Hold[e_]:>e
          }]
        },
        If[e=!=Null,
          Cell[BoxData@ToBoxes@
            Replace[Hold[expression],{
              Hold[(Hold|HoldPattern)[e_]]:>e,
              Hold[e_]:>e
              }],
            "Output",
            CellLabel->
              (
                If[!IntegerQ@$DocGenLine,$DocGenLine=1];
                TemplateApply["Out[``]:=",$DocGenLine++]
                )
            ],
          (
            If[!IntegerQ@$DocGenLine,$DocGenLine=1];
            TemplateApply["Out[``]:=",$DocGenLine++]
            );
          $DocGenLine++;
          Nothing
          ]
        ]
      },
      Open]];


generateBasicExample[b_BoxData]:=
  Replace[b,
    _:>
      Cell[
        CellGroupData[
          {
            Cell[b,"InlineFormula","Input",
              CellLabel->TemplateApply["In[``]:=",$DocGenLine]],
            Replace[ToExpression@b,{
              Null:>($DocGenLine++;Nothing),
              e_:>
                Cell[BoxData@ToBoxes@e,"Output",
                  CellLabel->TemplateApply["Out[``]:=",$DocGenLine++]]
              }]
            },
          Open
          ]
        ]
    ];


generateBasicExample[b_TextData]:=
  ReplaceAll[
    Cell[
      b/.Cell[e_,"Input",o___]:>Cell[e,"InlineFormula","Input",o],
      "ExampleText"
      ],
    r_RowBox:>
      ReplaceAll[r,
        {
          c:Cell[BoxData[_TemplateBox],___]:>
            c,
          s_String?makeRefTest:>
            s,
          s_String?symString:>
            StyleBox[
              Last@StringSplit[s,"`"],
              "TI"
              ]
          }
        ]
    ];


generateBasicExample[c_Cell]:=
  c;
generateBasicExample[s_String]:=
  Cell[s,"ExampleText"];
generateBasicExample[Delimiter]:=
  Cell[
    BoxData@
      InterpretationBox[Cell["\t", "ExampleDelimiter"],$Line = 0; Null],
     "ExampleDelimiter"
    ];
generateBasicExample~SetAttributes~HoldFirst;


(* ::Subsubsection::Closed:: *)
(*generateExamplesSections*)



generateExamplesSections[exampleSections:{(_String->_List)...}:{}]:=
  ReplaceAll[{
    "\""<>$HomeDirectory<>"\""->"$HomeDirectory",
    s_String?(StringStartsQ["\""<>$HomeDirectory]):>
      Replace[
        FileNameSplit@FileNameDrop[StringTrim[s,"\""],
          FileNameDepth@$HomeDirectory],
        {p__}:>
          Cell[
            BoxData@
              ToBoxes@Unevaluated@
                FileNameJoin@{
                  $HomeDirectory,
                  p
                  }
            ]
        ]
    }]@
  Block[{$exampleCounter=0},
    openerCellGroup[{"Examples","PrimaryExamplesSection"},
      Map[
        openerCellGroup[{
            Extract[#,{1,1}],
            "ExampleSection",
            ToString@($exampleCounter++)
            },
          Replace[
            Block[{$splitFlag=True},
              SplitBy[
                Thread@Extract[#,{1,2},Hold],
                Replace[{
                  Hold[Cell[_,"ExampleSubsection",___]]:>
                    ($splitFlag=Not@$splitFlag),
                  _:>$splitFlag
                  }]
                ]
              ],{
            {
              Hold[Cell[d_,"ExampleSubsection",ops___]],
              c__
              }:>
                openerCellGroup[{
                  d,
                  "ExampleSubsection",
                  If[IntegerQ@$exampleCounter,
                    ToString@$exampleCounter++,
                    "0"
                    ],
                  ops
                  },
                  Replace[{c},{
                    Hold[Hold[e_]]:>
                      generateBasicExample[e],
                    Hold[e_]:>
                      generateBasicExample[e]
                    },
                    1]
                  ],
            c_:>
              Replace[c,{
                Hold[Hold[e_]]:>
                  generateBasicExample[e],
                Hold[e_]:>
                  generateBasicExample[e]
                },
                1]
            },
            1]
          ]&,
        Thread[Hold@exampleSections]
        ]
      ]
    ];
generateExamplesSections[
  basicExamples:{Except[_Rule],___}
  ]:=
  generateExamplesSections[{"Basic Examples"->basicExamples}]


(* ::Subsubsection::Closed:: *)
(*Footer*)



If[!ValueQ@$DocGenFooter,
  $DocGenFooter:=
    DocGenSettingsLookup["Footer"]
  ]


(* ::Subsection:: *)
(*Helpers*)



(* ::Subsubsection::Closed:: *)
(*IndexDocumentation*)



DocGenIndexDocumentation[
  src_String?DirectoryQ,
  dest:_String?DirectoryQ|Automatic:Automatic
  ]:=
  If[10<=$VersionNumber<11.2,
    With[{
      indexDir=Replace[dest, Automatic:>FileNameJoin@{src,"Index"}],
      spellInd=Replace[dest, Automatic:>FileNameJoin@{src,"SpellIndex"}]
      },
      Needs["DocumentationSearch`"];
      Quiet@DeleteDirectory[indexDir, DeleteContents -> True];
      With[{ind=DocumentationSearch`NewDocumentationNotebookIndexer[indexDir]},
        Map[
          DocumentationSearch`AddDocumentationNotebook[
            ind,
            #]&,
            FileNames["*.nb", src, \[Infinity]]
          ];
        DocumentationSearch`CloseDocumentationNotebookIndexer[ind];
        ];
      Quiet@DeleteDirectory[spellInd, DeleteContents -> True];
      DocumentationSearch`CreateSpellIndex[indexDir,spellInd];
      indexDir
      ],
    With[
      {
        pac=
          PacletInfoAssociation[
            Nest[ParentDirectory, src, 2]
            ]
        },
      Needs["DocumentationSearch`"];
      DocumentationSearch`SearchDocumentation[
        (*"paclet:"<>*)
          StringTrim[
            Lookup[
              Lookup[
                Lookup[pac, "Extensions",<||>],
                "Kernel",
                <||>
                ],
              "Context",
              {FileBaseName[Nest[ParentDirectory, src, 2]]<>"`"}
              ][[1]],
            "`"
            ]
          ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*generateDocumentation*)



generateDocumentation//Clear


Options[generateDocumentation]:=
  Join[
    Options@DocGenGenerateSymbolPages,
    Options@DocGenGenerateGuide,
    {
      "Install"->False,
      "Temporary"->False,
      "Upload"->False,
      "Index"->Automatic,
      "GenerateHTML"->False
      },
    Options@PacletUpload,
    Options@PacletInfoExpressionBundle,
    Options@DocGenGenerateHTMLDocumentation
    ];
generateDocumentation[
  pattern:_String,
  base:_String?DirectoryQ|Automatic:Automatic,
  open:True|False:True,
  ops:OptionsPattern[]
  ]:=
  Module[{
    pacletBase=
      FileNameJoin@{
        Replace[base,
          Automatic:>
            $DocGenDirectory
          ],
        Replace[OptionValue["Name"],
          Automatic:>
            "Documentation_"<>StringReplace[pattern, 
              Except["$"|WordCharacter]->""
              ]
          ]
        },
    dir,linkbase,
    paclet,
    bundle,
    html,
    tmp=TrueQ@OptionValue["Temporary"]
    },
      dir=
        FileNameJoin@{
          pacletBase,
          "Documentation",
          "English"
          };
      linkbase=
        Replace[OptionValue["Name"],
          Automatic:>
            StringReplace[
              pattern,
              Except[WordCharacter]->""
              ]
          ];
      Quiet@DeleteDirectory[dir,DeleteContents->True];
      CreateDirectory[dir,
        CreateIntermediateDirectories->True
        ];
      Block[{$DocGenActive=linkbase},
        DocGenSaveSymbolPages[
          pattern,
          Sequence@@
            DeleteDuplicatesBy[First]@
            FilterRules[
              {
                "Extension"->True,
                "Directory"->dir,
                ops,
                "RelatedGuides"->(linkbase<>"/guide/"<>linkbase)
                },
              Options@DocGenSaveSymbolPages
              ]
          ];
        Monitor[
          DocGenSaveGuide[
            pattern,
            Sequence@@
              DeleteDuplicatesBy[First]@
              FilterRules[
                {
                  "Directory"->dir,
                  "RelatedGuides"->
                    DeleteCases[
                      Replace[OptionValue@"RelatedGuides",Automatic->{}],
                      linkbase->linkbase|(linkbase<>"/guide/"<>linkbase)
                      ],
                    ops
                    },
                Options@DocGenSaveGuide
                ]
            ],
          Internal`LoadingPanel[
            "Generating guide page"
            ]
          ]
        ];
      If[OptionValue["GenerateHTML"]//TrueQ,
        If[!DirectoryQ@$DocGenWebDocsDirectory,
          CreateDirectory@$DocGenWebDocsDirectory
          ];
        html=
          DocGenGenerateHTMLDocumentation[
            FileNameJoin@$DocGenWebDocsDirectory,
            FilterRules[
              {
                "Directory"->dir,
                ops
                },
              Options@DocGenGenerateHTMLDocumentation
              ]
            ]
        ];
      If[Replace[OptionValue["Index"],
          Automatic->
            OptionValue@"Install"],
          Monitor[
            DocGenIndexDocumentation[dir],
            Internal`LoadingPanel[
              "Indexing documentation"
              ]
            ]
        ];
      PacletInfoExpressionBundle[
        pacletBase,
        FilterRules[{
          ops,
          "Kernel"->None,
          "FrontEnd"->None,
          "Resource"->None,
          "Description"->"Autogenerated documentation"
          },
          Options@PacletInfoExpressionBundle
          ]
        ];
      If[open||TrueQ@OptionValue["Install"],
        PacletManager`PacletDirectoryRemove@
          Replace[base,
            Automatic:>
              $DocGenDirectory
            ]
        ];
      bundle=
        If[TrueQ@OptionValue["Install"]||
          TrueQ@OptionValue["Upload"],
          PacletBundle[pacletBase,
            "BuildRoot"->
              Replace[base,
                Automatic:>
                  $DocGenDirectory
                ]
            ]
          ];
      If[OptionValue["Install"]//TrueQ,
        PacletManager`PacletInstall[bundle, "IgnoreVersion"->True],
        If[open,
          (*CurrentValue[$FrontEndSession,
						{"NotebookSecurityOptions", "TrustedPath"}
						]=
						Append[
							CurrentValue[$FrontEndSession,
								{"NotebookSecurityOptions", "TrustedPath"}
								],
							Replace[base,
								Automatic\[RuleDelayed]
									$DocGenDirectory
								]
							];*)
          PacletManager`PacletDirectoryAdd@
            Replace[base,
              Automatic:>
                $DocGenDirectory
              ]
          ]
        ];
      If[open,
        SystemOpen@
          URLBuild[<|
            "Scheme"->"paclet",
            "Path"->{
              StringReplace[pattern,Except["$"|WordCharacter]->""],
              "guide",
              StringReplace[pattern,Except["$"|WordCharacter]->""]
              }
            |>];
        If[OptionValue["Upload"]//TrueQ,
          PacletUpload[bundle,FilterRules[{ops},Options@PacletUpload]]
          ],
        <|
          "Directory"->pacletBase,
          If[TrueQ@OptionValue@"Install",
            "Paclets"->
              PacletManager`PacletFind[
                Lookup[
                  PacletInfoAssociation@pacletBase,
                  {"Name","Version"}
                  ]
                ],
            Nothing
            ],
          If[OptionValue["Upload"]//TrueQ,
            "Upload"->
              PacletUpload[bundle,
                FilterRules[{ops},Options@PacletUpload]],
            Nothing
            ],
          If[OptionValue["GenerateHTML"]//TrueQ,  
            "HTML"->html,
            Nothing
            ]
          |>
        ]
      ];


(* ::Subsubsection::Closed:: *)
(*GenerateDocumentation*)



Options[docGenGenerateDocumentation]=
    Options[generateDocumentation]
docGenGenerateDocumentation[
  patterns:{__String},
  base:_String?DirectoryQ|Automatic:Automatic,
  open:True|False:True,
  ops:OptionsPattern[]
  ]:=
  If[OptionValue["Upload"]===Default,
    docGenGenerateDocumentation[patterns,base,open,
      "Upload"->True,
      "ServerName"->Default,
      "UploadSiteFile"->True,
      ops
      ],
    With[{
      linkBases=
        StringReplace[
          patterns,
          Except[WordCharacter]->""
          ]
        },
      With[{pacs=
        Block[{
          $ContextPath=
            Join[$ContextPath,
              Select[patterns, StringEndsQ["`"]]
              ]
          },
          MapThread[
            Monitor[
              generateDocumentation[
                #,
                base,
                False,
                ops,
                "RelatedGuides"->
                  Map[#->(#<>"/guide/"<>#)&,linkBases]
                ],
              Internal`LoadingPanel@
                TemplateApply[
                  "Generating `` documentation",
                  #2
                  ]
              ]&,
              {
                patterns,
                linkBases
                }
            ]
          ]
        },(*
				If[Length@linkBases>1,
					SaveMultiPackageOverviewNotebook[
						Lookup[pacs, "Directory"],
						Directory->
							First@
								Select[DirectoryQ]@
								FileNames["*",
									FileNameJoin@{
										Last@Lookup[pacs, "Directory"],
										"Documentation"
										}
									]
						]
					];*)
        If[open,
          PacletManager`PacletDirectoryAdd@
            Replace[base,
              Automatic:>
                $DocGenDirectory
              ];
          SystemOpen@
            URLBuild[<|
              "Scheme"->"paclet",
              "Path"->{
                StringReplace[Last@linkBases,Except["$"|WordCharacter]->""],
                "guide",
                StringReplace[Last@linkBases,Except["$"|WordCharacter]->""]
                }
              |>],
          pacs
          ]
        ]
      ]
    ];
docGenGenerateDocumentation[
  patterns_String,
  base:_String?DirectoryQ|Automatic:Automatic,
  open:True|False:True,
  ops:OptionsPattern[]
  ]:=
  docGenGenerateDocumentation[
    {patterns},
    base,
    open,
    ops
    ];


Options[DocGenGenerateDocumentation]=
  Join[
    {
      Directory->Automatic,
      "OpenOnBuild"->True
      },
    Options[docGenGenerateDocumentation]
    ];
DocGenGenerateDocumentation[obj:_String|{__String}, ops:OptionsPattern[]]:=
  With[{base=OptionValue[Directory], open=OptionValue["OpenOnBuild"]},
    docGenGenerateDocumentation[obj,
      base,
      open,
      FilterRules[{ops}, Options[docGenGenerateDocumentation]]
      ]
    ]


(* ::Subsubsection::Closed:: *)
(*AddUsage*)



DocAddUsage[sym_Symbol,usage_String]:=
  (sym::usages=
    StringTrim@
      StringRiffle[{
        StringReplace[
          Replace[sym::usages,
            Except[_String]->""
            ],
          usage->""
          ],
        usage},
        "\n"]);
DocAddUsage[pat:Except[_Missing],usage_String]:=
  DocAddUsage[
    Evaluate@
      FirstCase[Hold[pat],
        s_Symbol?(
          Function[Null,
            !MatchQ[Context[#],"System`"|"Global`"],
            HoldFirst]):>s,
        Missing["NotFound"],
        Infinity,
        Heads->True
        ],
    ToString[Unevaluated[pat]]<>" "<>usage
    ];
DocAddUsage[pat:Except[_Missing],usage_]:=
  DocAddUsage[pat,ToString[usage]];
DocAddUsage~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*ExtractInfo Helpers*)



refLinkRewind//Clear


refLinksRewindable=
  RefLinkPlain|RefLink|OrangeLink|
  "RefLinkPlain"|"RefLink"|"OrangeLink";


refLinkRewind[
  TemplateBox[{title_Cell,link_},
    refLinksRewindable,
  ___]]:=
  ButtonBox[FE`makePlainText@title,
    BaseStyle->"Link",
    ButtonData->link
    ];
refLinkRewind[e_]:=
  e


(* ::Subsection:: *)
(*SymbolPageExtractInfo*)



symPageExtractMetadata[nb_Notebook]:=
  Fold[
    Lookup[#,#2,{}]&,
    Options[nb,TaggingRules],
    {TaggingRules,"Metadata"}
    ]


symPageExtractTitle[nb_Notebook]:=
  FirstCase[nb,Cell[title_,"ObjectName",___]:>title,"Unknown",\[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"Title"]:=
  symPageExtractTitle[nb];


symPageExtractDetails[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"NotesSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"Examples"]:=
  symPageExtractExamples[nb];


symPageExtractExamples[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"PrimaryExamplesSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"Examples"]:=
  symPageExtractExamples[nb];


symPageExtractSeeAlso[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"SeeAlsoSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"SeeAlso"]:=
  symPageExtractSeeAlso[nb];


symPageExtractMoreAbout[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"MoreAboutSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"MoreAbout"]:=
  symPageExtractMoreAbout[nb];


symPageExtractRelatedTutorials[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"RelatedTutorialsSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"RelatedTutorials"]:=
  symPageExtractRelatedTutorials[nb];


symPageExtractRelatedLinks[nb_Notebook]:=
  FirstCase[nb,
    Cell[
      CellGroupData[{
        Cell[_,"RelatedLinksSection",___],
        cells___
        },
        ___]:>{cells},
      ___],
    {},
    \[Infinity]];
SymbolPageExtractInfo[nb_Notebook,"RelatedLinks"]:=
  symPageExtractRelatedLinks[nb];


symPageExtractUsage[nb_Notebook]:=
  Map[#[[2]]->#[[3]]&,
    FirstCase[nb,Cell[BoxData[GridBox[cont_,___]],"Usage",___]:>cont,{},\[Infinity]]
    ];
SymbolPageExtractInfo[nb_Notebook,"Usage"]:=
  symPageExtractUsage[nb];


SymbolPageExtractInfo[nb_Notebook,Optional[All,All]]:=
  AssociationMap[
    SymbolPageExtractInfo[nb,#]&,
    {
      "Usage",
      "Metadata"
      }
    ];


End[];



