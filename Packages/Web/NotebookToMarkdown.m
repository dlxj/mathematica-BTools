(* ::Package:: *)



NotebookToMarkdown::usage="Converts a notebook to markdown";
NotebookMarkdownSave::usage="Saves a notebook as markdown";


Begin["`Private`"];


(* ::Subsection:: *)
(*NotebookToMarkdown*)



$MarkdownSiteRoot=
  FileNameJoin@{
    $WebTemplatingRoot,
    "markdown"
    };


(* ::Subsubsection::Closed:: *)
(*Site*)



$MarkdownStandardContentExtensions=
  {
    "content",
    "project",
    "proj"
    };


MarkdownSiteBase[f_String]:=
  Replace[FileNameSplit[f],{
    {d:Shortest[___],
      (Alternatives@@$MarkdownStandardContentExtensions)|"output",___}:>
      FileNameJoin@{d},
    _:>If[DirectoryQ@f,f,DirectoryName[f]]
    }]


MarkdownContentExtension[root_]:=
  SelectFirst[$MarkdownStandardContentExtensions,
    DirectoryQ@FileNameJoin@{root,#}&,
    Nothing
    ];


MarkdownContentPath[f_String]:=
  Replace[FileNameSplit[f],{
    {Shortest[___],
      Alternatives@@$MarkdownStandardContentExtensions,p___}:>
      FileNameJoin@{p},
    _:>f
    }]


MarkdownOutputPath[f_String]:=
  Replace[FileNameSplit[f],{
    {Shortest[___],"output",p___}:>FileNameJoin@{p},
    _:>f
    }]


(* ::Subsubsection::Closed:: *)
(*File Templates*)



(* ::Subsubsubsection::Closed:: *)
(*Template*)



$markdownnewmdfiletemplate=
"`headers`

`body`
";


(* ::Subsubsubsection::Closed:: *)
(*Metadata*)



(* ::Subsubsubsubsection::Closed:: *)
(*NameToSlug*)



markdownNameToSlug[t_]:=
  ToLowerCase@
    StringReplace[
      t,
      {
        Whitespace->"-",
        Except[WordCharacter]->""
        }
      ]


(* ::Subsubsubsubsection::Closed:: *)
(*Title*)



markdownFileMetadataTitle[t_,name_,opsassoc_]:=
  Replace[t,
    {
      Automatic:>name
      }];


(* ::Subsubsubsubsection::Closed:: *)
(*Slug*)



markdownFileMetadataSlug[t_,name_,opsassoc_]:=
  Replace[t,
    {
      Automatic:>
        markdownNameToSlug@
          markdownFileMetadataTitle[
            Lookup[opsassoc,"Title",t],
            name,
            opsassoc
            ]
      }
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*Metadata*)



markdownFileMetadata[val_,opsassoc_]:=
  Replace[val,{
    _List:>
      StringRiffle[ToString/@val,","],
    _DateObject:>
      StringReplace[DateString[val,"ISODateTime"],"T"->" "]
    }]


(* ::Subsubsubsubsection::Closed:: *)
(*MetadataFormat*)



markdownMetadataFormat[name_,ops_]:=
  With[{opsassoc=Association@ops},
    Block[{Internal`$ContextMarks=False},
      Function[StringRiffle[ToString/@#,"\n"]]@
        KeyValueMap[
          ToString[#]<>": "<>
            ToString@
              StringReplace[
                ToString@
                  Switch[#,
                    "Title",
                      markdownFileMetadataTitle[#2,name,opsassoc],
                    "Slug",
                      markdownFileMetadataSlug[#2,name,opsassoc],
                    _,
                      markdownFileMetadata[#2,opsassoc]
                    ],
                "\n"->"\ "
                ]&,
          KeySortBy[
            Switch[#,"Title",0,_,1]&
            ]@opsassoc
          ]
      ]
    ];


(* ::Subsubsection::Closed:: *)
(*NotebookMetadata*)



MarkdownNotebookMetadata[c:{Cell[_BoxData,"Metadata",___]...}]:=
  Join@@Select[Normal@ToExpression[First@First@#]&/@c,OptionQ];
MarkdownNotebookMetadata[nb_Notebook]:=
  MarkdownNotebookMetadata@
    Cases[
      NotebookTools`FlattenCellGroups[First@nb],
      Cell[_BoxData,"Metadata",___]
      ];
MarkdownNotebookMetadata[nb_NotebookObject]:=
  MarkdownNotebookMetadata@
    Cases[
      NotebookRead@Cells[nb,CellStyle->"Metadata"],
      Cell[_BoxData,___]
      ]


(* ::Subsubsection::Closed:: *)
(*MarkdownNotebook**)



MarkdownNotebookDirectory[nb_]:=
  Replace[Quiet@NotebookDirectory[nb],
    Except[_String?DirectoryQ]:>
      With[{
        d=
          FileNameJoin@{
            $TemporaryDirectory,
            "markdown_export"
            }
        },
        If[!DirectoryQ[d],
          CreateDirectory[d]
          ];
        d
        ]
    ];


MarkdownNotebookFileName[nb_]:=
  Replace[Quiet@NotebookFileName[nb],
    Except[_String?FileExistsQ]:>
      FileNameJoin@{
        $TemporaryDirectory,
        "markdown_export",
        "markdown_notebook.nb"
        }
    ];


MarkdownNotebookContentPath[nb_]:=
  MarkdownContentPath@
    MarkdownNotebookFileName[nb];


NotebookToMarkdown::nocont=
  "Can't handle notebook with implicit CellContext ``. Use a string instead.";
MarkdownNotebookContext[nb_]:=
  Replace[CurrentValue[nb, CellContext],
    c:Except[_String?(StringEndsQ["`"])]:>
      PackageRaiseException[
        Automatic,
        Evaluate[NotebookToMarkdown::nocont],
        c
        ]
    ]


(* ::Subsubsection::Closed:: *)
(*NotebookToMarkdown*)



(* ::Subsubsubsection::Closed:: *)
(*Styles*)



$NotebookToMarkdownCellStyles=
  <|
    
    |>;


$NotebookToMarkdownCellStyles["Section"]=
  {
    "Title", "Chapter", "Subchapter",
    "Section","Subsection","Subsubsection"
    };
$NotebookToMarkdownCellStyles["InputOutput"]=
  {
    "Code","Output","ExternalLanguage",
    "FormattedOutput", "FencedCode", "MathematicaLanguageCode"
    };
$NotebookToMarkdownCellStyles["Text"]=
  {
    "Text",
    "RawMarkdown","RawHTML",
    "RawPre","Program",
    "DisplayFormula",
    "DisplayFormulaNumbered"
    };
$NotebookToMarkdownCellStyles["Print"]=
  {
    "Message","Echo","Print",
    "PrintUsage"
    };
$NotebookToMarkdownCellStyles["Item"]=
  {
    "Item","Subitem","Subsubitem",
    "ItemNumbered","SubitemNumbered","SubsubitemNumbered"
    };
$NotebookToMarkdownCellStyles["Quote"]=
  {
    "Quote"
    };
$NotebookToMarkdownCellStyles["Break"]=
  {
    "PageBreak"
    };


$NotebookToMarkdownStyles:=
  Flatten@Values@$NotebookToMarkdownCellStyles;


(* ::Subsubsubsection::Closed:: *)
(*Global Options*)



$MarkdownIncludeStyleDefinitions=
  False;
$MarkdownIncludeLinkAnchors=
  { "Section", "Subsection" };


(* ::Subsubsubsection::Closed:: *)
(*CharCleaner*)



$NotebookToMarkdownHTMLCharReplacements=
  {
    "\[Rule]"->"->",
    "\[RuleDelayed]"->":>",
    "\[LeftGuillemet]"->"&laquo;",
    "\[DiscretionaryHyphen]"->"&shy;",
    "\[RightGuillemet]"->"&raquo;",
    "\[CapitalAGrave]"->"&Agrave;",
    "\[CapitalAAcute]"->"&Aacute;",
    "\[CapitalAHat]"->"&Acirc;",
    "\[CapitalATilde]"->"&Atilde;",
    "\[CapitalADoubleDot]"->"&Auml;",
    "\[CapitalARing]"->"&Aring;",
    "\[CapitalAE]"->"&AElig;",
    "\[CapitalCCedilla]"->"&Ccedil;",
    "\[CapitalEGrave]"->"&Egrave;",
    "\[CapitalEAcute]"->"&Eacute;",
    "\[CapitalEHat]"->"&Ecirc;",
    "\[CapitalEDoubleDot]"->"&Euml;",
    "\[CapitalIGrave]"->"&Igrave;",
    "\[CapitalIAcute]"->"&Iacute;",
    "\[CapitalIHat]"->"&Icirc;",
    "\[CapitalIDoubleDot]"->"&Iuml;",
    "\[CapitalEth]"->"&ETH;",
    "\[CapitalNTilde]"->"&Ntilde;",
    "\[CapitalOGrave]"->"&Ograve;",
    "\[CapitalOAcute]"->"&Oacute;",
    "\[CapitalOE]"->"&OElig;",
    "\[CapitalOHat]"->"&Ocirc;",
    "\[CapitalOTilde]"->"&Otilde;",
    "\[CapitalODoubleDot]"->"&Ouml;",
    "\[CapitalOSlash]"->"&Oslash;",
    "\[CapitalUGrave]"->"&Ugrave;",
    "\[CapitalUAcute]"->"&Uacute;",
    "\[CapitalUHat]"->"&Ucirc;",
    "\[CapitalUDoubleDot]"->"&Uuml;",
    "\[CapitalYAcute]"->"&Yacute;",
    "\[CapitalThorn]"->"&THORN;",
    "\[SZ]"->"&szlig;",
    "\[AGrave]"->"&agrave;",
    "\[AAcute]"->"&aacute;",
    "\[AHat]"->"&acirc;",
    "\[ATilde]"->"&atilde;",
    "\[ADoubleDot]"->"&auml;",
    "\[ARing]"->"&aring;",
    "\[AE]"->"&aelig;",
    "\[CCedilla]"->"&ccedil;",
    "\[EGrave]"->"&egrave;",
    "\[EAcute]"->"&eacute;",
    "\[EHat]"->"&ecirc;",
    "\[EDoubleDot]"->"&euml;",
    "\[IGrave]"->"&igrave;",
    "\[IAcute]"->"&iacute;",
    "\[IHat]"->"&icirc;",
    "\[IDoubleDot]"->"&iuml;",
    "\[Eth]"->"&eth;",
    "\[NTilde]"->"&ntilde;",
    "\[OGrave]"->"&ograve;",
    "\[OAcute]"->"&oacute;",
    "\[OE]"->"&oelig;",
    "\[OHat]"->"&ocirc;",
    "\[OTilde]"->"&otilde;",
    "\[ODoubleDot]"->"&ouml;",
    "\[OSlash]"->"&oslash;",
    "\[UGrave]"->"&ugrave;",
    "\[UAcute]"->"&uacute;",
    "\[UHat]"->"&ucirc;",
    "\[UDoubleDot]"->"&uuml;",
    "\[YAcute]"->"&yacute;",
    "\[Thorn]"->"&thorn;",
    "\[YDoubleDot]"->"&yuml;",
    "\[ABar]"->"&amacr;",
    "\[CapitalABar]"->"&Amacr;",
    "\[ACup]"->"&abreve;",
    "\[CapitalACup]"->"&Abreve;",
    "\[CAcute]"->"&cacute;",
    "\[CapitalCAcute]"->"&Cacute;",
    "\[CHacek]"->"&ccaron;",
    "\[CapitalCHacek]"->"&Ccaron;",
    "\[DHacek]"->"&dcaron;",
    "\[CapitalDHacek]"->"&Dcaron;",
    "\[EHacek]"->"&ecaron;",
    "\[CapitalEHacek]"->"&Ecaron;",
    "\[NHacek]"->"&ncaron;",
    "\[CapitalNHacek]"->"&Ncaron;",
    "\[RHacek]"->"&rcaron;",
    "\[CapitalRHacek]"->"&Rcaron;",
    "\[THacek]"->"&tcaron;",
    "\[CapitalTHacek]"->"&Tcaron;",
    "\[URing]"->"&uring;",
    "\[CapitalURing]"->"&Uring;",
    "\[ZHacek]"->"&zcaron;",
    "\[CapitalZHacek]"->"&Zcaron;",
    "\[EBar]"->"&emacr;",
    "\[CapitalEBar]"->"&Emacr;",
    "\[LSlash]"->"&lstrok;",
    "\[CapitalLSlash]"->"&Lstrok;",
    "\[ODoubleAcute]"->"&odblac;",
    "\[CapitalODoubleAcute]"->"&Odblac;",
    "\[SHacek]"->"&scaron;",
    "\[CapitalSHacek]"->"&Scaron;",
    "\[UDoubleAcute]"->"&udblac;",
    "\[CapitalUDoubleAcute]"->"&Udblac;",
    "\[Florin]"->"&fnof;",
    "\[Breve]"->"&Breve;",
    "\[DoubleDot]"->"&DoubleDot;",
    "\[TripleDot]"->"&TripleDot;",
    "\[Hacek]"->"&Hacek;",
    "\[DownBreve]"->"&DownBreve;",
    "\[Cedilla]"->"&Cedilla;",
    "\[CapitalAlpha]"->"&Alpha;",
    "\[CapitalBeta]"->"&Beta;",
    "\[CapitalGamma]"->"&Gamma;",
    "\[CapitalDelta]"->"&Delta;",
    "\[CapitalEpsilon]"->"&Epsilon;",
    "\[CapitalZeta]"->"&Zeta;",
    "\[CapitalEta]"->"&Eta;",
    "\[CapitalTheta]"->"&Theta;",
    "\[CapitalIota]"->"&Iota;",
    "\[CapitalKappa]"->"&Kappa;",
    "\[CapitalLambda]"->"&Lambda;",
    "\[CapitalMu]"->"&Mu;",
    "\[CapitalNu]"->"&Nu;",
    "\[CapitalXi]"->"&Xi;",
    "\[CapitalOmicron]"->"&Omicron;",
    "\[CapitalPi]"->"&Pi;",
    "\[CapitalRho]"->"&Rho;",
    "\[CapitalSigma]"->"&Sigma;",
    "\[CapitalTau]"->"&Tau;",
    "\[CapitalUpsilon]"->"&Upsilon;",
    "\[CurlyCapitalUpsilon]"->"&Upsi;",
    "\[CapitalPhi]"->"&Phi;",
    "\[CapitalChi]"->"&Chi;",
    "\[CapitalPsi]"->"&Psi;",
    "\[CapitalOmega]"->"&Omega;",
    "\[CapitalDigamma]"->"&digamma;",
    "\[Alpha]"->"&alpha;",
    "\[Beta]"->"&beta;",
    "\[Gamma]"->"&gamma;",
    "\[Delta]"->"&delta;",
    "\[Epsilon]"->"&varepsilon;",
    "\[CurlyEpsilon]"->"&epsiv;",
    "\[Zeta]"->"&zeta;",
    "\[Eta]"->"&eta;",
    "\[Theta]"->"&theta;",
    "\[CurlyTheta]"->"&vartheta;",
    "\[Iota]"->"&iota;",
    "\[Kappa]"->"&kappa;",
    "\[CurlyKappa]"->"&varkappa;",
    "\[Lambda]"->"&lambda;",
    "\[Mu]"->"&mu;",
    "\[Nu]"->"&nu;",
    "\[Xi]"->"&xi;",
    "\[Omicron]"->"&omicron;",
    "\[Pi]"->"&pi;",
    "\[CurlyPi]"->"&varpi;",
    "\[Rho]"->"&rho;",
    "\[CurlyRho]"->"&varrho;",
    "\[Sigma]"->"&sigma;",
    "\[FinalSigma]"->"&varsigma;",
    "\[Tau]"->"&tau;",
    "\[Upsilon]"->"&upsilon;",
    "\[Phi]"->"&straightphi;",
    "\[CurlyPhi]"->"&varphi;",
    "\[Chi]"->"&chi;",
    "\[Psi]"->"&psi;",
    "\[Omega]"->"&omega;",
    "\[Infinity]"->"&infin;",
    "\[ExponentialE]"->"&ee;",
    "\[ImaginaryI]"->"&ii;",
    "\[ScriptA]"->"&ascr;",
    "\[ScriptB]"->"&bscr;",
    "\[ScriptC]"->"&cscr;",
    "\[ScriptD]"->"&dscr;",
    "\[ScriptE]"->"&escr;",
    "\[ScriptF]"->"&fscr;",
    "\[ScriptG]"->"&gscr;",
    "\[ScriptH]"->"&hscr;",
    "\[ScriptI]"->"&iscr;",
    "\[ScriptJ]"->"&jscr;",
    "\[ScriptK]"->"&kscr;",
    "\[ScriptL]"->"&lscr;",
    "\[ScriptM]"->"&mscr;",
    "\[ScriptN]"->"&nscr;",
    "\[ScriptO]"->"&oscr;",
    "\[ScriptP]"->"&pscr;",
    "\[ScriptQ]"->"&qscr;",
    "\[ScriptR]"->"&rscr;",
    "\[ScriptS]"->"&sscr;",
    "\[ScriptT]"->"&tscr;",
    "\[ScriptU]"->"&uscr;",
    "\[ScriptV]"->"&vscr;",
    "\[ScriptW]"->"&wscr;",
    "\[ScriptX]"->"&xscr;",
    "\[ScriptY]"->"&yscr;",
    "\[ScriptZ]"->"&zscr;",
    "\[ScriptCapitalA]"->"&Ascr;",
    "\[ScriptCapitalB]"->"&Bscr;",
    "\[ScriptCapitalC]"->"&Cscr;",
    "\[ScriptCapitalD]"->"&Dscr;",
    "\[ScriptCapitalE]"->"&Escr;",
    "\[ScriptCapitalF]"->"&Fscr;",
    "\[ScriptCapitalG]"->"&Gscr;",
    "\[ScriptCapitalH]"->"&Hscr;",
    "\[ScriptCapitalI]"->"&Iscr;",
    "\[ScriptCapitalJ]"->"&Jscr;",
    "\[ScriptCapitalK]"->"&Kscr;",
    "\[ScriptCapitalL]"->"&Lscr;",
    "\[ScriptCapitalM]"->"&Mscr;",
    "\[ScriptCapitalN]"->"&Nscr;",
    "\[ScriptCapitalO]"->"&Oscr;",
    "\[ScriptCapitalP]"->"&Pscr;",
    "\[ScriptCapitalQ]"->"&Qscr;",
    "\[ScriptCapitalR]"->"&Rscr;",
    "\[ScriptCapitalS]"->"&Sscr;",
    "\[ScriptCapitalT]"->"&Tscr;",
    "\[ScriptCapitalU]"->"&Uscr;",
    "\[ScriptCapitalV]"->"&Vscr;",
    "\[ScriptCapitalW]"->"&Wscr;",
    "\[ScriptCapitalX]"->"&Xscr;",
    "\[ScriptCapitalY]"->"&Yscr;",
    "\[ScriptCapitalZ]"->"&Zscr;",
    "\[GothicA]"->"&afr;",
    "\[GothicB]"->"&bfr;",
    "\[GothicC]"->"&cfr;",
    "\[GothicD]"->"&dfr;",
    "\[GothicE]"->"&efr;",
    "\[GothicF]"->"&ffr;",
    "\[GothicG]"->"&gfr;",
    "\[GothicH]"->"&hfr;",
    "\[GothicI]"->"&ifr;",
    "\[GothicJ]"->"&jfr;",
    "\[GothicK]"->"&kfr;",
    "\[GothicL]"->"&lfr;",
    "\[GothicM]"->"&mfr;",
    "\[GothicN]"->"&nfr;",
    "\[GothicO]"->"&ofr;",
    "\[GothicP]"->"&pfr;",
    "\[GothicQ]"->"&qfr;",
    "\[GothicR]"->"&rfr;",
    "\[GothicS]"->"&sfr;",
    "\[GothicT]"->"&tfr;",
    "\[GothicU]"->"&ufr;",
    "\[GothicV]"->"&vfr;",
    "\[GothicW]"->"&wfr;",
    "\[GothicX]"->"&xfr;",
    "\[GothicY]"->"&yfr;",
    "\[GothicZ]"->"&zfr;",
    "\[GothicCapitalA]"->"&Afr;",
    "\[GothicCapitalB]"->"&Bfr;",
    "\[GothicCapitalC]"->"&Cfr;",
    "\[GothicCapitalD]"->"&Dfr;",
    "\[GothicCapitalE]"->"&Efr;",
    "\[GothicCapitalF]"->"&Ffr;",
    "\[GothicCapitalG]"->"&Gfr;",
    "\[GothicCapitalH]"->"&Hfr;",
    "\[GothicCapitalI]"->"&Ifr;",
    "\[GothicCapitalJ]"->"&Jfr;",
    "\[GothicCapitalK]"->"&Kfr;",
    "\[GothicCapitalL]"->"&Lfr;",
    "\[GothicCapitalM]"->"&Mfr;",
    "\[GothicCapitalN]"->"&Nfr;",
    "\[GothicCapitalO]"->"&Ofr;",
    "\[GothicCapitalP]"->"&Pfr;",
    "\[GothicCapitalQ]"->"&Qfr;",
    "\[GothicCapitalR]"->"&Rfr;",
    "\[GothicCapitalS]"->"&Sfr;",
    "\[GothicCapitalT]"->"&Tfr;",
    "\[GothicCapitalU]"->"&Ufr;",
    "\[GothicCapitalV]"->"&Vfr;",
    "\[GothicCapitalW]"->"&Wfr;",
    "\[GothicCapitalX]"->"&Xfr;",
    "\[GothicCapitalY]"->"&Yfr;",
    "\[GothicCapitalZ]"->"&Zfr;",
    "\[DoubleStruckA]"->"&aopf;",
    "\[DoubleStruckB]"->"&bopf;",
    "\[DoubleStruckC]"->"&copf;",
    "\[DoubleStruckD]"->"&dopf;",
    "\[DoubleStruckE]"->"&eopf;",
    "\[DoubleStruckF]"->"&fopf;",
    "\[DoubleStruckG]"->"&gopf;",
    "\[DoubleStruckH]"->"&hopf;",
    "\[DoubleStruckI]"->"&iopf;",
    "\[DoubleStruckJ]"->"&jopf;",
    "\[DoubleStruckK]"->"&kopf;",
    "\[DoubleStruckL]"->"&lopf;",
    "\[DoubleStruckM]"->"&mopf;",
    "\[DoubleStruckN]"->"&nopf;",
    "\[DoubleStruckO]"->"&oopf;",
    "\[DoubleStruckP]"->"&popf;",
    "\[DoubleStruckQ]"->"&qopf;",
    "\[DoubleStruckR]"->"&ropf;",
    "\[DoubleStruckS]"->"&sopf;",
    "\[DoubleStruckT]"->"&topf;",
    "\[DoubleStruckU]"->"&uopf;",
    "\[DoubleStruckV]"->"&vopf;",
    "\[DoubleStruckW]"->"&wopf;",
    "\[DoubleStruckX]"->"&xopf;",
    "\[DoubleStruckY]"->"&yopf;",
    "\[DoubleStruckZ]"->"&zopf;",
    "\[DoubleStruckCapitalA]"->"&Aopf;",
    "\[DoubleStruckCapitalB]"->"&Bopf;",
    "\[DoubleStruckCapitalC]"->"&Copf;",
    "\[DoubleStruckCapitalD]"->"&Dopf;",
    "\[DoubleStruckCapitalE]"->"&Eopf;",
    "\[DoubleStruckCapitalF]"->"&Fopf;",
    "\[DoubleStruckCapitalG]"->"&Gopf;",
    "\[DoubleStruckCapitalH]"->"&Hopf;",
    "\[DoubleStruckCapitalI]"->"&Iopf;",
    "\[DoubleStruckCapitalJ]"->"&Jopf;",
    "\[DoubleStruckCapitalK]"->"&Kopf;",
    "\[DoubleStruckCapitalL]"->"&imped;",
    "\[DoubleStruckCapitalM]"->"&Mopf;",
    "\[DoubleStruckCapitalN]"->"&Nopf;",
    "\[DoubleStruckCapitalO]"->"&Oopf;",
    "\[DoubleStruckCapitalP]"->"&Popf;",
    "\[DoubleStruckCapitalQ]"->"&Qopf;",
    "\[DoubleStruckCapitalR]"->"&Ropf;",
    "\[DoubleStruckCapitalS]"->"&Sopf;",
    "\[DoubleStruckCapitalT]"->"&Topf;",
    "\[DoubleStruckCapitalU]"->"&Uopf;",
    "\[DoubleStruckCapitalV]"->"&Vopf;",
    "\[DoubleStruckCapitalW]"->"&Wopf;",
    "\[DoubleStruckCapitalX]"->"&Xopf;",
    "\[DoubleStruckCapitalY]"->"&Yopf;",
    "\[DoubleStruckCapitalZ]"->"&Zopf;",
    "\[WeierstrassP]"->"&wp;",
    "\[Aleph]"->"&aleph;",
    "\[Bet]"->"&beth;",
    "\[Gimel]"->"&gimel;",
    "\[Dalet]"->"&daleth;",
    "\[DownExclamation]"->"&iexcl;",
    "\[Cent]"->"&cent;",
    "\[Sterling]"->"&pound;",
    "\[Currency]"->"&curren;",
    "\[Yen]"->"&yen;",
    "\[Section]"->"&sect;",
    "\[Copyright]"->"&copy;",
    "\[RegisteredTrademark]"->"&reg;",
    "\[Trademark]"->"&trade;",
    "\[Degree]"->"&deg;",
    "\[Micro]"->"&micro;",
    "\[Paragraph]"->"&para;",
    "\[DownQuestion]"->"&iquest;",
    "\[HBar]"->"&hslash;",
    "\[Mho]"->"&mho;",
    "\[Angstrom]"->"&angst;",
    "\[EmptySet]"->"&varnothing;",
    "\[Dash]"->"&ndash;",
    "\[LongDash]"->"&mdash;",
    "\[Dagger]"->"&dagger;",
    "\[DoubleDagger]"->"&ddagger;",
    "\[Bullet]"->"&bullet;",
    "\[DotlessI]"->"&imath;",
    "\[FiLigature]"->"&filig;",
    "\[FlLigature]"->"&fllig;",
    "\[Angle]"->"&angle;",
    "\[RightAngle]"->"&angrt;",
    "\[MeasuredAngle]"->"&measuredangle;",
    "\[SphericalAngle]"->"&angsph;",
    "\[Ellipsis]"->"&hellip;",
    "\[VerticalEllipsis]"->"&vellip;",
    "\[CenterEllipsis]"->"&ctdot;",
    "\[AscendingEllipsis]"->"&utdot;",
    "\[DescendingEllipsis]"->"&dtdot;",
    "\[Prime]"->"&prime;",
    "\[DoublePrime]"->"&Prime;",
    "\[ReversePrime]"->"&backprime;",
    "\[ForAll]"->"&ForAll;",
    "\[Exists]"->"&Exists;",
    "\[NotExists]"->"&NotExists;",
    "\[Element]"->"&Element;",
    "\[NotElement]"->"&NotElement;",
    "\[ReverseElement]"->"&ReverseElement;",
    "\[NotReverseElement]"->"&NotReverseElement;",
    "\[Because]"->"&Because;",
    "\[SuchThat]"->"&SuchThat;",
    "\[VerticalSeparator]"->"&VerticalSeparator;",
    "\[Therefore]"->"&Therefore;",
    "\[Implies]"->"&Implies;",
    "\[RoundImplies]"->"&RoundImplies;",
    "\[Tilde]"->"&Tilde;",
    "\[NotTilde]"->"&NotTilde;",
    "\[EqualTilde]"->"&EqualTilde;",
    "\[TildeEqual]"->"&TildeEqual;",
    "\[NotTildeEqual]"->"&NotTildeEqual;",
    "\[TildeFullEqual]"->"&TildeFullEqual;",
    "\[TildeTilde]"->"&TildeTilde;",
    "\[NotTildeTilde]"->"&NotTildeTilde;",
    "\[NotEqualTilde]"->"&NotEqualTilde;",
    "\[NotTildeFullEqual]"->"&NotTildeFullEqual;",
    "\[LessTilde]"->"&LessTilde;",
    "\[GreaterTilde]"->"&GreaterTilde;",
    "\[NotLessTilde]"->"&NotLessTilde;",
    "\[NotGreaterTilde]"->"&NotGreaterTilde;",
    "\[LeftTriangle]"->"&LeftTriangle;",
    "\[RightTriangle]"->"&RightTriangle;",
    "\[LeftTriangleEqual]"->"&LeftTriangleEqual;",
    "\[RightTriangleEqual]"->"&RightTriangleEqual;",
    "\[LeftTriangleBar]"->"&LeftTriangleBar;",
    "\[RightTriangleBar]"->"&RightTriangleBar;",
    "\[NotLeftTriangleBar]"->"&NotLeftTriangleBar;",
    "\[NotRightTriangleBar]"->"&NotRightTriangleBar;",
    "\[NotLeftTriangle]"->"&NotLeftTriangle;",
    "\[NotLeftTriangleEqual]"->"&NotLeftTriangleEqual;",
    "\[NotRightTriangle]"->"&NotRightTriangle;",
    "\[NotRightTriangleEqual]"->"&NotRightTriangleEqual;",
    "\[NotEqual]"->"&NotEqual;",
    "\[NotLess]"->"&NotLess;",
    "\[NotGreater]"->"&NotGreater;",
    "\[LessEqual]"->"&leq;",
    "\[LessLess]"->"&LessLess;",
    "\[GreaterGreater]"->"&GreaterGreater;",
    "\[NotLessEqual]"->"&NotLessEqual;",
    "\[GreaterEqual]"->"&GreaterEqual;",
    "\[NotGreaterEqual]"->"&NotGreaterEqual;",
    "\[LessSlantEqual]"->"&LessSlantEqual;",
    "\[LessFullEqual]"->"&LessFullEqual;",
    "\[NotLessLess]"->"&NotLessLess;",
    "\[NotNestedLessLess]"->"&NotNestedLessLess;",
    "\[NotLessSlantEqual]"->"&NotLessSlantEqual;",
    "\[NotLessFullEqual]"->"&NotLessFullEqual;",
    "\[NestedLessLess]"->"&NestedLessLess;",
    "\[NestedGreaterGreater]"->"&NestedGreaterGreater;",
    "\[GreaterSlantEqual]"->"&GreaterSlantEqual;",
    "\[GreaterFullEqual]"->"&GreaterFullEqual;",
    "\[NotGreaterGreater]"->"&NotGreaterGreater;",
    "\[NotNestedGreaterGreater]"->"&NotNestedGreaterGreater;",
    "\[NotGreaterSlantEqual]"->"&NotGreaterSlantEqual;",
    "\[NotGreaterFullEqual]"->"&NotGreaterFullEqual;",
    "\[LessGreater]"->"&LessGreater;",
    "\[GreaterLess]"->"&GreaterLess;",
    "\[NotLessGreater]"->"&NotLessGreater;",
    "\[NotGreaterLess]"->"&NotGreaterLess;",
    "\[LessEqualGreater]"->"&LessEqualGreater;",
    "\[GreaterEqualLess]"->"&GreaterEqualLess;",
    "\[Subset]"->"&subset;",
    "\[Superset]"->"&Superset;",
    "\[NotSubset]"->"&NotSubset;",
    "\[NotSuperset]"->"&NotSuperset;",
    "\[SubsetEqual]"->"&SubsetEqual;",
    "\[SupersetEqual]"->"&SupersetEqual;",
    "\[NotSubsetEqual]"->"&NotSubsetEqual;",
    "\[NotSupersetEqual]"->"&NotSupersetEqual;",
    "\[SquareSubset]"->"&SquareSubset;",
    "\[SquareSuperset]"->"&SquareSuperset;",
    "\[SquareSubsetEqual]"->"&SquareSubsetEqual;",
    "\[SquareSupersetEqual]"->"&SquareSupersetEqual;",
    "\[NotSquareSubset]"->"&NotSquareSubset;",
    "\[NotSquareSuperset]"->"&NotSquareSuperset;",
    "\[NotSquareSubsetEqual]"->"&NotSquareSubsetEqual;",
    "\[NotSquareSupersetEqual]"->"&NotSquareSupersetEqual;",
    "\[Precedes]"->"&Precedes;",
    "\[Succeeds]"->"&Succeeds;",
    "\[PrecedesEqual]"->"&PrecedesEqual;",
    "\[SucceedsEqual]"->"&SucceedsEqual;",
    "\[PrecedesTilde]"->"&PrecedesTilde;",
    "\[SucceedsTilde]"->"&SucceedsTilde;",
    "\[NotPrecedes]"->"&NotPrecedes;",
    "\[NotSucceeds]"->"&NotSucceeds;",
    "\[PrecedesSlantEqual]"->"&PrecedesSlantEqual;",
    "\[NotPrecedesEqual]"->"&NotPrecedesEqual;",
    "\[NotPrecedesSlantEqual]"->"&NotPrecedesSlantEqual;",
    "\[NotPrecedesTilde]"->"&NotPrecedesTilde;",
    "\[SucceedsSlantEqual]"->"&SucceedsSlantEqual;",
    "\[NotSucceedsEqual]"->"&NotSucceedsEqual;",
    "\[NotSucceedsSlantEqual]"->"&NotSucceedsSlantEqual;",
    "\[NotSucceedsTilde]"->"&NotSucceedsTilde;",
    "\[UpTee]"->"&UpTee;",
    "\[Proportional]"->"&Proportional;",
    "\[Proportion]"->"&Proportion;",
    "\[Congruent]"->"&Congruent;",
    "\[NotCongruent]"->"&NotCongruent;",
    "\[CupCap]"->"&CupCap;",
    "\[NotCupCap]"->"&NotCupCap;",
    "\[Equilibrium]"->"&Equilibrium;",
    "\[ReverseEquilibrium]"->"&ReverseEquilibrium;",
    "\[UpEquilibrium]"->"&UpEquilibrium;",
    "\[ReverseUpEquilibrium]"->"&ReverseUpEquilibrium;",
    "\[RightTee]"->"&RightTee;",
    "\[LeftTee]"->"&LeftTee;",
    "\[DownTee]"->"&DownTee;",
    "\[DoubleRightTee]"->"&DoubleRightTee;",
    "\[DoubleLeftTee]"->"&DoubleLeftTee;",
    "\[HumpEqual]"->"&HumpEqual;",
    "\[NotHumpEqual]"->"&NotHumpEqual;",
    "\[HumpDownHump]"->"&HumpDownHump;",
    "\[NotHumpDownHump]"->"&NotHumpDownHump;",
    "\[DotEqual]"->"&DotEqual;",
    "\[Colon]"->"&colon;",
    "\[Equal]"->"&Equal;",
    "\[Sqrt]"->"&Sqrt;",
    "\[Divides]"->"&Divides;",
    "\[DoubleVerticalBar]"->"&DoubleVerticalBar;",
    "\[NotDoubleVerticalBar]"->"&NotDoubleVerticalBar;",
    "\[Not]"->"&not;",
    "\[VerticalTilde]"->"&VerticalTilde;",
    "\[Times]"->"&times;",
    "\[PlusMinus]"->"&PlusMinus;",
    "\[MinusPlus]"->"&MinusPlus;",
    "\[Minus]"->"&minus;",
    "\[Divide]"->"&div;",
    "\[CenterDot]"->"&CenterDot;",
    "\[SmallCircle]"->"&SmallCircle;",
    "\[Cross]"->"&Cross;",
    "\[CirclePlus]"->"&CirclePlus;",
    "\[CircleMinus]"->"&CircleMinus;",
    "\[CircleTimes]"->"&CircleTimes;",
    "\[CircleDot]"->"&CircleDot;",
    "\[Star]"->"&Star;",
    "\[Square]"->"&Square;",
    "\[Diamond]"->"&Diamond;",
    "\[Del]"->"&Del;",
    "\[Backslash]"->"&Backslash;",
    "\[Cap]"->"&frown;",
    "\[Cup]"->"&smile;",
    "\[Coproduct]"->"&Coproduct;",
    "\[Integral]"->"&Integral;",
    "\[ContourIntegral]"->"&ContourIntegral;",
    "\[DoubleContourIntegral]"->"&DoubleContourIntegral;",
    "\[CounterClockwiseContourIntegral]"->"&CounterClockwiseContourIntegral;",
    "\[ClockwiseContourIntegral]"->"&ClockwiseContourIntegral;",
    "\[Sum]"->"&Sum;",
    "\[Product]"->"&Product;",
    "\[Intersection]"->"&Intersection;",
    "\[Union]"->"&Union;",
    "\[UnionPlus]"->"&UnionPlus;",
    "\[SquareIntersection]"->"&SquareIntersection;",
    "\[SquareUnion]"->"&SquareUnion;",
    "\[Wedge]"->"&Wedge;",
    "\[And]"->"&&$   $&and;",
    "\[Nand]"->"&&$   $&barwed;",
    "\[Vee]"->"&Vee;",
    "\[Or]"->"&or;",
    "\[Nor]"->"&barvee;",
    "\[Xor]"->"&veebar;",
    "\[PartialD]"->"&PartialD;",
    "\[DifferentialD]"->"&dd;",
    "\[CapitalDifferentialD]"->"&CapitalDifferentialD;",
    "\[RightArrow]"->"&RightArrow;",
    "\[LeftArrow]"->"&LeftArrow;",
    "\[UpArrow]"->"&UpArrow;",
    "\[DownArrow]"->"&DownArrow;",
    "\[LeftRightArrow]"->"&LeftRightArrow;",
    "\[UpDownArrow]"->"&UpDownArrow;",
    "\[ShortRightArrow]"->"&ShortRightArrow;",
    "\[ShortLeftArrow]"->"&ShortLeftArrow;",
    "\[ShortUpArrow]"->"&ShortUpArrow;",
    "\[ShortDownArrow]"->"&ShortDownArrow;",
    "\[RuleDelayed]"->"&RuleDelayed;",
    "\[DoubleRightArrow]"->"&DoubleRightArrow;",
    "\[DoubleLeftArrow]"->"&DoubleLeftArrow;",
    "\[DoubleUpArrow]"->"&DoubleUpArrow;",
    "\[DoubleDownArrow]"->"&DoubleDownArrow;",
    "\[DoubleLeftRightArrow]"->"&DoubleLeftRightArrow;",
    "\[DoubleUpDownArrow]"->"&DoubleUpDownArrow;",
    "\[RightArrowBar]"->"&RightArrowBar;",
    "\[LeftArrowBar]"->"&LeftArrowBar;",
    "\[UpArrowBar]"->"&UpArrowBar;",
    "\[DownArrowBar]"->"&DownArrowBar;",
    "\[RightTeeArrow]"->"&RightTeeArrow;",
    "\[LeftTeeArrow]"->"&LeftTeeArrow;",
    "\[UpTeeArrow]"->"&UpTeeArrow;",
    "\[DownTeeArrow]"->"&DownTeeArrow;",
    "\[UpperLeftArrow]"->"&UpperLeftArrow;",
    "\[UpperRightArrow]"->"&UpperRightArrow;",
    "\[LowerRightArrow]"->"&LowerRightArrow;",
    "\[LowerLeftArrow]"->"&LowerLeftArrow;",
    "\[LongRightArrow]"->"&LongRightArrow;",
    "\[LongLeftArrow]"->"&LongLeftArrow;",
    "\[DoubleLongLeftArrow]"->"&DoubleLongLeftArrow;",
    "\[DoubleLongRightArrow]"->"&DoubleLongRightArrow;",
    "\[LongLeftRightArrow]"->"&LongLeftRightArrow;",
    "\[DoubleLongLeftRightArrow]"->"&DoubleLongLeftRightArrow;",
    "\[RightArrowLeftArrow]"->"&RightArrowLeftArrow;",
    "\[LeftArrowRightArrow]"->"&LeftArrowRightArrow;",
    "\[UpArrowDownArrow]"->"&UpArrowDownArrow;",
    "\[DownArrowUpArrow]"->"&DownArrowUpArrow;",
    "\[RightVector]"->"&RightVector;",
    "\[DownRightVector]"->"&DownRightVector;",
    "\[LeftVector]"->"&LeftVector;",
    "\[DownLeftVector]"->"&DownLeftVector;",
    "\[RightUpVector]"->"&RightUpVector;",
    "\[LeftUpVector]"->"&LeftUpVector;",
    "\[RightDownVector]"->"&RightDownVector;",
    "\[LeftDownVector]"->"&LeftDownVector;",
    "\[LeftRightVector]"->"&LeftRightVector;",
    "\[DownLeftRightVector]"->"&DownLeftRightVector;",
    "\[RightUpDownVector]"->"&RightUpDownVector;",
    "\[LeftUpDownVector]"->"&LeftUpDownVector;",
    "\[RightVectorBar]"->"&RightVectorBar;",
    "\[DownRightVectorBar]"->"&DownRightVectorBar;",
    "\[LeftVectorBar]"->"&LeftVectorBar;",
    "\[DownLeftVectorBar]"->"&DownLeftVectorBar;",
    "\[RightUpVectorBar]"->"&RightUpVectorBar;",
    "\[LeftUpVectorBar]"->"&LeftUpVectorBar;",
    "\[RightDownVectorBar]"->"&RightDownVectorBar;",
    "\[LeftDownVectorBar]"->"&LeftDownVectorBar;",
    "\[RightTeeVector]"->"&RightTeeVector;",
    "\[DownRightTeeVector]"->"&DownRightTeeVector;",
    "\[LeftTeeVector]"->"&LeftTeeVector;",
    "\[DownLeftTeeVector]"->"&DownLeftTeeVector;",
    "\[RightUpTeeVector]"->"&RightUpTeeVector;",
    "\[LeftUpTeeVector]"->"&LeftUpTeeVector;",
    "\[RightDownTeeVector]"->"&RightDownTeeVector;",
    "\[LeftDownTeeVector]"->"&LeftDownTeeVector;",
    "\[LeftDoubleBracket]"->"&LeftDoubleBracket;",
    "\[RightDoubleBracket]"->"&RightDoubleBracket;",
    "\[LeftAngleBracket]"->"&LeftAngleBracket;",
    "\[RightAngleBracket]"->"&RightAngleBracket;",
    "\[LeftFloor]"->"&LeftFloor;",
    "\[RightFloor]"->"&RightFloor;",
    "\[LeftCeiling]"->"&LeftCeiling;",
    "\[RightCeiling]"->"&RightCeiling;",
    "\[LeftBracketingBar]"->"&LeftBracketingBar;",
    "\[RightBracketingBar]"->"&RightBracketingBar;",
    "\[LeftDoubleBracketingBar]"->"&LeftDoubleBracketingBar;",
    "\[RightDoubleBracketingBar]"->"&RightDoubleBracketingBar;",
    "\[EmptyCircle]"->"&bigcirc;",
    "\[FilledRectangle]"->"&marker;",
    "\[EmptySquare]"->"&squ;",
    "\[EmptyVerySmallSquare]"->"&EmptyVerySmallSquare;",
    "\[FilledSmallSquare]"->"&squarf;",
    "\[FilledVerySmallSquare]"->"&FilledVerySmallSquare;",
    "\[EmptyUpTriangle]"->"&bigtriangleup;",
    "\[EmptyDownTriangle]"->"&bigtriangledown;",
    "\[FivePointedStar]"->"&bigstar;",
    "\[SixPointedStar]"->"&sext;",
    "\[SpadeSuit]"->"&spadesuit;",
    "\[HeartSuit]"->"&heartsuit;",
    "\[DiamondSuit]"->"&diamondsuit;",
    "\[ClubSuit]"->"&clubsuit;",
    "\[Flat]"->"&flat;",
    "\[Natural]"->"&natural;",
    "\[Sharp]"->"&sharp;",
    "\[NumberSign]"->"&num;",
    "\[InvisibleSpace]"->"&ZeroWidthSpace;",
    "\[VeryThinSpace]"->"&VeryThinSpace;",
    "\[ThinSpace]"->"&ThinSpace;",
    "\[ThickSpace]"->"&ThickSpace;",
    "\[NegativeVeryThinSpace]"->"&NegativeVeryThinSpace;",
    "\[NegativeThinSpace]"->"&NegativeThinSpace;",
    "\[NegativeMediumSpace]"->"&NegativeMediumSpace;",
    "\[NegativeThickSpace]"->"&NegativeThickSpace;",
    "\[OpenCurlyQuote]"->"&OpenCurlyQuote;",
    "\[CloseCurlyQuote]"->"&CloseCurlyQuote;",
    "\[OpenCurlyDoubleQuote]"->"&OpenCurlyDoubleQuote;",
    "\[CloseCurlyDoubleQuote]"->"&CloseCurlyDoubleQuote;",
    "\[OverParenthesis]"->"&OverParenthesis;",
    "\[UnderParenthesis]"->"&UnderParenthesis;",
    "\[OverBrace]"->"&OverBrace;",
    "\[UnderBrace]"->"&UnderBrace;",
    "\[OverBracket]"->"&OverBracket;",
    "\[UnderBracket]"->"&UnderBracket;",
    "\[IndentingNewLine]"->"&IndentingNewLine;",
    "\[NoBreak]"->"&NoBreak;",
    "\[NonBreakingSpace]"->"&nbsp;",
    "\[SpaceIndicator]"->"&blank;",
    "\[InvisibleApplication]"->"&af;",
    "\[ReturnIndicator]"->"&crarr;",
    "\[HorizontalLine]"->"&HorizontalLine;",
    "\[VerticalLine]"->"&VerticalLine;",
    "\[InvisibleComma]"->"&ic;",
    "\[SkeletonIndicator]"->"&hybull;",
    "\[LeftSkeleton]"->"&LeftSkeleton;",
    "\[RightSkeleton]"->"&RightSkeleton;",
    "\[Piecewise]"->"&piecewise;",
    "\[VerticalBar]"->"&VerticalBar;",
    "\[NotVerticalBar]"->"&NotVerticalBar;"
    };


(* ::Subsubsubsection::Closed:: *)
(*LongToUnicode*)



$NotebookToMarkdownLongToUnicodeReplacements=
  <|
    "\\[LeftGuillemet]"->"\[LeftGuillemet]",
    "\\[DiscretionaryHyphen]"->"\[DiscretionaryHyphen]",
    "\\[RightGuillemet]"->"\[RightGuillemet]",
    "\\[CapitalAGrave]"->"\[CapitalAGrave]",
    "\\[CapitalAAcute]"->"\[CapitalAAcute]",
    "\\[CapitalAHat]"->"\[CapitalAHat]",
    "\\[CapitalATilde]"->"\[CapitalATilde]",
    "\\[CapitalADoubleDot]"->"\[CapitalADoubleDot]",
    "\\[CapitalARing]"->"\[CapitalARing]",
    "\\[CapitalAE]"->"\[CapitalAE]",
    "\\[CapitalCCedilla]"->"\[CapitalCCedilla]",
    "\\[CapitalEGrave]"->"\[CapitalEGrave]",
    "\\[CapitalEAcute]"->"\[CapitalEAcute]",
    "\\[CapitalEHat]"->"\[CapitalEHat]",
    "\\[CapitalEDoubleDot]"->"\[CapitalEDoubleDot]",
    "\\[CapitalIGrave]"->"\[CapitalIGrave]",
    "\\[CapitalIAcute]"->"\[CapitalIAcute]",
    "\\[CapitalIHat]"->"\[CapitalIHat]",
    "\\[CapitalIDoubleDot]"->"\[CapitalIDoubleDot]",
    "\\[CapitalEth]"->"\[CapitalEth]",
    "\\[CapitalNTilde]"->"\[CapitalNTilde]",
    "\\[CapitalOGrave]"->"\[CapitalOGrave]",
    "\\[CapitalOAcute]"->"\[CapitalOAcute]",
    "\\[CapitalOE]"->"\[CapitalOE]",
    "\\[CapitalOHat]"->"\[CapitalOHat]",
    "\\[CapitalOTilde]"->"\[CapitalOTilde]",
    "\\[CapitalODoubleDot]"->"\[CapitalODoubleDot]",
    "\\[CapitalOSlash]"->"\[CapitalOSlash]",
    "\\[CapitalUGrave]"->"\[CapitalUGrave]",
    "\\[CapitalUAcute]"->"\[CapitalUAcute]",
    "\\[CapitalUHat]"->"\[CapitalUHat]",
    "\\[CapitalUDoubleDot]"->"\[CapitalUDoubleDot]",
    "\\[CapitalYAcute]"->"\[CapitalYAcute]",
    "\\[CapitalThorn]"->"\[CapitalThorn]",
    "\\[SZ]"->"\[SZ]",
    "\\[AGrave]"->"\[AGrave]",
    "\\[AAcute]"->"\[AAcute]",
    "\\[AHat]"->"\[AHat]",
    "\\[ATilde]"->"\[ATilde]",
    "\\[ADoubleDot]"->"\[ADoubleDot]",
    "\\[ARing]"->"\[ARing]",
    "\\[AE]"->"\[AE]",
    "\\[CCedilla]"->"\[CCedilla]",
    "\\[EGrave]"->"\[EGrave]",
    "\\[EAcute]"->"\[EAcute]",
    "\\[EHat]"->"\[EHat]",
    "\\[EDoubleDot]"->"\[EDoubleDot]",
    "\\[IGrave]"->"\[IGrave]",
    "\\[IAcute]"->"\[IAcute]",
    "\\[IHat]"->"\[IHat]",
    "\\[IDoubleDot]"->"\[IDoubleDot]",
    "\\[Eth]"->"\[Eth]",
    "\\[NTilde]"->"\[NTilde]",
    "\\[OGrave]"->"\[OGrave]",
    "\\[OAcute]"->"\[OAcute]",
    "\\[OE]"->"\[OE]",
    "\\[OHat]"->"\[OHat]",
    "\\[OTilde]"->"\[OTilde]",
    "\\[ODoubleDot]"->"\[ODoubleDot]",
    "\\[OSlash]"->"\[OSlash]",
    "\\[UGrave]"->"\[UGrave]",
    "\\[UAcute]"->"\[UAcute]",
    "\\[UHat]"->"\[UHat]",
    "\\[UDoubleDot]"->"\[UDoubleDot]",
    "\\[YAcute]"->"\[YAcute]",
    "\\[Thorn]"->"\[Thorn]",
    "\\[YDoubleDot]"->"\[YDoubleDot]",
    "\\[ABar]"->"\[ABar]",
    "\\[CapitalABar]"->"\[CapitalABar]",
    "\\[ACup]"->"\[ACup]",
    "\\[CapitalACup]"->"\[CapitalACup]",
    "\\[CAcute]"->"\[CAcute]",
    "\\[CapitalCAcute]"->"\[CapitalCAcute]",
    "\\[CHacek]"->"\[CHacek]",
    "\\[CapitalCHacek]"->"\[CapitalCHacek]",
    "\\[DHacek]"->"\[DHacek]",
    "\\[CapitalDHacek]"->"\[CapitalDHacek]",
    "\\[EHacek]"->"\[EHacek]",
    "\\[CapitalEHacek]"->"\[CapitalEHacek]",
    "\\[NHacek]"->"\[NHacek]",
    "\\[CapitalNHacek]"->"\[CapitalNHacek]",
    "\\[RHacek]"->"\[RHacek]",
    "\\[CapitalRHacek]"->"\[CapitalRHacek]",
    "\\[THacek]"->"\[THacek]",
    "\\[CapitalTHacek]"->"\[CapitalTHacek]",
    "\\[URing]"->"\[URing]",
    "\\[CapitalURing]"->"\[CapitalURing]",
    "\\[ZHacek]"->"\[ZHacek]",
    "\\[CapitalZHacek]"->"\[CapitalZHacek]",
    "\\[EBar]"->"\[EBar]",
    "\\[CapitalEBar]"->"\[CapitalEBar]",
    "\\[LSlash]"->"\[LSlash]",
    "\\[CapitalLSlash]"->"\[CapitalLSlash]",
    "\\[ODoubleAcute]"->"\[ODoubleAcute]",
    "\\[CapitalODoubleAcute]"->"\[CapitalODoubleAcute]",
    "\\[SHacek]"->"\[SHacek]",
    "\\[CapitalSHacek]"->"\[CapitalSHacek]",
    "\\[UDoubleAcute]"->"\[UDoubleAcute]",
    "\\[CapitalUDoubleAcute]"->"\[CapitalUDoubleAcute]",
    "\\[Florin]"->"\[Florin]",
    "\\[Breve]"->"\[Breve]",
    "\\[DoubleDot]"->"\[DoubleDot]",
    "\\[TripleDot]"->"\[TripleDot]",
    "\\[Hacek]"->"\[Hacek]",
    "\\[DownBreve]"->"\[DownBreve]",
    "\\[Cedilla]"->"\[Cedilla]",
    "\\[CapitalAlpha]"->"\[CapitalAlpha]",
    "\\[CapitalBeta]"->"\[CapitalBeta]",
    "\\[CapitalGamma]"->"\[CapitalGamma]",
    "\\[CapitalDelta]"->"\[CapitalDelta]",
    "\\[CapitalEpsilon]"->"\[CapitalEpsilon]",
    "\\[CapitalZeta]"->"\[CapitalZeta]",
    "\\[CapitalEta]"->"\[CapitalEta]",
    "\\[CapitalTheta]"->"\[CapitalTheta]",
    "\\[CapitalIota]"->"\[CapitalIota]",
    "\\[CapitalKappa]"->"\[CapitalKappa]",
    "\\[CapitalLambda]"->"\[CapitalLambda]",
    "\\[CapitalMu]"->"\[CapitalMu]",
    "\\[CapitalNu]"->"\[CapitalNu]",
    "\\[CapitalXi]"->"\[CapitalXi]",
    "\\[CapitalOmicron]"->"\[CapitalOmicron]",
    "\\[CapitalPi]"->"\[CapitalPi]",
    "\\[CapitalRho]"->"\[CapitalRho]",
    "\\[CapitalSigma]"->"\[CapitalSigma]",
    "\\[CapitalTau]"->"\[CapitalTau]",
    "\\[CapitalUpsilon]"->"\[CapitalUpsilon]",
    "\\[CurlyCapitalUpsilon]"->"\[CurlyCapitalUpsilon]",
    "\\[CapitalPhi]"->"\[CapitalPhi]",
    "\\[CapitalChi]"->"\[CapitalChi]",
    "\\[CapitalPsi]"->"\[CapitalPsi]",
    "\\[CapitalOmega]"->"\[CapitalOmega]",
    "\\[CapitalDigamma]"->"\[CapitalDigamma]",
    "\\[Alpha]"->"\[Alpha]",
    "\\[Beta]"->"\[Beta]",
    "\\[Gamma]"->"\[Gamma]",
    "\\[Delta]"->"\[Delta]",
    "\\[Epsilon]"->"\[Epsilon]",
    "\\[CurlyEpsilon]"->"\[CurlyEpsilon]",
    "\\[Zeta]"->"\[Zeta]",
    "\\[Eta]"->"\[Eta]",
    "\\[Theta]"->"\[Theta]",
    "\\[CurlyTheta]"->"\[CurlyTheta]",
    "\\[Iota]"->"\[Iota]",
    "\\[Kappa]"->"\[Kappa]",
    "\\[CurlyKappa]"->"\[CurlyKappa]",
    "\\[Lambda]"->"\[Lambda]",
    "\\[Mu]"->"\[Mu]",
    "\\[Nu]"->"\[Nu]",
    "\\[Xi]"->"\[Xi]",
    "\\[Omicron]"->"\[Omicron]",
    "\\[Pi]"->"\[Pi]",
    "\\[CurlyPi]"->"\[CurlyPi]",
    "\\[Rho]"->"\[Rho]",
    "\\[CurlyRho]"->"\[CurlyRho]",
    "\\[Sigma]"->"\[Sigma]",
    "\\[FinalSigma]"->"\[FinalSigma]",
    "\\[Tau]"->"\[Tau]",
    "\\[Upsilon]"->"\[Upsilon]",
    "\\[Phi]"->"\[Phi]",
    "\\[CurlyPhi]"->"\[CurlyPhi]",
    "\\[Chi]"->"\[Chi]",
    "\\[Psi]"->"\[Psi]",
    "\\[Omega]"->"\[Omega]",
    "\\[Infinity]"->"\[Infinity]",
    "\\[ExponentialE]"->"\[ExponentialE]",
    "\\[ImaginaryI]"->"\[ImaginaryI]",
    "\\[ScriptA]"->"\[ScriptA]",
    "\\[ScriptB]"->"\[ScriptB]",
    "\\[ScriptC]"->"\[ScriptC]",
    "\\[ScriptD]"->"\[ScriptD]",
    "\\[ScriptE]"->"\[ScriptE]",
    "\\[ScriptF]"->"\[ScriptF]",
    "\\[ScriptG]"->"\[ScriptG]",
    "\\[ScriptH]"->"\[ScriptH]",
    "\\[ScriptI]"->"\[ScriptI]",
    "\\[ScriptJ]"->"\[ScriptJ]",
    "\\[ScriptK]"->"\[ScriptK]",
    "\\[ScriptL]"->"\[ScriptL]",
    "\\[ScriptM]"->"\[ScriptM]",
    "\\[ScriptN]"->"\[ScriptN]",
    "\\[ScriptO]"->"\[ScriptO]",
    "\\[ScriptP]"->"\[ScriptP]",
    "\\[ScriptQ]"->"\[ScriptQ]",
    "\\[ScriptR]"->"\[ScriptR]",
    "\\[ScriptS]"->"\[ScriptS]",
    "\\[ScriptT]"->"\[ScriptT]",
    "\\[ScriptU]"->"\[ScriptU]",
    "\\[ScriptV]"->"\[ScriptV]",
    "\\[ScriptW]"->"\[ScriptW]",
    "\\[ScriptX]"->"\[ScriptX]",
    "\\[ScriptY]"->"\[ScriptY]",
    "\\[ScriptZ]"->"\[ScriptZ]",
    "\\[ScriptCapitalA]"->"\[ScriptCapitalA]",
    "\\[ScriptCapitalB]"->"\[ScriptCapitalB]",
    "\\[ScriptCapitalC]"->"\[ScriptCapitalC]",
    "\\[ScriptCapitalD]"->"\[ScriptCapitalD]",
    "\\[ScriptCapitalE]"->"\[ScriptCapitalE]",
    "\\[ScriptCapitalF]"->"\[ScriptCapitalF]",
    "\\[ScriptCapitalG]"->"\[ScriptCapitalG]",
    "\\[ScriptCapitalH]"->"\[ScriptCapitalH]",
    "\\[ScriptCapitalI]"->"\[ScriptCapitalI]",
    "\\[ScriptCapitalJ]"->"\[ScriptCapitalJ]",
    "\\[ScriptCapitalK]"->"\[ScriptCapitalK]",
    "\\[ScriptCapitalL]"->"\[ScriptCapitalL]",
    "\\[ScriptCapitalM]"->"\[ScriptCapitalM]",
    "\\[ScriptCapitalN]"->"\[ScriptCapitalN]",
    "\\[ScriptCapitalO]"->"\[ScriptCapitalO]",
    "\\[ScriptCapitalP]"->"\[ScriptCapitalP]",
    "\\[ScriptCapitalQ]"->"\[ScriptCapitalQ]",
    "\\[ScriptCapitalR]"->"\[ScriptCapitalR]",
    "\\[ScriptCapitalS]"->"\[ScriptCapitalS]",
    "\\[ScriptCapitalT]"->"\[ScriptCapitalT]",
    "\\[ScriptCapitalU]"->"\[ScriptCapitalU]",
    "\\[ScriptCapitalV]"->"\[ScriptCapitalV]",
    "\\[ScriptCapitalW]"->"\[ScriptCapitalW]",
    "\\[ScriptCapitalX]"->"\[ScriptCapitalX]",
    "\\[ScriptCapitalY]"->"\[ScriptCapitalY]",
    "\\[ScriptCapitalZ]"->"\[ScriptCapitalZ]",
    "\\[GothicA]"->"\[GothicA]",
    "\\[GothicB]"->"\[GothicB]",
    "\\[GothicC]"->"\[GothicC]",
    "\\[GothicD]"->"\[GothicD]",
    "\\[GothicE]"->"\[GothicE]",
    "\\[GothicF]"->"\[GothicF]",
    "\\[GothicG]"->"\[GothicG]",
    "\\[GothicH]"->"\[GothicH]",
    "\\[GothicI]"->"\[GothicI]",
    "\\[GothicJ]"->"\[GothicJ]",
    "\\[GothicK]"->"\[GothicK]",
    "\\[GothicL]"->"\[GothicL]",
    "\\[GothicM]"->"\[GothicM]",
    "\\[GothicN]"->"\[GothicN]",
    "\\[GothicO]"->"\[GothicO]",
    "\\[GothicP]"->"\[GothicP]",
    "\\[GothicQ]"->"\[GothicQ]",
    "\\[GothicR]"->"\[GothicR]",
    "\\[GothicS]"->"\[GothicS]",
    "\\[GothicT]"->"\[GothicT]",
    "\\[GothicU]"->"\[GothicU]",
    "\\[GothicV]"->"\[GothicV]",
    "\\[GothicW]"->"\[GothicW]",
    "\\[GothicX]"->"\[GothicX]",
    "\\[GothicY]"->"\[GothicY]",
    "\\[GothicZ]"->"\[GothicZ]",
    "\\[GothicCapitalA]"->"\[GothicCapitalA]",
    "\\[GothicCapitalB]"->"\[GothicCapitalB]",
    "\\[GothicCapitalC]"->"\[GothicCapitalC]",
    "\\[GothicCapitalD]"->"\[GothicCapitalD]",
    "\\[GothicCapitalE]"->"\[GothicCapitalE]",
    "\\[GothicCapitalF]"->"\[GothicCapitalF]",
    "\\[GothicCapitalG]"->"\[GothicCapitalG]",
    "\\[GothicCapitalH]"->"\[GothicCapitalH]",
    "\\[GothicCapitalI]"->"\[GothicCapitalI]",
    "\\[GothicCapitalJ]"->"\[GothicCapitalJ]",
    "\\[GothicCapitalK]"->"\[GothicCapitalK]",
    "\\[GothicCapitalL]"->"\[GothicCapitalL]",
    "\\[GothicCapitalM]"->"\[GothicCapitalM]",
    "\\[GothicCapitalN]"->"\[GothicCapitalN]",
    "\\[GothicCapitalO]"->"\[GothicCapitalO]",
    "\\[GothicCapitalP]"->"\[GothicCapitalP]",
    "\\[GothicCapitalQ]"->"\[GothicCapitalQ]",
    "\\[GothicCapitalR]"->"\[GothicCapitalR]",
    "\\[GothicCapitalS]"->"\[GothicCapitalS]",
    "\\[GothicCapitalT]"->"\[GothicCapitalT]",
    "\\[GothicCapitalU]"->"\[GothicCapitalU]",
    "\\[GothicCapitalV]"->"\[GothicCapitalV]",
    "\\[GothicCapitalW]"->"\[GothicCapitalW]",
    "\\[GothicCapitalX]"->"\[GothicCapitalX]",
    "\\[GothicCapitalY]"->"\[GothicCapitalY]",
    "\\[GothicCapitalZ]"->"\[GothicCapitalZ]",
    "\\[DoubleStruckA]"->"\[DoubleStruckA]",
    "\\[DoubleStruckB]"->"\[DoubleStruckB]",
    "\\[DoubleStruckC]"->"\[DoubleStruckC]",
    "\\[DoubleStruckD]"->"\[DoubleStruckD]",
    "\\[DoubleStruckE]"->"\[DoubleStruckE]",
    "\\[DoubleStruckF]"->"\[DoubleStruckF]",
    "\\[DoubleStruckG]"->"\[DoubleStruckG]",
    "\\[DoubleStruckH]"->"\[DoubleStruckH]",
    "\\[DoubleStruckI]"->"\[DoubleStruckI]",
    "\\[DoubleStruckJ]"->"\[DoubleStruckJ]",
    "\\[DoubleStruckK]"->"\[DoubleStruckK]",
    "\\[DoubleStruckL]"->"\[DoubleStruckL]",
    "\\[DoubleStruckM]"->"\[DoubleStruckM]",
    "\\[DoubleStruckN]"->"\[DoubleStruckN]",
    "\\[DoubleStruckO]"->"\[DoubleStruckO]",
    "\\[DoubleStruckP]"->"\[DoubleStruckP]",
    "\\[DoubleStruckQ]"->"\[DoubleStruckQ]",
    "\\[DoubleStruckR]"->"\[DoubleStruckR]",
    "\\[DoubleStruckS]"->"\[DoubleStruckS]",
    "\\[DoubleStruckT]"->"\[DoubleStruckT]",
    "\\[DoubleStruckU]"->"\[DoubleStruckU]",
    "\\[DoubleStruckV]"->"\[DoubleStruckV]",
    "\\[DoubleStruckW]"->"\[DoubleStruckW]",
    "\\[DoubleStruckX]"->"\[DoubleStruckX]",
    "\\[DoubleStruckY]"->"\[DoubleStruckY]",
    "\\[DoubleStruckZ]"->"\[DoubleStruckZ]",
    "\\[DoubleStruckCapitalA]"->"\[DoubleStruckCapitalA]",
    "\\[DoubleStruckCapitalB]"->"\[DoubleStruckCapitalB]",
    "\\[DoubleStruckCapitalC]"->"\[DoubleStruckCapitalC]",
    "\\[DoubleStruckCapitalD]"->"\[DoubleStruckCapitalD]",
    "\\[DoubleStruckCapitalE]"->"\[DoubleStruckCapitalE]",
    "\\[DoubleStruckCapitalF]"->"\[DoubleStruckCapitalF]",
    "\\[DoubleStruckCapitalG]"->"\[DoubleStruckCapitalG]",
    "\\[DoubleStruckCapitalH]"->"\[DoubleStruckCapitalH]",
    "\\[DoubleStruckCapitalI]"->"\[DoubleStruckCapitalI]",
    "\\[DoubleStruckCapitalJ]"->"\[DoubleStruckCapitalJ]",
    "\\[DoubleStruckCapitalK]"->"\[DoubleStruckCapitalK]",
    "\\[DoubleStruckCapitalL]"->"\[DoubleStruckCapitalL]",
    "\\[DoubleStruckCapitalM]"->"\[DoubleStruckCapitalM]",
    "\\[DoubleStruckCapitalN]"->"\[DoubleStruckCapitalN]",
    "\\[DoubleStruckCapitalO]"->"\[DoubleStruckCapitalO]",
    "\\[DoubleStruckCapitalP]"->"\[DoubleStruckCapitalP]",
    "\\[DoubleStruckCapitalQ]"->"\[DoubleStruckCapitalQ]",
    "\\[DoubleStruckCapitalR]"->"\[DoubleStruckCapitalR]",
    "\\[DoubleStruckCapitalS]"->"\[DoubleStruckCapitalS]",
    "\\[DoubleStruckCapitalT]"->"\[DoubleStruckCapitalT]",
    "\\[DoubleStruckCapitalU]"->"\[DoubleStruckCapitalU]",
    "\\[DoubleStruckCapitalV]"->"\[DoubleStruckCapitalV]",
    "\\[DoubleStruckCapitalW]"->"\[DoubleStruckCapitalW]",
    "\\[DoubleStruckCapitalX]"->"\[DoubleStruckCapitalX]",
    "\\[DoubleStruckCapitalY]"->"\[DoubleStruckCapitalY]",
    "\\[DoubleStruckCapitalZ]"->"\[DoubleStruckCapitalZ]",
    "\\[WeierstrassP]"->"\[WeierstrassP]",
    "\\[Aleph]"->"\[Aleph]",
    "\\[Bet]"->"\[Bet]",
    "\\[Gimel]"->"\[Gimel]",
    "\\[Dalet]"->"\[Dalet]",
    "\\[DownExclamation]"->"\[DownExclamation]",
    "\\[Cent]"->"\[Cent]",
    "\\[Sterling]"->"\[Sterling]",
    "\\[Currency]"->"\[Currency]",
    "\\[Yen]"->"\[Yen]",
    "\\[Section]"->"\[Section]",
    "\\[Copyright]"->"\[Copyright]",
    "\\[RegisteredTrademark]"->"\[RegisteredTrademark]",
    "\\[Trademark]"->"\[Trademark]",
    "\\[Degree]"->"\[Degree]",
    "\\[Micro]"->"\[Micro]",
    "\\[Paragraph]"->"\[Paragraph]",
    "\\[DownQuestion]"->"\[DownQuestion]",
    "\\[HBar]"->"\[HBar]",
    "\\[Mho]"->"\[Mho]",
    "\\[Angstrom]"->"\[Angstrom]",
    "\\[EmptySet]"->"\[EmptySet]",
    "\\[Dash]"->"\[Dash]",
    "\\[LongDash]"->"\[LongDash]",
    "\\[Dagger]"->"\[Dagger]",
    "\\[DoubleDagger]"->"\[DoubleDagger]",
    "\\[Bullet]"->"\[Bullet]",
    "\\[DotlessI]"->"\[DotlessI]",
    "\\[FiLigature]"->"\[FiLigature]",
    "\\[FlLigature]"->"\[FlLigature]",
    "\\[Angle]"->"\[Angle]",
    "\\[RightAngle]"->"\[RightAngle]",
    "\\[MeasuredAngle]"->"\[MeasuredAngle]",
    "\\[SphericalAngle]"->"\[SphericalAngle]",
    "\\[Ellipsis]"->"\[Ellipsis]",
    "\\[VerticalEllipsis]"->"\[VerticalEllipsis]",
    "\\[CenterEllipsis]"->"\[CenterEllipsis]",
    "\\[AscendingEllipsis]"->"\[AscendingEllipsis]",
    "\\[DescendingEllipsis]"->"\[DescendingEllipsis]",
    "\\[Prime]"->"\[Prime]",
    "\\[DoublePrime]"->"\[DoublePrime]",
    "\\[ReversePrime]"->"\[ReversePrime]",
    "\\[ForAll]"->"\[ForAll]",
    "\\[Exists]"->"\[Exists]",
    "\\[NotExists]"->"\[NotExists]",
    "\\[Element]"->"\[Element]",
    "\\[NotElement]"->"\[NotElement]",
    "\\[ReverseElement]"->"\[ReverseElement]",
    "\\[NotReverseElement]"->"\[NotReverseElement]",
    "\\[Because]"->"\[Because]",
    "\\[SuchThat]"->"\[SuchThat]",
    "\\[VerticalSeparator]"->"\[VerticalSeparator]",
    "\\[Therefore]"->"\[Therefore]",
    "\\[Implies]"->"\[Implies]",
    "\\[RoundImplies]"->"\[RoundImplies]",
    "\\[Tilde]"->"\[Tilde]",
    "\\[NotTilde]"->"\[NotTilde]",
    "\\[EqualTilde]"->"\[EqualTilde]",
    "\\[TildeEqual]"->"\[TildeEqual]",
    "\\[NotTildeEqual]"->"\[NotTildeEqual]",
    "\\[TildeFullEqual]"->"\[TildeFullEqual]",
    "\\[TildeTilde]"->"\[TildeTilde]",
    "\\[NotTildeTilde]"->"\[NotTildeTilde]",
    "\\[NotEqualTilde]"->"\[NotEqualTilde]",
    "\\[NotTildeFullEqual]"->"\[NotTildeFullEqual]",
    "\\[LessTilde]"->"\[LessTilde]",
    "\\[GreaterTilde]"->"\[GreaterTilde]",
    "\\[NotLessTilde]"->"\[NotLessTilde]",
    "\\[NotGreaterTilde]"->"\[NotGreaterTilde]",
    "\\[LeftTriangle]"->"\[LeftTriangle]",
    "\\[RightTriangle]"->"\[RightTriangle]",
    "\\[LeftTriangleEqual]"->"\[LeftTriangleEqual]",
    "\\[RightTriangleEqual]"->"\[RightTriangleEqual]",
    "\\[LeftTriangleBar]"->"\[LeftTriangleBar]",
    "\\[RightTriangleBar]"->"\[RightTriangleBar]",
    "\\[NotLeftTriangleBar]"->"\[NotLeftTriangleBar]",
    "\\[NotRightTriangleBar]"->"\[NotRightTriangleBar]",
    "\\[NotLeftTriangle]"->"\[NotLeftTriangle]",
    "\\[NotLeftTriangleEqual]"->"\[NotLeftTriangleEqual]",
    "\\[NotRightTriangle]"->"\[NotRightTriangle]",
    "\\[NotRightTriangleEqual]"->"\[NotRightTriangleEqual]",
    "\\[NotEqual]"->"\[NotEqual]",
    "\\[NotLess]"->"\[NotLess]",
    "\\[NotGreater]"->"\[NotGreater]",
    "\\[LessEqual]"->"\[LessEqual]",
    "\\[LessLess]"->"\[LessLess]",
    "\\[GreaterGreater]"->"\[GreaterGreater]",
    "\\[NotLessEqual]"->"\[NotLessEqual]",
    "\\[GreaterEqual]"->"\[GreaterEqual]",
    "\\[NotGreaterEqual]"->"\[NotGreaterEqual]",
    "\\[LessSlantEqual]"->"\[LessSlantEqual]",
    "\\[LessFullEqual]"->"\[LessFullEqual]",
    "\\[NotLessLess]"->"\[NotLessLess]",
    "\\[NotNestedLessLess]"->"\[NotNestedLessLess]",
    "\\[NotLessSlantEqual]"->"\[NotLessSlantEqual]",
    "\\[NotLessFullEqual]"->"\[NotLessFullEqual]",
    "\\[NestedLessLess]"->"\[NestedLessLess]",
    "\\[NestedGreaterGreater]"->"\[NestedGreaterGreater]",
    "\\[GreaterSlantEqual]"->"\[GreaterSlantEqual]",
    "\\[GreaterFullEqual]"->"\[GreaterFullEqual]",
    "\\[NotGreaterGreater]"->"\[NotGreaterGreater]",
    "\\[NotNestedGreaterGreater]"->"\[NotNestedGreaterGreater]",
    "\\[NotGreaterSlantEqual]"->"\[NotGreaterSlantEqual]",
    "\\[NotGreaterFullEqual]"->"\[NotGreaterFullEqual]",
    "\\[LessGreater]"->"\[LessGreater]",
    "\\[GreaterLess]"->"\[GreaterLess]",
    "\\[NotLessGreater]"->"\[NotLessGreater]",
    "\\[NotGreaterLess]"->"\[NotGreaterLess]",
    "\\[LessEqualGreater]"->"\[LessEqualGreater]",
    "\\[GreaterEqualLess]"->"\[GreaterEqualLess]",
    "\\[Subset]"->"\[Subset]",
    "\\[Superset]"->"\[Superset]",
    "\\[NotSubset]"->"\[NotSubset]",
    "\\[NotSuperset]"->"\[NotSuperset]",
    "\\[SubsetEqual]"->"\[SubsetEqual]",
    "\\[SupersetEqual]"->"\[SupersetEqual]",
    "\\[NotSubsetEqual]"->"\[NotSubsetEqual]",
    "\\[NotSupersetEqual]"->"\[NotSupersetEqual]",
    "\\[SquareSubset]"->"\[SquareSubset]",
    "\\[SquareSuperset]"->"\[SquareSuperset]",
    "\\[SquareSubsetEqual]"->"\[SquareSubsetEqual]",
    "\\[SquareSupersetEqual]"->"\[SquareSupersetEqual]",
    "\\[NotSquareSubset]"->"\[NotSquareSubset]",
    "\\[NotSquareSuperset]"->"\[NotSquareSuperset]",
    "\\[NotSquareSubsetEqual]"->"\[NotSquareSubsetEqual]",
    "\\[NotSquareSupersetEqual]"->"\[NotSquareSupersetEqual]",
    "\\[Precedes]"->"\[Precedes]",
    "\\[Succeeds]"->"\[Succeeds]",
    "\\[PrecedesEqual]"->"\[PrecedesEqual]",
    "\\[SucceedsEqual]"->"\[SucceedsEqual]",
    "\\[PrecedesTilde]"->"\[PrecedesTilde]",
    "\\[SucceedsTilde]"->"\[SucceedsTilde]",
    "\\[NotPrecedes]"->"\[NotPrecedes]",
    "\\[NotSucceeds]"->"\[NotSucceeds]",
    "\\[PrecedesSlantEqual]"->"\[PrecedesSlantEqual]",
    "\\[NotPrecedesEqual]"->"\[NotPrecedesEqual]",
    "\\[NotPrecedesSlantEqual]"->"\[NotPrecedesSlantEqual]",
    "\\[NotPrecedesTilde]"->"\[NotPrecedesTilde]",
    "\\[SucceedsSlantEqual]"->"\[SucceedsSlantEqual]",
    "\\[NotSucceedsEqual]"->"\[NotSucceedsEqual]",
    "\\[NotSucceedsSlantEqual]"->"\[NotSucceedsSlantEqual]",
    "\\[NotSucceedsTilde]"->"\[NotSucceedsTilde]",
    "\\[UpTee]"->"\[UpTee]",
    "\\[Proportional]"->"\[Proportional]",
    "\\[Proportion]"->"\[Proportion]",
    "\\[Congruent]"->"\[Congruent]",
    "\\[NotCongruent]"->"\[NotCongruent]",
    "\\[CupCap]"->"\[CupCap]",
    "\\[NotCupCap]"->"\[NotCupCap]",
    "\\[Equilibrium]"->"\[Equilibrium]",
    "\\[ReverseEquilibrium]"->"\[ReverseEquilibrium]",
    "\\[UpEquilibrium]"->"\[UpEquilibrium]",
    "\\[ReverseUpEquilibrium]"->"\[ReverseUpEquilibrium]",
    "\\[RightTee]"->"\[RightTee]",
    "\\[LeftTee]"->"\[LeftTee]",
    "\\[DownTee]"->"\[DownTee]",
    "\\[DoubleRightTee]"->"\[DoubleRightTee]",
    "\\[DoubleLeftTee]"->"\[DoubleLeftTee]",
    "\\[HumpEqual]"->"\[HumpEqual]",
    "\\[NotHumpEqual]"->"\[NotHumpEqual]",
    "\\[HumpDownHump]"->"\[HumpDownHump]",
    "\\[NotHumpDownHump]"->"\[NotHumpDownHump]",
    "\\[DotEqual]"->"\[DotEqual]",
    "\\[Colon]"->"\[Colon]",
    "\\[Equal]"->"\[Equal]",
    "\\[Sqrt]"->"\[Sqrt]",
    "\\[Divides]"->"\[Divides]",
    "\\[DoubleVerticalBar]"->"\[DoubleVerticalBar]",
    "\\[NotDoubleVerticalBar]"->"\[NotDoubleVerticalBar]",
    "\\[Not]"->"\[Not]",
    "\\[VerticalTilde]"->"\[VerticalTilde]",
    "\\[Times]"->"\[Times]",
    "\\[PlusMinus]"->"\[PlusMinus]",
    "\\[MinusPlus]"->"\[MinusPlus]",
    "\\[Minus]"->"\[Minus]",
    "\\[Divide]"->"\[Divide]",
    "\\[CenterDot]"->"\[CenterDot]",
    "\\[SmallCircle]"->"\[SmallCircle]",
    "\\[Cross]"->"\[Cross]",
    "\\[CirclePlus]"->"\[CirclePlus]",
    "\\[CircleMinus]"->"\[CircleMinus]",
    "\\[CircleTimes]"->"\[CircleTimes]",
    "\\[CircleDot]"->"\[CircleDot]",
    "\\[Star]"->"\[Star]",
    "\\[Square]"->"\[Square]",
    "\\[Diamond]"->"\[Diamond]",
    "\\[Del]"->"\[Del]",
    "\\[Backslash]"->"\[Backslash]",
    "\\[Cap]"->"\[Cap]",
    "\\[Cup]"->"\[Cup]",
    "\\[Coproduct]"->"\[Coproduct]",
    "\\[Integral]"->"\[Integral]",
    "\\[ContourIntegral]"->"\[ContourIntegral]",
    "\\[DoubleContourIntegral]"->"\[DoubleContourIntegral]",
    "\\[CounterClockwiseContourIntegral]"->"\[CounterClockwiseContourIntegral]",
    "\\[ClockwiseContourIntegral]"->"\[ClockwiseContourIntegral]",
    "\\[Sum]"->"\[Sum]",
    "\\[Product]"->"\[Product]",
    "\\[Intersection]"->"\[Intersection]",
    "\\[Union]"->"\[Union]",
    "\\[UnionPlus]"->"\[UnionPlus]",
    "\\[SquareIntersection]"->"\[SquareIntersection]",
    "\\[SquareUnion]"->"\[SquareUnion]",
    "\\[Wedge]"->"\[Wedge]",
    "\\[And]"->"\[And]",
    "\\[Nand]"->"\[Nand]",
    "\\[Vee]"->"\[Vee]",
    "\\[Or]"->"\[Or]",
    "\\[Nor]"->"\[Nor]",
    "\\[Xor]"->"\[Xor]",
    "\\[PartialD]"->"\[PartialD]",
    "\\[DifferentialD]"->"\[DifferentialD]",
    "\\[CapitalDifferentialD]"->"\[CapitalDifferentialD]",
    "\\[RightArrow]"->"\[RightArrow]",
    "\\[LeftArrow]"->"\[LeftArrow]",
    "\\[UpArrow]"->"\[UpArrow]",
    "\\[DownArrow]"->"\[DownArrow]",
    "\\[LeftRightArrow]"->"\[LeftRightArrow]",
    "\\[UpDownArrow]"->"\[UpDownArrow]",
    "\\[ShortRightArrow]"->"\[ShortRightArrow]",
    "\\[ShortLeftArrow]"->"\[ShortLeftArrow]",
    "\\[ShortUpArrow]"->"\[ShortUpArrow]",
    "\\[ShortDownArrow]"->"\[ShortDownArrow]",
    "\\[Rule]"->"->",
    "\\[RuleDelayed]"->":>",
    "\\[DoubleRightArrow]"->"\[DoubleRightArrow]",
    "\\[DoubleLeftArrow]"->"\[DoubleLeftArrow]",
    "\\[DoubleUpArrow]"->"\[DoubleUpArrow]",
    "\\[DoubleDownArrow]"->"\[DoubleDownArrow]",
    "\\[DoubleLeftRightArrow]"->"\[DoubleLeftRightArrow]",
    "\\[DoubleUpDownArrow]"->"\[DoubleUpDownArrow]",
    "\\[RightArrowBar]"->"\[RightArrowBar]",
    "\\[LeftArrowBar]"->"\[LeftArrowBar]",
    "\\[UpArrowBar]"->"\[UpArrowBar]",
    "\\[DownArrowBar]"->"\[DownArrowBar]",
    "\\[RightTeeArrow]"->"\[RightTeeArrow]",
    "\\[LeftTeeArrow]"->"\[LeftTeeArrow]",
    "\\[UpTeeArrow]"->"\[UpTeeArrow]",
    "\\[DownTeeArrow]"->"\[DownTeeArrow]",
    "\\[UpperLeftArrow]"->"\[UpperLeftArrow]",
    "\\[UpperRightArrow]"->"\[UpperRightArrow]",
    "\\[LowerRightArrow]"->"\[LowerRightArrow]",
    "\\[LowerLeftArrow]"->"\[LowerLeftArrow]",
    "\\[LongRightArrow]"->"\[LongRightArrow]",
    "\\[LongLeftArrow]"->"\[LongLeftArrow]",
    "\\[DoubleLongLeftArrow]"->"\[DoubleLongLeftArrow]",
    "\\[DoubleLongRightArrow]"->"\[DoubleLongRightArrow]",
    "\\[LongLeftRightArrow]"->"\[LongLeftRightArrow]",
    "\\[DoubleLongLeftRightArrow]"->"\[DoubleLongLeftRightArrow]",
    "\\[RightArrowLeftArrow]"->"\[RightArrowLeftArrow]",
    "\\[LeftArrowRightArrow]"->"\[LeftArrowRightArrow]",
    "\\[UpArrowDownArrow]"->"\[UpArrowDownArrow]",
    "\\[DownArrowUpArrow]"->"\[DownArrowUpArrow]",
    "\\[RightVector]"->"\[RightVector]",
    "\\[DownRightVector]"->"\[DownRightVector]",
    "\\[LeftVector]"->"\[LeftVector]",
    "\\[DownLeftVector]"->"\[DownLeftVector]",
    "\\[RightUpVector]"->"\[RightUpVector]",
    "\\[LeftUpVector]"->"\[LeftUpVector]",
    "\\[RightDownVector]"->"\[RightDownVector]",
    "\\[LeftDownVector]"->"\[LeftDownVector]",
    "\\[LeftRightVector]"->"\[LeftRightVector]",
    "\\[DownLeftRightVector]"->"\[DownLeftRightVector]",
    "\\[RightUpDownVector]"->"\[RightUpDownVector]",
    "\\[LeftUpDownVector]"->"\[LeftUpDownVector]",
    "\\[RightVectorBar]"->"\[RightVectorBar]",
    "\\[DownRightVectorBar]"->"\[DownRightVectorBar]",
    "\\[LeftVectorBar]"->"\[LeftVectorBar]",
    "\\[DownLeftVectorBar]"->"\[DownLeftVectorBar]",
    "\\[RightUpVectorBar]"->"\[RightUpVectorBar]",
    "\\[LeftUpVectorBar]"->"\[LeftUpVectorBar]",
    "\\[RightDownVectorBar]"->"\[RightDownVectorBar]",
    "\\[LeftDownVectorBar]"->"\[LeftDownVectorBar]",
    "\\[RightTeeVector]"->"\[RightTeeVector]",
    "\\[DownRightTeeVector]"->"\[DownRightTeeVector]",
    "\\[LeftTeeVector]"->"\[LeftTeeVector]",
    "\\[DownLeftTeeVector]"->"\[DownLeftTeeVector]",
    "\\[RightUpTeeVector]"->"\[RightUpTeeVector]",
    "\\[LeftUpTeeVector]"->"\[LeftUpTeeVector]",
    "\\[RightDownTeeVector]"->"\[RightDownTeeVector]",
    "\\[LeftDownTeeVector]"->"\[LeftDownTeeVector]",
    "\\[LeftDoubleBracket]"->"\[LeftDoubleBracket]",
    "\\[RightDoubleBracket]"->"\[RightDoubleBracket]",
    "\\[LeftAngleBracket]"->"\[LeftAngleBracket]",
    "\\[RightAngleBracket]"->"\[RightAngleBracket]",
    "\\[LeftFloor]"->"\[LeftFloor]",
    "\\[RightFloor]"->"\[RightFloor]",
    "\\[LeftCeiling]"->"\[LeftCeiling]",
    "\\[RightCeiling]"->"\[RightCeiling]",
    "\\[LeftBracketingBar]"->"\[LeftBracketingBar]",
    "\\[RightBracketingBar]"->"\[RightBracketingBar]",
    "\\[LeftDoubleBracketingBar]"->"\[LeftDoubleBracketingBar]",
    "\\[RightDoubleBracketingBar]"->"\[RightDoubleBracketingBar]",
    "\\[EmptyCircle]"->"\[EmptyCircle]",
    "\\[FilledRectangle]"->"\[FilledRectangle]",
    "\\[EmptySquare]"->"\[EmptySquare]",
    "\\[EmptyVerySmallSquare]"->"\[EmptyVerySmallSquare]",
    "\\[FilledSmallSquare]"->"\[FilledSmallSquare]",
    "\\[FilledVerySmallSquare]"->"\[FilledVerySmallSquare]",
    "\\[EmptyUpTriangle]"->"\[EmptyUpTriangle]",
    "\\[EmptyDownTriangle]"->"\[EmptyDownTriangle]",
    "\\[FivePointedStar]"->"\[FivePointedStar]",
    "\\[SixPointedStar]"->"\[SixPointedStar]",
    "\\[SpadeSuit]"->"\[SpadeSuit]",
    "\\[HeartSuit]"->"\[HeartSuit]",
    "\\[DiamondSuit]"->"\[DiamondSuit]",
    "\\[ClubSuit]"->"\[ClubSuit]",
    "\\[Flat]"->"\[Flat]",
    "\\[Natural]"->"\[Natural]",
    "\\[Sharp]"->"\[Sharp]",
    "\\[NumberSign]"->"\[NumberSign]",
    "\\[InvisibleSpace]"->"\[InvisibleSpace]",
    "\\[VeryThinSpace]"->"\[VeryThinSpace]",
    "\\[ThinSpace]"->"\[ThinSpace]",
    "\\[ThickSpace]"->"\[ThickSpace]",
    "\\[NegativeVeryThinSpace]"->"\[NegativeVeryThinSpace]",
    "\\[NegativeThinSpace]"->"\[NegativeThinSpace]",
    "\\[NegativeMediumSpace]"->"\[NegativeMediumSpace]",
    "\\[NegativeThickSpace]"->"\[NegativeThickSpace]",
    "\\[OpenCurlyQuote]"->"\[OpenCurlyQuote]",
    "\\[CloseCurlyQuote]"->"\[CloseCurlyQuote]",
    "\\[OpenCurlyDoubleQuote]"->"\[OpenCurlyDoubleQuote]",
    "\\[CloseCurlyDoubleQuote]"->"\[CloseCurlyDoubleQuote]",
    "\\[OverParenthesis]"->"\[OverParenthesis]",
    "\\[UnderParenthesis]"->"\[UnderParenthesis]",
    "\\[OverBrace]"->"\[OverBrace]",
    "\\[UnderBrace]"->"\[UnderBrace]",
    "\\[OverBracket]"->"\[OverBracket]",
    "\\[UnderBracket]"->"\[UnderBracket]",
    "\\[IndentingNewLine]"->"\[IndentingNewLine]",
    "\\[NoBreak]"->"\[NoBreak]",
    "\\[NonBreakingSpace]"->"\[NonBreakingSpace]",
    "\\[SpaceIndicator]"->"\[SpaceIndicator]",
    "\\[InvisibleApplication]"->"\[InvisibleApplication]",
    "\\[ReturnIndicator]"->"\[ReturnIndicator]",
    "\\[HorizontalLine]"->"\[HorizontalLine]",
    "\\[VerticalLine]"->"\[VerticalLine]",
    "\\[InvisibleComma]"->"\[InvisibleComma]",
    "\\[SkeletonIndicator]"->"\[SkeletonIndicator]",
    "\\[LeftSkeleton]"->"\[LeftSkeleton]",
    "\\[RightSkeleton]"->"\[RightSkeleton]",
    "\\[Piecewise]"->"\[Piecewise]",
    "\\[VerticalBar]"->"\[VerticalBar]",
    "\\[NotVerticalBar]"->"\[NotVerticalBar]"
    |>;


(* ::Subsubsubsection::Closed:: *)
(*Main*)



NotebookToMarkdown//Clear


Options[NotebookToMarkdown]=
  {
    "Directory"->Automatic,
    "Path"->Automatic,
    "Name"->Automatic,
    "Metadata"->Automatic,
    "ContentExtension"->Automatic,
    "NotebookObject"->Automatic,
    "CellObjects"->Automatic,
    "Context"->Automatic,
    "CellStyles"->Automatic,
    "IncludeStyleDefinitions"->Automatic,
    "IncludeLinkAnchors"->Automatic,
    "UseHTMLFormatting"->Automatic,
    "UseMathJAX"->False,
    "PacletLinkResolutionFunction"->Automatic
    };
NotebookToMarkdown[
  nb_Notebook,
  ops:OptionsPattern[]
  ]:=
  PackageExceptionBlock["NotebookToMarkdown"]@
  Block[
    {
      $MarkdownIncludeStyleDefinitions=
        Replace[OptionValue["IncludeStyleDefinitions"],
          Automatic:>$MarkdownIncludeStyleDefinitions
          ],
      $MarkdownIncludeLinkAnchors=
        Replace[OptionValue["IncludeLinkAnchors"],
          Automatic:>$MarkdownIncludeLinkAnchors
          ],
      exportStrings,
      exportPick,
      exportRiffle,
      $iNotebookToMarkdownCounters=<||>
      },
  With[
    {
      dir=OptionValue["Directory"],
      path=OptionValue["Path"],
      name=Replace[Except[_String]->"Markdown"]@OptionValue["Name"],
      cext=Replace[Except[_String]->"content"]@OptionValue["ContentExtension"],
      meta=Replace[Except[_Association?AssociationQ]-><||>]@OptionValue["Metadata"],
      cont=Replace[Except[_String]->"Global`"]@OptionValue["Context"],
      nbo=OptionValue["NotebookObject"],
      cells=OptionValue["CellObjects"],
      ps=OptionValue["UseHTMLFormatting"],
      prf=Replace[
        OptionValue["PacletLinkResolutionFunction"], 
        Automatic->notebookToMarkdownResolvePacletURL
        ]
      },
    If[!DirectoryQ@dir, 
      PackageRaiseException[
        Automatic,
        "Notebook directory `` is not a valid directory",
        dir
        ]
      ];
    If[!StringQ@path,
      PackageRaiseException[
        Automatic,
        "Notebook path `` is not a valid string path",
        path
        ]
      ];
    exportStrings=
      iNotebookToMarkdown[
        <|
          "Root"->dir,
          "Path"->path,
          "Name"->name,
          "ContentExtension"->cext,
          "Meta"->meta,
          "NotebookObject"->nbo,
          "CellObjects"->cells,
          "Context"->cont,
          "UseHTML"->ps,
          "PacletResolve"->prf
          |>,
        #
        ]&/@First@nb;
    exportPick=
      Map[#=!=""&, exportStrings];
    exportStrings=
      If[$MarkdownIncludeStyleDefinitions===All&&
        MatchQ[cells, {__CellObject}]&&Length[cells]==Length[exportStrings],
        MapThread[
          TemplateApply[
            "<style>body {``}</style>\n",
            CSSGenerate[Options[#2], "RiffleCharacter"->""]
            ]<>#&,
          {
            Pick[exportStrings, exportPick],
            Pick[cells, exportPick]
            }
          ],
        Pick[exportStrings, exportPick]
        ];
    exportRiffle=
      StringRiffle[
        ReplaceAll[
          exportStrings,
          RawBoxes[s_]|
            ExportPacket[s_, ___]:>s
          ],
        "\n\n"
        ];
    Replace[
      exportRiffle,
      {
        s_String:>
          If[MatchQ[$MarkdownIncludeStyleDefinitions, All|True]&&
            MatchQ[nbo, _NotebookObject?(NotebookInformation[#]=!=$Failed&)],
            "<style>"<>CSSGenerate[nbo, "RiffleCharacter"->{"", " "}]<>"</style>\n\n",
            ""
            ]<>
          StringReplace[s,
            Join[
              Normal@
                $NotebookToMarkdownLongToUnicodeReplacements,
              Lookup[Options[nb], ExportAutoReplacements, {}],
              {
                "\t"->" "
                }
              ]
            ],
          _->$Failed
          }
      ]
    ]
  ];


NotebookToMarkdown[nb_NotebookObject, ops:OptionsPattern[]]:=
  With[{meta=MarkdownNotebookMetadata[nb]},
    With[{
      dir=
        MarkdownNotebookDirectory[nb],
      name=
        Replace[OptionValue["Name"],
          Automatic:>
            markdownNameToSlug@
              Replace[
                Lookup[meta, "Slug", Automatic],
                Automatic:>
                  Replace[Quiet@FileBaseName@MarkdownNotebookFileName[nb],
                    Except[_String]->"Title"
                    ]
                ]
          ]
      },
      If[!DirectoryQ[dir],
        $Failed,
        With[{
          d2=
            MarkdownSiteBase@
              Replace[OptionValue["Directory"],
                Automatic:>MarkdownSiteBase[dir]
                ],
          cext=
            Replace[OptionValue["ContentExtension"],
              Automatic:>MarkdownContentExtension[MarkdownSiteBase@dir]
              ],
          path=
            Replace[OptionValue["Path"],
              Automatic:>
                If[StringMatchQ[dir, MarkdownContentPath[dir]~~___],
                  "",
                  URLBuild@ConstantArray["..",
                    1+FileNameDepth[MarkdownContentPath[dir]]]
                  ]
              ],
          cont=
            Replace[OptionValue["Context"],
              Automatic:>MarkdownNotebookContext@nb
              ],
          cells=
            Cells[nb,
              CellStyle->
                Replace[OptionValue["CellStyles"],
                 Automatic:>$NotebookToMarkdownStyles
                 ]
              ]
          },
          NotebookToMarkdown[
            Notebook[
              NotebookRead@
                cells,
              ExportAutoReplacements->
                CurrentValue[nb, ExportAutoReplacements]
              ],
            {
              "Directory"->d2,
              "Path"->path,
              "Name"->name,
              "ContentExtension"->cext,
              "NotebookObject"->nb,
              "CellObjects"->cells,
              "Metadata"->
                Association@
                  FilterRules[Normal@meta,
                    Except[Alternatives@@Keys@Options@NotebookToMarkdown]
                    ],
              "Context"->cont,
              Sequence@@
                FilterRules[Normal@meta,
                  Options@NotebookToMarkdown
                  ],
              ops
              }
            ]
          ]
        ]
      ]
    ];


(*NotebookToMarkdown[nb_Notebook]:=
	With[{
		nb2=CreateDocument@Insert[nb, Visible\[Rule]False,2]
		},
		CheckAbort[
			(NotebookClose[nb2];#)&@
				NotebookToMarkdown[nb2],
			NotebookClose[nb2];
			$Aborted
			]
		]*)


(* ::Subsubsection::Closed:: *)
(*iNotebookToMarkdown*)



iNotebookToMarkdown//Clear;
iNotebookToMarkdownValid//Clear;
iNotebookToMarkdownRegister//Clear;


iNotebookToMarkdown[pathInfo_][e___]:=
  iNotebookToMarkdown[pathInfo, e]


iNotebookToMarkdownRegister/:
  HoldPattern[iNotebookToMarkdownRegister[pathInfo_, p__]~SetDelayed~d_]:=
    (
      iNotebookToMarkdown[pathInfo, p]:=d;
      iNotebookToMarkdownValid[pathInfo, p]:=True;
      )


iNotebookToMarkdownValid[e__]:=False


(* ::Subsubsubsection::Closed:: *)
(*Boxes*)



$iNotebookToMarkdownBasicBoxHeads=
  Alternatives[
    _RowBox,_GridBox,_SuperscriptBox,
    _SubscriptBox,_SubsuperscriptBox,_OverscriptBox,
    _UnderscriptBox,_UnderoverscriptBox,_FractionBox,
    _SqrtBox,_RadicalBox,_StyleBox,
    _FrameBox,_AdjustmentBox,_ButtonBox,
    _FormBox,_InterpretationBox,_TagBox,
    _ErrorBox,_CounterBox,_ValueBox,
    _OptionValueBox,_GraphicsArray,_GraphicsGrid,
    _SurfaceGraphics,_ContourGraphics,_DensityGraphics,
    _AnimatorBox,_CheckboxBox,_DynamicBox,
    _InputFieldBox,_OpenerBox,
    _PopupMenuBox,_RadioButtonBox,_SliderBox,_TooltipBox,
    _System`Convert`TeXFormDump`AreaSliderBox,
    _PaneSelectorBox,_TemplateBox,_TabViewBox
    ];


(* ::Subsubsubsection::Closed:: *)
(*Math*)



$iNotebookToMarkdownMathBoxHeads=
  _SubscriptBox|_SuperscriptBox|_FractionBox|_OverscriptBox|
  _SubsuperscriptBox


(* ::Subsubsubsection::Closed:: *)
(*IgnoredOutput Forms*)



$iNotebookToMarkdownIgnoredIOBaseForms=
  OutputFormData[_, _]|
    TemplateBox[__, "EmbeddedHTML", ___];
$iNotebookToMarkdownIgnoredIOForms=
  $iNotebookToMarkdownIgnoredIOBaseForms|
    BoxData[$iNotebookToMarkdownIgnoredIOBaseForms]|
    TextData[$iNotebookToMarkdownIgnoredIOBaseForms]


(* ::Subsubsubsection::Closed:: *)
(*IgnoredBoxHeads*)



$iNotebookToMarkdownIgnoredBoxHeads=
  TooltipBox|InterpretationBox|FormBox|FrameBox;


(* ::Subsubsubsection::Closed:: *)
(*ToString Forms*)



$iNotebookToMarkdownOutputStringBaseForms=
  _GraphicsBox|_Graphics3DBox|
  TagBox[__,_Manipulate`InterpretManipulate]|
  TagBox[_GridBox, "Column"|"Grid"]|
  TemplateBox[_, "Legended"|"EmbeddedHTML", ___];
$iNotebookToMarkdownOutputStringForms=
  $iNotebookToMarkdownOutputStringBaseForms|
  $iNotebookToMarkdownIgnoredBoxHeads[
    $iNotebookToMarkdownOutputStringBaseForms,
    __
    ];


(* ::Subsubsubsection::Closed:: *)
(*Rasterize Forms*)



$iNotebookToMarkdownRasterizeBaseForms=
  TemplateBox[__,
    InterpretationFunction->("Dataset[<>]"& ),
    ___
    ]|
  TemplateBox[__,
    "DateObject"|"CellObject"|"BoxObject"|"NotebookObject"|"NotebookObjectUnsaved",
    ___
    ]|
  InterpretationBox[
    RowBox[{
      TagBox[_String,"SummaryHead",___]|
        StyleBox[TagBox[_String,"SummaryHead",___],"NonInterpretableSummary"],
      __
      }],
    __
    ]|
  _DynamicBox|_DynamicModuleBox|
  _CheckboxBox|_DynamicBox|
  _InputFieldBox|_OpenerBox|
  _PopupMenuBox|_RadioButtonBox|_SliderBox|
  _ButtonBox?(FreeQ[BaseStyle->"Link"|"Hyperlink"])|
  _PanelBox|_PaneBox|_TogglerBox|
  $iNotebookToMarkdownRasterizeBoxHeads?(Not@*FreeQ[_DynamicBox])|
  TagBox[__, _InterpretTemplate, ___];
$iNotebookToMarkdownRasterizeForms=
  $iNotebookToMarkdownRasterizeBaseForms|
    $iNotebookToMarkdownBasicBoxHeads?(
      Not@*FreeQ[
        $iNotebookToMarkdownRasterizeBaseForms|
          $iNotebookToMarkdownOutputStringBaseForms
        ])


(* ::Subsubsubsection::Closed:: *)
(*notebookToMarkdownCleanStringExport*)



notebookToMarkdownCleanStringExport[s_String]:=
  If[StringStartsQ[s, "\""]&&StringContainsQ[s, "\!\("|"\\!\\("],
    ToExpression@s,
    s
    ];


(* ::Subsubsubsection::Closed:: *)
(*notebookToMarkdownMathJAXExport*)



notebookToMarkdownNoMathJAX[ass_]:=
  ass["UseMathJAX"]===False


notebookToMarkdownMathJAXExport//Clear


notebookToMarkdownMathJAXExport[
  pathInfo_,
  boxes_,
  temp_:"$$``$$"
  ]:=
  temp~TemplateApply~
    Module[
      {
        box,
        expr
        },
      box=System`FEDump`processBoxesForCopyAsTeX[TraditionalForm, boxes];
      expr=Quiet[Check[MakeExpression[box, StandardForm], $Failed]];
      box=
        If[expr=!=$Failed,
          ToBoxes[Extract[expr, 1, HoldForm], TraditionalForm],
          box
          ];
      System`FEDump`transformProcessedBoxesToTeX@box
      ]


(* ::Subsubsubsection::Closed:: *)
(*notebookToMarkdownHTMLExport*)



(* ::Subsubsubsubsection::Closed:: *)
(*HTML Allowed*)



notebookToMarkdownHTMLExport[
  pathInfo_?(#["UseHTML"]=!=False&),
  expr_,
  part_,
  repSpec_,
  repLevel_
  ]:=
  Module[
    {
      base=expr,
      holder=<||>,
      str,
      rep
      },
    rep=
      ReplaceAll[
        repPlaceHolder:>repSpec,
        {
          Verbatim[repExpr_]:>
            (holder[ToString@Hash[repExpr]]=repExpr;ToString@Hash[repExpr]),
          repPlaceHolder:>
            repSpec
          }
        ];
    base=
      If[part===All,
        Replace[base,
          rep,
          repLevel
          ],
        ReplacePart[base,
          part->
            Replace[
              base[[part]],
              rep,
              repLevel
              ]
          ]
        ];
    str=
      ExportString[base, "HTMLFragment"];
    holder=
      Map[
        Replace[
          iNotebookToMarkdown[pathInfo, ToBoxes@#],
          {
            s:Except["", _String]:>
              StringTrim[
                With[{x=MarkdownToXML[s]},
                  Replace[
                    ExportString[x, "HTMLFragment"],
                    {
                      e:Except[_String]:>
                        (Print[x];"")
                      }
                    ]
                  ],
                "<html><body>"|"</body></html>"
                ],
            e_:>ToString[#]
            }
          ]&,
        holder
        ];
    RawBoxes@
      StringReplace[str,
        k:Apply[Alternatives, Map[ToString,Keys@holder]]:>
          holder[k]
        ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*HTML Not Allowed*)



notebookToMarkdownHTMLExport[
  pathInfo_?(#["UseHTML"]===False&), 
  expr_,
  part_,
  repSpec_,
  repLevel_
  ]:=
  notebookToMarkdownFEExport[
    pathInfo,
    BoxData@ToBoxes@expr,
    "InputText",
    "Code"
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*ToExpression HTML Allowed*)



notebookToMarkdownHTMLToExpressionExport[
  pathInfo_?(#["UseHTML"]=!=False&), 
  boxes_,
  part_,
  repSpec_,
  repLevel_
  ]:=
  With[{expr=ToExpression[boxes, StandardForm, HoldComplete]},
    Replace[
      Thread[
        DeleteDuplicates@Cases[expr, 
          sym_Symbol?(
            Function[Null,
              Context[#]=!="System`",
              HoldAllComplete
              ]
            ):>HoldComplete[sym],
          \[Infinity],
          Heads->True
          ],
        HoldComplete
        ],
      {
        HoldComplete[{syms___}]|
          {syms___}:>
          Block[{syms},
            notebookToMarkdownHTMLExport[
              pathInfo,
              ReleaseHold[expr],
              part,
              repSpec,
              repLevel
              ]
            ],
        _:>
          notebookToMarkdownHTMLExport[
            pathInfo,
            ReleaseHold[expr],
            All,
            repExpr_,
            {1}
            ]
        }
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*ToExpression HTML Not Allowed*)



notebookToMarkdownHTMLToExpressionExport[
  pathInfo_?(#["UseHTML"]===False&), 
  boxes_,
  part_,
  repSpec_,
  repLevel_
  ]:=
  notebookToMarkdownFEExport[
    pathInfo,
    BoxData@boxes,
    "InputText",
    "Code"
    ]


(* ::Subsubsubsection::Closed:: *)
(*notebookToMarkdownPlainTextExport*)



notebookToMarkdownPlainTextExport[t_,ops:OptionsPattern[]]:=
  FrontEndExecute[
    FrontEnd`ExportPacket[
      Cell[t],
      "PlainText"
      ]
    ][[1]]


(* ::Subsubsubsection::Closed:: *)
(*notebookToMarkdownFEExport*)



notebookToMarkdownFEExport[
  pathInfo_, t_, type_, style_, ops:OptionsPattern[]
  ]:=
  Replace[
    FrontEndExecute[
      FrontEnd`ExportPacket[
        Cell[
          If[type=="InputText",
            t/.TextData->BoxData,
            t
            ], 
          First@Flatten@{style}, 
          Flatten@{ops}
          ],
        type
        ]
      ][[1]],
    {
      s_String?(StringContainsQ["\\!\\("|"\!\("]):>
        iNotebookToMarkdown[pathInfo, s]
      }
    ]


(* ::Subsubsubsection::Closed:: *)
(*markdownCodeCellIOReformat*)



(* ::Subsubsubsubsection::Closed:: *)
(*flags*)



(* ::Text:: *)
(*
	A bunch of tags to be used when cleaning the data
*)



$iNotebookToMarkdownToStripStartBlockFlag=
  "\n\"<!--<<<[[<<!\"\n";
$iNotebookToMarkdownToStripEndBlockFlag=
  "\n\"!>>]]>>>--!>\"\n";


$iNotebookToMarkdownToStripStart=
  "\"<!--STRIP_ME_FROM_OUTPUT>";
$iNotebookToMarkdownToStripEnd=
  "<STRIP_ME_FROM_OUTPUT--!>\"";


$iNotebookToMarkdownUnIndentedLine=
  "\"<!NO_INDENT>\"";


(* ::Subsubsubsubsection::Closed:: *)
(*notebookToMarkdownStripBlock*)



(* ::Text:: *)
(*
	StripBlock
	
	Preps a string by adding the tags that tell the post-processor to strip IO lines and things
*)



notebookToMarkdownStripBlock[s_]:=
  $iNotebookToMarkdownToStripStartBlockFlag<>
    $iNotebookToMarkdownUnIndentedLine<>
      $iNotebookToMarkdownToStripStart<>
        StringTrim@s<>
      $iNotebookToMarkdownToStripEnd<>
  $iNotebookToMarkdownToStripEndBlockFlag


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatPreClean*)



(* ::Text:: *)
(*
	PreClean
	
	Precleans the boxes before exporting, allowing for the pre-rasterization of rasterizable forms
*)



markdownCodeCellIOReformatPreClean[pathInfo_, e_, style_]:=
  ReplaceAll[
    e,
    {
      b:$iNotebookToMarkdownRasterizeForms:>
        Replace[
          iNotebookToMarkdown[
            pathInfo,b,
            Replace[style,
              {
                "PlainText"->"Text",
                "InputText"->"Input",
                _->Last@Flatten@{style}
                }
              ]
            ],
          s:Except["", _String]:>
            RawBoxes[s]
        ],
      (*
			Converts tabs into spaces because it looks better		
			*)
      g:$iNotebookToMarkdownOutputStringForms:>
        Replace[
          iNotebookToMarkdown[pathInfo, g],
          s:Except["", _String]:>
            RawBoxes[s]
          ],
      (*
			Converts tabs into spaces because it looks better		
			*)
      s_String?(StringMatchQ["\t"..]):>
        StringReplace[s, "\t"->"  "],
      s_String:>
        notebookToMarkdownCleanStringExport@s
      }
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatBaseExport*)



(* ::Text:: *)
(*
	BaseExport
	
	Performs the basic export to string for the IO data
*)



(* ::Text:: *)
(*
	This is currently super kludgy. 
	I need a better way to handle what should and what should not be exported via ExportPacket...
*)



markdownCodeCellIOReformatBaseExport[
  pathInfo_,
  e_,
  style_,
  postFormat_,
  Hold[stack_],
  ops:OptionsPattern[]
  ]:=
  Replace[If[Length@Flatten@{ops}>0, $$pass, iNotebookToMarkdown[##]],
    {
      Except[_String]:>
        notebookToMarkdownFEExport[
          #,
          #2,
          First@Flatten@{style},
          Rest@Flatten@{style},
          Flatten@{
            ops
            }
          ]
      }
    ]&[
      pathInfo,
      ReplaceAll[
        {
          r:RawBoxes[s_]:>
            (stack["Raw", ToString@Hash[r]]=s;ToString@Hash[r]),
          p:ExportPacket[s_, t_]:>
            (
              If[!KeyMemberQ[stack, t], stack[t]=<||>];
              stack[t, ToString@Hash[p]]=s;ToString@Hash[p]
              )
          }
        ]@
      markdownCodeCellIOReformatPreClean[
        pathInfo,
        e,
        style
        ]
      ];


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatReinsertStack*)



(* ::Text:: *)
(*
	ReinsertStack:
	
	Reinserts the stack of removed forms. Special tags include \[OpenCurlyDoubleQuote]Raw\[CloseCurlyDoubleQuote] and \[OpenCurlyDoubleQuote]Indented\[CloseCurlyDoubleQuote]
*)



markdownCodeCellIOReformatReinsertStack[s_, stack_]:=
  StringReplace[s,
    Join[
      {
        k:Apply[Alternatives, Keys[stack["Raw"]]]:>
          notebookToMarkdownStripBlock@
            stack["Raw", k],
        k:Apply[Alternatives, Keys[Lookup[stack, "Indented", <||>]]]:>
            stack["Indented", k]
        },
      KeyValueMap[
        Function[
          k:Apply[Alternatives, #2]:>
            #<>": "<>stack[#, k]
          ],
        KeyDrop[stack, {"Raw", "Indented"}]
        ]
      ]
    ];
markdownCodeCellIOReformatReinsertStack[Hold[stack_]][s_]:=
  markdownCodeCellIOReformatReinsertStack[s, stack];


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatStripIndents*)



(* ::Text:: *)
(*
	StripIndents:
	
	Strips indentation where tagged to
*)



markdownCodeCellIOReformatStripIndents[s_]:=
  StringReplace[s,
    {
      (* The replacement for \t is two spaces *)
      $iNotebookToMarkdownUnIndentedLine~~"  \\\n"~~(Whitespace|"")->
        $iNotebookToMarkdownUnIndentedLine,
      $iNotebookToMarkdownToStripStart~~
        inner:Shortest[__]~~
        $iNotebookToMarkdownToStripEnd:>
          StringReplace[inner,
            {
              StartOfLine->$iNotebookToMarkdownUnIndentedLine,
              StartOfLine~~Whitespace->"",
              "\\\n"~~(Whitespace|"")->""
              }
            ]
      }
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatStripFlags*)



(* ::Text:: *)
(*
	StripFlags:
	
	Strips block-start flags and such
*)



markdownCodeCellIOReformatStripFlags[s_]:=
  StringReplace[s, 
    {
      $iNotebookToMarkdownToStripStartBlockFlag~~
        inner:Shortest[__]~~
        $iNotebookToMarkdownToStripEndBlockFlag:>
          StringReplace[
            StringReplace[inner, {"\\\n"->""}],{
            $iNotebookToMarkdownToStripStart|
              $iNotebookToMarkdownToStripEnd->"",
            StartOfLine->$iNotebookToMarkdownUnIndentedLine
            }]
      }];


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformatHaveEffectCellStyles*)



(* ::Text:: *)
(*
	HaveEffectCellStyles:
	
	The cell styles that do something and should not be ignored
*)



markdownCodeCellIOReformatHaveEffectCellStyles=
  {
    ShowStringCharacters, ShowSpecialCharacters,
    ShowShortBoxForm
    };


(* ::Subsubsubsubsection::Closed:: *)
(*markdownCodeCellIOReformat*)



(* ::Text:: *)
(*
	IOReformat:
	
	Performs the total reformatting of the IO data
*)



markdownCodeCellIOReformat[
  pathInfo_,
  e_,
  style_,
  postFormat_,
  postFormat2_,
  ops:OptionsPattern[]
  ]:=
  Module[{stack=<|"Raw"-><||>|>},
    Replace[
      {
        s_String?(StringContainsQ["<"~~__~~">"~~___~~"</"~~__~~">"]):>
          postFormat2@
            With[{baseWhitespace=StringCases[s, StartOfString~~Whitespace, 1]},
              "<pre >\n<code>\n"<>
                If[Length@baseWhitespace>0,
                  StringReplace[s, 
                    StartOfLine~~baseWhitespace[[1]]->""
                    ],
                  s
                  ]<>
              "\n</code>\n</pre>"
              ],
        s:Except["", _String]:>
          StringReplace[postFormat@s,
            {
              ("    "...)~~$iNotebookToMarkdownUnIndentedLine->
                "",
              (* Clean up the replacements for \t *)
              "  \\\n"->
                "\n",
              "\\\n"~~(Whitespace|"")->
                ""
              }]
        }
      ]@
      markdownCodeCellIOReformatStripIndents@
      markdownCodeCellIOReformatStripFlags@
      markdownCodeCellIOReformatReinsertStack[Hold[stack]]@
        markdownCodeCellIOReformatBaseExport[
          pathInfo,
          e,
          style,
          postFormat,
          Hold[stack],
          FilterRules[Flatten@{ops},
            Alternatives@@markdownCodeCellIOReformatHaveEffectCellStyles
            ]
        ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*Hooks*)



markdownIDHook[id_String]:=
  TemplateApply[
    "<a id=\"``\" style=\"width:0;height:0;margin:0;padding:0;\">&zwnj;</a>",
    ToLowerCase@
      StringReplace[
        StringTrim@id,
        {Whitespace->"-", Except[WordCharacter]->""}
        ]
    ];
markdownLinkAnchor[t_, style_]:=
  If[TrueQ@$MarkdownIncludeLinkAnchors||
      MemberQ[$MarkdownIncludeLinkAnchors, style],
    Replace[
      FrontEndExecute@
        ExportPacket[Cell[t], "PlainText"],
      {
        {id_String,___}:>
          markdownIDHook[id]<>"\n\n",
          _->""
        }
      ],
    ""
    ]


(* ::Subsubsubsection::Closed:: *)
(*skipConversion*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  skipConversion[e_]
  ]:=
  e


(* ::Subsubsubsection::Closed:: *)
(*Input / Output *)



(* ::Subsubsubsubsection::Closed:: *)
(*ExternalLanguage*)



iNotebookToMarkdownRegister[pathInfo_, 
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "ExternalLanguage", o___]
  ]:=
  With[
    {
      cl=
        Replace[Lookup[{o}, CellEvaluationLanguage, "Python"],
          {
            s_String?(StringContainsQ[#, "Python", IgnoreCase->True]&):>
              "python",
            s_String?(StringContainsQ[#, "NodeJS", IgnoreCase->True]&)
              "javascript",
            s_String:>ToLowerCase[s]
            }
          ]
      },
    markdownCodeCellIOReformat[
      pathInfo,
      ReplaceAll[e, BoxData->TextData],
      {"PlainText", "Code"},
      "```"<>cl<>"\n"<>#<>"\n"<>"```"&,
      StringReplace[#, 
        "<code>"->"<code class='language-"<>cl<>"'>",
        1
        ]&,
      Select[{o, PageWidth->10000}, OptionQ]
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*FencedCode*)



iNotebookToMarkdownRegister[pathInfo_, 
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "FencedCode", o___]]:=
  markdownCodeCellIOReformat[
    pathInfo,
    ReplaceAll[e, BoxData->TextData],
    {"PlainText", "Code"},
    Replace[
      ReplacePart[#, 
        1->StringTrim@StringTrim[#[[1]], "(*"|"*)"]
        ]&@
        StringSplit[#,"\n",2],
      {
        {
          s_?(StringContainsQ["="]),
          b_
          }:>
          "<?prettify "<>s<>" ?>\n"<>"```\n"<>b<>"\n"<>"```",
        {
          s_?(StringMatchQ[Except[WhitespaceCharacter]..]@*StringTrim),
          b_
          }:>
          "```"<>StringTrim[s]<>"\n"<>b<>"\n```",
        _:>
          "```\n"<>#<>"\n"<>"```"
        }
      ]&,
    Identity,
    Select[{o, PageWidth->10000}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*MathematicaLanguageCode*)



iNotebookToMarkdownRegister[pathInfo_, 
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "MathematicaLanguageCode", o___]]:=
  markdownCodeCellIOReformat[
    pathInfo,
    e,
    {"InputText", "Code"},
    "```mathematica\n"<>StringDelete[#, "\\\n"]<>"\n```"&,
    StringReplace[#, 
      "<code>"->"<code class='language-mathematica'>",
      1
      ]&,
    Select[{o}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*Code/Input*)



iNotebookToMarkdownRegister[pathInfo_,
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "Code"|"Input", o___]]:=
  markdownCodeCellIOReformat[pathInfo,
    e,
    {"InputText", "Code"},
    StringReplace[#, 
      {
        StartOfLine->"    ",
        "\\\n"->""
        }]&,
    Identity,
    Select[{o}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*InlineInput*)



iNotebookToMarkdownRegister[pathInfo_,
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "InlineInput", o___]]:=
  markdownCodeCellIOReformat[pathInfo,
    Replace[e,
      BoxData@$iNotebookToMarkdownIgnoredBoxHeads[expr_, ___]:>BoxData@expr
      ],
    {"InputText", "Code"},
    "```"<>#<>If[StringEndsQ[#,"`"], " ", ""]<>"```"&,
    Identity,
    Select[{o}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*InlineText*)



iNotebookToMarkdownRegister[pathInfo_,
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms],"InlineText", o___]]:=
  markdownCodeCellIOReformat[pathInfo,
    Replace[e,
      {
        BoxData@FormBox[expr_, _]:>TextData@expr,
        BoxData@FormBox[expr_, _]:>TextData@expr
        }
      ],
    {"PlainText", "Text"},
    "```"<>#<>If[StringEndsQ[#,"`"]," ",""]<>"```"&,
    Identity,
    Select[{o}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*Output*)



iNotebookToMarkdownRegister[pathInfo_,
  Cell[e:Except[$iNotebookToMarkdownIgnoredIOForms], "Output", o___]]:=
  markdownCodeCellIOReformat[pathInfo, 
    e,
    {"InputText", "Output"},
    StringReplace["(*Out:*)\n\n"<>#,
      {
        StartOfLine->"    "
        }
      ]&,
    StringReplace[#, 
      "<code>"->"<code>\n(*Out:*)\n",
      1
      ]&,
    Select[{o}, OptionQ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*FormattedOutput*)



iNotebookToMarkdownRegister[pathInfo_,
  Cell[
    (e:Except[$iNotebookToMarkdownIgnoredIOForms])|
      OutputFormData[_, e_],
    "FormattedOutput",
    o___
    ]|
    Cell[OutputFormData[_, e_], o___]
  ]:=
  markdownCodeCellIOReformat[pathInfo,
    e,
    {"PlainText", "Output"},
    StringTrim[
      ExportString[
        XMLElement["pre",{"class"->"program"},{
          XMLElement["code",
            {"style"->"width: 100%; white-space: pre-wrap;"},
            {"(*Out:*)\n"<>#}
            ]
          }],
        "HTMLFragment"
        ],
      "<html><body>"|"</body></html"
      ]&,
    StringReplace[#, 
      "<code>"->"<code>\n(*Out:*)",
      1
      ]&,
    Select[
      {
        o,
        ShowStringCharacters->False
        }, 
      OptionQ
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Section Styles*)



(* ::Text:: *)
(*
	Not currently used for anything, but it could be used to dynamically change whether the Title is the h1 or the section is
*)



$iNotebookToMarkdownSectionStyleRanking=
  <|
    "Title"->1,
    "Chapter"->2,
    "Subchapter"->3,
    "Section"->3,
    "Subsection"->4,
    "Subsubsection"->5,
    "Subsubsubsection"->6,
    "Subsubsubsection"->7,
    "Subsubsubsubsection"->8
    |>;


iNotebookToMarkdownRegister[pathInfo_, Cell[t_, "Title", ___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except["", _String]:>
      markdownLinkAnchor[t, "Section"]<>
        "# **"<>s<>"**"
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_, "Chapter", ___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except["", _String]:>
      markdownLinkAnchor[t, "Section"]<>
        "# ***"<>s<>"***"
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_, "Subchapter", ___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except["", _String]:>
      markdownLinkAnchor[t, "Section"]<>
        "# *"<>s<>"*"
    ];


iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Section",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except["", _String]:>
      markdownLinkAnchor[t, "Section"]<>
        "# "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsection",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>
      markdownLinkAnchor[t, "Subsection"]<>
        "## "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsubsection",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>
      markdownLinkAnchor[t, "Subsubsection"]<>
        "### "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsubsubsection",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>
      markdownLinkAnchor[t, "Subsubsubsection"]<>
        "#### "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsubsubsubsection",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>
      markdownLinkAnchor[t, "Subsubsubsubsection"]<>
        "##### "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsububsubsubsection",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>
      markdownLinkAnchor[t, "Subsububsubsubsection"]<>
        "###### "<>s
    ];


(* ::Subsubsubsection::Closed:: *)
(*Page Break*)



iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"PageBreak",___]]:=
  "---"


(* ::Subsubsubsection::Closed:: *)
(*Text Styles*)



iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Text",___]]:=
  iNotebookToMarkdown[pathInfo,t];


iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Quote",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>StringReplace[s,StartOfString->"> "]
    ];


iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Program",___]]:=
  With[{md=notebookToMarkdownPlainTextExport[t]},
    ExportString[
      XMLElement["pre",{"class"->"program"},{XMLElement["code",{},{"\n"<>md<>"\n"}]}],
      "XML"
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*Print Styles*)



notebookToMarkdownCleanPrintStyle//Clear


(* ::Subsubsubsubsection::Closed:: *)
(*notebookToMarkdownCleanPrintStyle*)



notebookToMarkdownCleanPrintStyle[s_String]:=
  notebookToMarkdownCleanStringExport[s];
notebookToMarkdownCleanPrintStyle[_[s_String, ___]]:=
  notebookToMarkdownCleanPrintStyle[s];
notebookToMarkdownCleanPrintStyle[BoxData[a_]]:=
  notebookToMarkdownCleanPrintStyle[a]
notebookToMarkdownCleanPrintStyle[e_]:=e


(* ::Subsubsubsubsection::Closed:: *)
(*notebookToMarkdownBasicXMLExport*)



notebookToMarkdownBasicXMLExport[e_]:=
  StringTrim[
    ExportString[
      ReplaceRepeated[
        MarkdownToXML@
          StringReplace[e, 
            Append[
              $NotebookToMarkdownHTMLCharReplacements,
              "\n"->"</br>"
              ]
            ],
        XMLElement["p", _, {a___}]:>a
        ],
      "HTMLFragment"
      ],
    "<html><body>"|"</body></html>"
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*notebookToMarkdownExportPrintStyle*)



notebookToMarkdownExportPrintStyle[
  pathInfo_,
  template1_,
  template2_,
  expr_,
  otherArgs:_Association:<||>,
  postProcess2:Except[_Association]:Identity
  ]:=
  If[pathInfo["UseHTML"]=!=False, 
    Identity,
    postProcess2
    ]@
  TemplateApply[
    If[pathInfo["UseHTML"]=!=False,
      template1,
      template2
      ],
    <|
      "body"->
        notebookToMarkdownBasicXMLExport@
          iNotebookToMarkdown[pathInfo, 
            notebookToMarkdownCleanPrintStyle@expr
            ],
      otherArgs
      |>
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*MessageTemplate*)



$notebookToMarkdownMessagePrintTemplate=
  StringTrim@
  "
<div 
	class='mma-message-wrapper'
	style='font-size: 12px; font-family: monospace;'>
	<div class='mma-message'>
		<span 
			class='mma-message-name-wrapper'
			style='color: #dd0000'>
			<span class='mma-message-name'>`head`::`name`:</span>
		</span>
		<span 
			class='mma-message-text-wrapper'
			style='color: gray'>
			<span class='mma-message-text'>`body`</span>
		</span>
	</div>
</div>
";


iNotebookToMarkdownRegister[pathInfo_,
  TemplateBox[{msgHead_,msgName_,text_,___}, 
    "MessageTemplate"|"MessageTemplate2",
    ___
    ]
  ]:=
  notebookToMarkdownExportPrintStyle[
    pathInfo,
    $notebookToMarkdownMessagePrintTemplate,
    "(*message*)\n`head`::`name`: `body`",
    Replace[text, RowBox[{a_, ___, _ButtonBox}]:>a, {1}],
    <|
      "head"->msgHead,
      "name"->msgName
      |>,
    StringReplace[(StartOfLine|StartOfString)->"    "]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*PrintUsage*)



$notebookToMarkdownUsagePrintTemplate=
  StringTrim@
"
<div 
	class='mma-print-usage-wrapper'
	style='margin-top: -2px; padding: 0px; font-size: 12px; color: rgb(128, 128, 128); background-color: aliceblue; border-top : solid 2px lightblue; padding: 5px 0 5px 0;'>
	<div class='mma-print-usage'>
		`body`
	</div>
</div>
";


iNotebookToMarkdownRegister[pathInfo_, Cell[t_, "Print", "PrintUsage", ___]]:=
  notebookToMarkdownExportPrintStyle[
    pathInfo,
    $notebookToMarkdownUsagePrintTemplate,
    "(*Usage*)\n`body`",
    Replace[t, RowBox[{a_, ___, _ButtonBox}]:>a, {1}],
    StringReplace[(StartOfLine|StartOfString)->"    "]
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*Print*)



$notebookToMarkdownPrintPrintTemplate=
  StringTrim@
"
<div 
	class='mma-print-wrapper'
	style='font-size 12px; color : rgb(55, 55, 55);'>	
	<div class='mma-print'>
		`body`
	</div>
</div>
";


iNotebookToMarkdownRegister[pathInfo_, 
  Cell[t_,"Print",___]
  ]:=
  notebookToMarkdownExportPrintStyle[
    pathInfo,
    $notebookToMarkdownPrintPrintTemplate,
    "`body`",
    Replace[t, RowBox[{a_, ___, _ButtonBox}]:>a, {1}],
    StringReplace[(StartOfLine|StartOfString)->"> "]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*Echo*)



$notebookToMarkdownEchoPrintTemplate=
  StringTrim@
"
<div 
	class='mma-echo-wrapper'
	style='font-size 12px; color : rgb(55, 55, 55);'>
	<div class='mma-echo mma-print'>
		<span 
			class='mma-echo-text-wrapper'
			style='color:orange;'>
			<span class='mma-echo-prompt' > >> </span>
		</span>
		`body`
</div>
";


iNotebookToMarkdownRegister[pathInfo_, Cell[t_,"Echo",___]]:=
  notebookToMarkdownExportPrintStyle[
    pathInfo,
    $notebookToMarkdownEchoPrintTemplate,
    ">> `body`",
    Replace[t, RowBox[{a_, ___, _ButtonBox}]:>a, {1}],
    StringReplace[(StartOfLine|StartOfString)->"> "]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Items*)



iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Item",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"* "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subitem",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"  * "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"Subsubitem",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"    * "<>s
    ];


iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"ItemNumbered",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"1. "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"SubitemNumbered",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"  1. "<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"SubsubitemNumbered",___]]:=
  Replace[iNotebookToMarkdown[pathInfo,t],
    s:Except[""]:>"    1. "<>s
    ];


(* ::Subsubsubsection::Closed:: *)
(*Raw Forms*)



iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"RawMarkdown",___]]:=
  notebookToMarkdownPlainTextExport[t];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"TaggedHTML",___]]:=
  With[{md=notebookToMarkdownPlainTextExport[t]},
    With[{block=StringSplit[md,"\n",2]},
      "<"<>block[[1]]<>">\n"<>
        block[[2]]<>
        "\n</"<>StringSplit[block[[1]]][[1]]<>">"
      ]
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[t_,"RawPre",___]]:=
  With[{md=notebookToMarkdownPlainTextExport[t]},
    ExportString[XMLElement["pre",{},{md}],"XML"]
    ];


iNotebookToMarkdownRegister[pathInfo_,
  TemplateBox[
    {
      InterpretationBox[_, EmbeddedHTML[s_]], 
      ___
      },
    "EmbeddedHTML",
    ___
    ]
  ]:=
  ExportPacket["\n"<>s<>"\n", "Indented"];


(* ::Subsubsubsection::Closed:: *)
(*Styled Text*)



iNotebookToMarkdownRegister[pathInfo_,
  StyleBox[a__,FontSlant->"Italic",b___]]:=
  Replace[
    iNotebookToMarkdown[pathInfo,StyleBox[a,b]],
    s:Except[""]:>
      "*"<>s<>"*"
    ];
iNotebookToMarkdownRegister[pathInfo_,
  StyleBox[a___,FontWeight->"Bold"|Bold,b___]]:=
  Replace[
    iNotebookToMarkdown[pathInfo,StyleBox[a,b]],
    s:Except[""]:>
      "**"<>s<>"**"
    ];
iNotebookToMarkdownRegister[pathInfo_,
  StyleBox[a_, style_String, ___]]:=
  iNotebookToMarkdown[pathInfo, 
    StyleBox[a, 
      Sequence@@CurrentValue[{StyleDefinitions, style}]
      ]
    ];
iNotebookToMarkdownRegister[
  pathInfo_,
  StyleBox[a_, ___]
  ]:=
  Replace[
    iNotebookToMarkdown[pathInfo,a],
    s:Except[""]:>
      s
    ];


iNotebookToMarkdownRegister[pathInfo_,Cell[a___,CellTags->t_,b___]]:=
  Replace[iNotebookToMarkdown[pathInfo,Cell[a,b]],
    s:Except[""]:>
      markdownIDHook[
        ToLowerCase@StringJoin@Flatten@{t}
        ]<>"\n\n"<>s
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[a___, FontSlant->"Italic"|Italic,b___]]:=
  Replace[iNotebookToMarkdown[pathInfo,Cell[a,b]],
    s:Except[""]:>
      "*"<>s<>"*"
    ];
iNotebookToMarkdownRegister[pathInfo_,Cell[a___,FontWeight->"Bold"|Bold,b___]]:=
  Replace[iNotebookToMarkdown[pathInfo,Cell[a,b]],
    s:Except[""]:>
      "**"<>s<>"**"
    ];


(* ::Subsubsubsection::Closed:: *)
(*Tag Boxes*)



(* ::Subsubsubsubsection::Closed:: *)
(*FullForm|InputForm*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  TagBox[g_, FullForm|InputForm]
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    g
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*StyleBox*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  TagBox[StyleBox[g_, ___],__]
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    g
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*Fallback*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  TagBox[g_, __]
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    g
    ];


(* ::Subsubsubsection::Closed:: *)
(*Math Cells*)



(* ::Subsubsubsubsection::Closed:: *)
(*SuperscriptBox*)



iNotebookToMarkdownRegister[pathInfo_, 
  box:SuperscriptBox[a_, b_]
  ]:=
  If[notebookToMarkdownNoMathJAX[pathInfo],
    TemplateApply[
      "``<sup>``</sup>",
      iNotebookToMarkdown[pathInfo]/@{
        a, 
        b
        }
      ],
    notebookToMarkdownFEExport[
      pathInfo,
      BoxData@box,
      "InputText",
      "Output"
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*SubscriptBox*)



iNotebookToMarkdownRegister[pathInfo_, 
  box:SubscriptBox[a_, b_]
  ]:=
  If[notebookToMarkdownNoMathJAX[pathInfo],
    TemplateApply[
      "``<sub>``</sub>",
      iNotebookToMarkdown[pathInfo]/@{a,b}
      ],
    notebookToMarkdownFEExport[
      pathInfo,
      BoxData@box,
      "InputText",
      "Output"
      ]
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*SubsuperscriptBox*)



iNotebookToMarkdownRegister[pathInfo_, 
  box:SubsuperscriptBox[a_, b_, c_]
  ]:=
  If[notebookToMarkdownNoMathJAX[pathInfo],
    TemplateApply[
      "``<sub>``</sub><sup>``</sup>",
      iNotebookToMarkdown[pathInfo]/@{a,b,c}
      ],
    notebookToMarkdownFEExport[
      pathInfo,
      BoxData@box,
      "InputText",
      "Output"
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*FractionBox*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  box:FractionBox[a_, b_]
  ]:=
  If[notebookToMarkdownNoMathJAX[pathInfo],
    TemplateApply[
      "<sup>``</sup>&frasl;<sub>``</sub>",
      iNotebookToMarkdown[pathInfo]/@{a, b}
      ],
    notebookToMarkdownFEExport[
      pathInfo,
      BoxData@box,
      "InputText",
      "Output"
      ]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*DisplayFormula*)



iNotebookToMarkdownRegister[
  pathInfo_,
  Cell[
    e_,
    "InlineFormula", 
    o___
    ]
  ]:=
  If[pathInfo["UseMathJAX"]=!=False,
    notebookToMarkdownMathJAXExport[
      pathInfo,
      e
      ],
    iNotebookToMarkdownExport[pathInfo, e]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*DisplayFormulaNumbered*)



iNotebookToMarkdownRegister[
  pathInfo_,
  Cell[
    e_,
    "DisplayFormulaNumbered", 
    o___
    ]
  ]:=
  With[{cv=$iNotebookToMarkdownCounters["DisplayFormulaNumbered"]},
    If[!IntegerQ@cv,
      $iNotebookToMarkdownCounters["DisplayFormulaNumbered"]=1,
      $iNotebookToMarkdownCounters["DisplayFormulaNumbered"]++
      ];
    If[pathInfo["UseMathJAX"]=!=False,
      StringReplace[
        notebookToMarkdownMathJAXExport[
          pathInfo,
          e
          ],
        "$$"~~EndOfString->"\\quad ("<>ToString[cv+1]<>")$$"
        ],
      iNotebookToMarkdownExport[pathInfo, e]
      ];
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*InlineFormula*)



iNotebookToMarkdownRegister[
  pathInfo_,
  Cell[
    e_,
    "InlineFormula",
    o___
    ]
  ]:=
  If[pathInfo["UseMathJAX"]=!=False,
    notebookToMarkdownMathJAXExport[
      pathInfo,
      e,
      "$``$"
      ],
    iNotebookToMarkdownExport[pathInfo, e]
    ];


(* ::Subsubsubsubsection::Closed:: *)
(*TraditionalForm*)



iNotebookToMarkdownRegister[
  pathInfo_,
  FormBox[bd_, TraditionalForm]
  ]:=
  If[pathInfo["UseMathJAX"]=!=False,
    notebookToMarkdownMathJAXExport[
      pathInfo,
      bd
      ],
    iNotebookToMarkdownExport[pathInfo, bd]
    ];


(* ::Subsubsubsection::Closed:: *)
(*Grid / Column / Row*)



iNotebookToMarkdownRegister[
  pathInfo_, 
  g:TagBox[_GridBox, "Grid"]
  ]:=
  notebookToMarkdownHTMLToExpressionExport[
    pathInfo,
    g,
    1,
    repExpr_,
    {2}
    ];
iNotebookToMarkdownRegister[
  pathInfo_,
  g:TagBox[_GridBox, "Column"]
  ]:=
  ReplaceAll[s_String:>StringDelete[s, "\n"~~"ItemSize->{Automatic,Automatic}"]]@
  notebookToMarkdownHTMLToExpressionExport[
    pathInfo,
    g,
    1,
    repExpr_,
    {1}
    ];
iNotebookToMarkdownRegister[
  pathInfo_, 
  TemplateBox[g_, "RowDefault"]
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    TagBox[GridBox[{g}], "Grid"]
    ];


(* ::Subsubsubsection::Closed:: *)
(*RowBox*)



iNotebookToMarkdownRegister[pathInfo_, RowBox[g_, ___]]:=
  StringJoin[
    iNotebookToMarkdown[
      pathInfo,
      #
      ]&/@g
    ];


(* ::Subsubsubsection::Closed:: *)
(*Hyperlinks*)



(* ::Subsubsubsubsection::Closed:: *)
(*formatDownloadLink*)



formatDownloadLink[pathInfo_, t_, s_]:=
  With[{parse=URLParse[s]},
    If[MatchQ[Lookup[parse["Query"],"_download",False],True|"True"],
      (*Download links*)
      "<a href=\""<>
        URLBuild@
          ReplacePart[parse,
            "Query"->
              Normal@
                KeyDrop[Association@parse["Query"],"_download"]
            ]<>"\" download>"<>t<>"</a>",
      "["<>t<>"]("<>iNotebookToMarkdown[pathInfo,s]<>")"
      ]
    ];
formatStandardLink[pathInfo_, t_, e_]:=
  "["<>t<>"]("<>URLBuild@URLParse[iNotebookToMarkdown[pathInfo,e]]<>")"


(* ::Subsubsubsubsection::Closed:: *)
(*Hyperlink*)



iNotebookToMarkdownRegister[
  pathInfo_,
  ButtonBox[d_,
    o___,
    BaseStyle->"Hyperlink",
    r___
    ]]:=
  With[{t=iNotebookToMarkdown[pathInfo, d]},
    Replace[
      FirstCase[
        Flatten@List@
          Replace[
            Lookup[Select[OptionQ]@{o,r},ButtonData,t],
            s_String?(StringFreeQ["/"]):>"#"<>s
            ],
        _String|_FrontEnd`FileName|_URL|_File,
        t
        ],{
      URL[s_String?(StringContainsQ["_download=True"])]:>
        formatDownloadLink[pathInfo, t, s],
      e_:>
        formatStandardLink[pathInfo, t, e]
      }]
    
    ];


(* ::Subsubsubsection::Closed:: *)
(*Paclet Links*)



(* ::Subsubsubsubsection::Closed:: *)
(*notebookToMarkdownResolvePacletURL*)



notebookToMarkdownResolvePacletURL[s_String]:=
  If[StringStartsQ[s,"paclet:"],
    With[{page=Documentation`ResolveLink[s]},
      URLBuild@
        Flatten@{
          If[StringQ[page]&&StringStartsQ[page,$InstallationDirectory],
            "https://reference.wolfram.com/language",
            "https://www.wolframcloud.com/objects/b3m2a1.docs/reference"
            ],
          URLParse[s,"Path"]
          }<>".html"
      ],
    With[{page=
      Replace[Documentation`ResolveLink[s],{
        Null:>
          If[StringStartsQ[s,"paclet:"],
            FileNameJoin@URLParse[s,"Path"],
            FileNameJoin@{"ref",s}
            ]
        }]
      },
      URLBuild@
        Flatten@{
          If[StringStartsQ[page,$InstallationDirectory],
            "https://reference.wolfram.com/language",
            "https://www.wolframcloud.com/objects/b3m2a1.paclets/reference"
            ],
          ReplacePart[#,
            If[Length[#]==2,1,2]->
              ToLowerCase@
                StringReplace[
                  #[[If[Length[#]==2,1,2]]],
                  "ReferencePages"->"ref"
                  ]
            ]&@DeleteCases["System"]@
          FileNameSplit@
            (StringTrim[#,"."~~FileExtension[#]]<>".html")&@
              Replace[
                Replace[FileNameSplit[page],{a___,"Symbols",b_}:>{a,b}],{
                {___,p_,"Documentation","English",e___}:>
                  FileNameJoin@{p,e},
                {___,a_,b_,c_}:>
                  FileNameJoin@{a,b,c},
                _:>
                  page
                }]
        }
      ]
    ]


(* ::Subsubsubsubsection::Closed:: *)
(*Link*)



iNotebookToMarkdownRegister[
  pathInfo_,
  ButtonBox[d_,
    o___,
    BaseStyle->"Link",
    r___
    ]]:=
  Module[
    {
      t=iNotebookToMarkdown[pathInfo,d],
      url,
      baseURL
      },
    baseURL=
      FirstCase[
        Flatten@{Lookup[{o,r},ButtonData,t]},
        _String,
        t
        ];
    url=
      Replace[baseURL, 
        s_String:>
          Lookup[pathInfo, "PacletResolve", notebookToMarkdownResolvePacletURL][s]
        ];
    If[
      StringQ[baseURL]&&StringContainsQ[baseURL, "/ref"]||
        StringEndsQ[url, "ref/"~~Except["/"].. ],
      "[```"<>t<>If[StringEndsQ[t,"`"]," ",""]<>"```]("<>url<>")",
      "["<>t<>"]("<>url<>")"
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*HashExport*)



markdownNotebookHashExport//Clear


markdownNotebookHashExport[
  pathInfo_,
  expr_,
  ext_,
  fbase_:Automatic,
  alt_:Automatic,
  pre_:Identity,
  hash_:Automatic
  ]:=
  With[{
    fname=
      Replace[fbase,
        Automatic:>
          ToLowerCase[
            StringReplace[
              StringTrim[
                pathInfo["Name"],
                FileExtension@pathInfo["Name"]
                ],{
              Whitespace|$PathnameSeparator->"-",
              Except[WordCharacter]->""
              }]
            ]<>"-"<>ToString@Replace[hash,Automatic:>Hash[expr]]<>"."<>ext
        ]
    },
    Sow[
      {"img", fname}->pre@expr,
      "MarkdownExport"
      ];
    "!["<>
      Replace[alt,
        Automatic:>StringTrim[fname,"."<>ext]
        ]<>"]("<>
      StringRiffle[{
        Lookup[pathInfo, "FileExtension",
          Switch[pathInfo["ContentExtension"],
            "content",
              "{filename}",
            _String,
              pathInfo["Path"]<>
                If[StringLength[pathInfo["Path"]]>0, "/", ""]<>
                pathInfo["ContentExtension"],
            _,
              Nothing
            ]
          ],
        "img",
        fname
        },"/"]<>")"
    ]


(* ::Subsubsubsection::Closed:: *)
(*Interpretation*)



iNotebookToMarkdownRegister[
  pathInfo_,
  InterpretationBox[
    g_?(MatchQ[$iNotebookToMarkdownOutputStringForms]),
    __
    ],
  fbase_:Automatic,
  alt_:Automatic
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    g
    ];
iNotebookToMarkdownRegister[pathInfo_,
  InterpretationBox[e_,___]
  ]:=
  iNotebookToMarkdown[pathInfo, e];


(* ::Subsubsubsection::Closed:: *)
(*Tooltip*)



iNotebookToMarkdownRegister[
  pathInfo_,
  TooltipBox[
    g:$iNotebookToMarkdownOutputStringForms,
    t_,
    ___],
  fbase_:Automatic,
  alt_:Automatic
  ]:=
  iNotebookToMarkdown[
    root,
    path,
    name,
    g,
    fbase,
    If[alt===Automatic,iNotebookToMarkdown@t,alt]
    ]


(* ::Subsubsubsection::Closed:: *)
(*Rasterizable*)



iNotebookToMarkdownRegister[
  pathInfo_,
  g:$iNotebookToMarkdownRasterizeForms,
  style_:"Output"
  ]:=
  markdownNotebookHashExport[
    pathInfo,
    g,
    "png",
    Automatic,
    Automatic,
    Rasterize[
      Cell[Flatten[BoxData@#, Infinity, BoxData], style,
        CellContext->pathInfo["Context"]
        ]
      ]&
    ]


(* ::Subsubsubsection::Closed:: *)
(*GIF*)



iNotebookToMarkdownRegister[
  pathInfo_,
  g:TagBox[__,_Manipulate`InterpretManipulate],
  fbase_:Automatic,
  alt_:Automatic
  ]:=
  With[{
    expr=
      Replace[
        ToExpression[g],
        (AnimationRunning->False)->
          (AnimationRunning->True),
        1
        ]
    },
    markdownNotebookHashExport[
      pathInfo,
      expr,
      "gif",
      alt,
      fbase,
      Identity,
      Replace[expr,{
        m:Verbatim[Manipulate][
          _,
          l__List,
          ___
          ]:>
          With[{syms=
            Alternatives@@
              ReleaseHold[
                Function[
                  Null,
                  FirstCase[
                    Hold[#],
                    s_Symbol:>HoldPattern[s],
                    nosym,
                    \[Infinity]
                    ],
                  HoldFirst
                  ]/@Hold[l]
                ]
            },
            Hash@DeleteCases[Hold[m],syms,\[Infinity]]
            ],
        _:>Automatic
        }]
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*PNG*)



$iNotebookToMarkdownBaseGraphicsBoxes=
  _GraphicsBox|_Graphics3DBox|TemplateBox[_,"Legended",___];
$iNotebookToMarkdownGraphicsBoxes=
  $iNotebookToMarkdownBaseGraphicsBoxes|
    TagBox[$iNotebookToMarkdownBaseGraphicsBoxes,___]


iNotebookToMarkdownRegister[
  pathInfo_,
  g:$iNotebookToMarkdownBaseGraphicsBoxes,
  fbase_:Automatic,
  alt_:Automatic
  ]:=
  markdownNotebookHashExport[
    pathInfo,
    g,
    "png",
    alt,
    fbase,
    Cell[BoxData[#],"Output"]&
    ]


(* ::Subsubsubsection::Closed:: *)
(*Files*)



iNotebookToMarkdownRegister[pathInfo_,f_FrontEnd`FileName]:=
  StringRiffle[FileNameSplit[ToFileName[f]],"/"];
iNotebookToMarkdownRegister[pathInfo_,u:_URL]:=
  First@u;
iNotebookToMarkdownRegister[pathInfo_,f_File]:=
  StringRiffle[FileNameSplit[First[f]],"/"];


(* ::Subsubsubsection::Closed:: *)
(*Box Structure Strings*)



iNotebookToMarkdownRegister[pathInfo_,
  s_String?(StringStartsQ["\!\("|"\\!\\("])
  ]:=
  iNotebookToMarkdown[
    pathInfo,
    Cell@BoxData@
    NestWhile[
      Replace[
        FrontEndExecute[
          FrontEnd`UndocumentedTestFEParserPacket[#, False]
          ],
        {
          l_List:>l[[1,1]],
          _:>#
          }
        ]&,
      s,
      StringQ[#]&&#=!=#2&,
      2
      ]
    ];
iNotebookToMarkdownRegister[
  pathInfo_,
  s_String?(StringContainsQ["\\!\\("~~__])
  ]:=
  StringReplace[s,
    interp:Longest["\\!\\("~~__~~"\\)"]/;
      StringCount[interp, "\\!\\("]==1:>
    iNotebookToMarkdown[
      pathInfo,
      interp
      ]
    ];
iNotebookToMarkdownRegister[
  pathInfo_,
  s_String?(StringContainsQ["\!\("~~__])
  ]:=
  StringReplace[s,
    interp:Longest["\!\("~~__~~"\)"]/;
      StringCount[interp, "\!\("]==1:>
    iNotebookToMarkdown[
      pathInfo,
      interp
      ]
    ];


(* ::Subsubsubsection::Closed:: *)
(*PaneSelectorBox*)



iNotebookToMarkdownRegister[pathInfo_, 
  PaneSelectorBox[a_, setting_, ___]
  ]:=
  iNotebookToMarkdown[pathInfo,
    Replace[
      setting/.a,
      setting->a[[1,2]]
      ]
    ]


(* ::Subsubsubsection::Closed:: *)
(*MarkdownLinkedImage*)



iNotebookToMarkdownRegister[pathInfo_, 
  TemplateBox[{alt_, url_}, "MarkdownLinkedImage", ___]
  ]:=
  "!["<>iNotebookToMarkdown[pathInfo, alt]<>"]("<>
    iNotebookToMarkdown[pathInfo, url]<>
    ")"


(* ::Subsubsubsection::Closed:: *)
(*MarkdownLinkedImageLink*)



iNotebookToMarkdownRegister[pathInfo_, 
  TemplateBox[{alt_, url_, link_}, "MarkdownLinkedImageLink", ___]
  ]:=
  "["<>"!["<>iNotebookToMarkdown[pathInfo, alt]<>"]("<>
    iNotebookToMarkdown[pathInfo, url]<>
    ")"<>"]("<>iNotebookToMarkdown[pathInfo, link]<>")"


(* ::Subsubsubsection::Closed:: *)
(*TemplateBox*)



iNotebookToMarkdownRegister[pathInfo_, 
  TemplateBox[a_, ___, DisplayFunction->f_, ___]
  ]:=
  iNotebookToMarkdown[pathInfo,
    f@@a
    ];
iNotebookToMarkdownRegister[pathInfo_, 
  TemplateBox[a_, s_, ___]
  ]:=
  iNotebookToMarkdown[pathInfo,
    CurrentValue[pathInfo["Notebook"], 
      {StyleDefinitions, s, "TemplateBoxOptionsDisplayFunction"}
      ]@@a
    ]


(* ::Subsubsubsection::Closed:: *)
(*Fallbacks*)



iNotebookToMarkdownRegister[pathInfo_, Cell[e_,___]]:=
  iNotebookToMarkdown[pathInfo, e]
iNotebookToMarkdownRegister[pathInfo_, s_String]:=
  s;
iNotebookToMarkdownRegister[pathInfo_, s_TextData]:=
  StringRiffle[
    Map[
      StringTrim[iNotebookToMarkdown[pathInfo, #], StartOfString~~" "]&, 
      List@@s//Flatten
      ]
    ];
iNotebookToMarkdownRegister[pathInfo_, b_BoxData]:=
  Replace[
    iNotebookToMarkdown[pathInfo, First@b],
    "":>
      notebookToMarkdownFEExport[
        pathInfo,
        b,
        "PlainText",
        "Text"
        ]
    ];
iNotebookToMarkdownRegister[pathInfo_, $iNotebookToMarkdownIgnoredBoxHeads[e_,___]]:=
  iNotebookToMarkdown[pathInfo, e]
iNotebookToMarkdownRegister[pathInfo_, e_, ___]:=
  If[BoxQ@e,
    notebookToMarkdownFEExport[
      pathInfo,
      BoxData@e,
      "InputText",
      "Output"
      ],
    ""
    ];


(* ::Subsubsection::Closed:: *)
(*NotebookSave*)



(* ::Subsubsubsection::Closed:: *)
(*ExportSown*)



NotebookMarkdownSaveExportSown[root_, files_]:=
  With[{ext=MarkdownContentExtension@root},
    With[
      {
        f=
          FileNameJoin@
            Flatten@{
              root,
              ext,
              First[#]
              }
          },
        If[!FileExistsQ@f,
          If[!DirectoryQ@DirectoryName[f],
            CreateDirectory[DirectoryName[f], CreateIntermediateDirectories->True]
            ];
          Export[f,
            ReleaseHold@Last[#],
            Switch[FileExtension[f],
              "gif",
                "AnimationRepetitions"->Infinity,
              _,
                Sequence@@{}
              ]
            ]
          ]
        ]&/@Flatten@files
      ];


(* ::Subsubsubsection::Closed:: *)
(*ExportMDFile*)



NotebookMarkdownSaveExportMDFile[file_, body_, meta_]:=
  Export[
    StringReplace[file, "*"->"_"],
    StringTrim@
      TemplateApply[
        $markdownnewmdfiletemplate,
        <|
          "headers"->
            If[Length@meta>0,
              markdownMetadataFormat[
                FileBaseName@file,
                Association@
                  Flatten[
                    {
                      "Modified":>Now,
                      meta
                      }
                    ]
                ],
              ""
              ],
          "body"->body
          |>
        ],
    "Text",
    CharacterEncoding->"UTF-8"
    ]


(* ::Subsubsubsection::Closed:: *)
(*Main*)



$NotebookMarkdownSaveIgnoredMeta=
  {
    "ExportOptions",
    "_Save"
    };


NotebookMarkdownSave//Clear


NotebookMarkdownSave[
  nbObj:_NotebookObject|Automatic:Automatic,
  ops:OptionsPattern[]
  ]:=
  Function[Null, Catch[#, "NotebookSaveAbort"], HoldFirst]@
  PackageExceptionBlock["NotebookMarkdownSave"]@
    Module[
      {
        nb=Replace[nbObj,Automatic:>InputNotebook[]],
        meta,
        expOps,
        md,
        root,
        expDir,
        expName,
        nbDir,
        siteBase,
        flops=Flatten@{ops}
        },
      meta=
        Merge[
          {
            MarkdownNotebookMetadata[nb],
            flops
            },
          Last
          ];
      expOps=
        Replace[Except[_?OptionQ]-><||>]@
          Lookup[meta, "ExportOptions"];
      If[
        Lookup[expOps, "Save", True]===False||
          Lookup[meta, "_Save", True]===False (*Legacy*), 
        Throw[Null, "NotebookSaveAbort"]
        ];
      md=
        Reap[
          NotebookToMarkdown[nb, 
            FilterRules[Normal@expOps, Options[NotebookToMarkdown]]],
          "MarkdownExport"
          ];
      If[!StringQ@md[[1]]||StringLength@StringTrim@md[[1]]==0, 
        Throw[Null, "NotebookSaveAbort"]
        ];
      nbDir=MarkdownNotebookDirectory[nb];
      siteBase=MarkdownSiteBase@nbDir;
      root=
        Replace[Lookup[expOps, "RootDirectory", Automatic],
          {
            f_String?(Not@*DirectoryQ):>
              ExpandFileName@
                FileNameJoin@{
                  siteBase,
                  f
                  },
            {f__String}:>
              ExpandFileName@
                FileNameJoin@{
                  siteBase,
                  f
                  },
            Except[_String?(DirectoryQ)]:>
              siteBase
            }
          ];
      expDir=
        Replace[Lookup[expOps, "Directory", Automatic],
          {
            f_String?(ExpandFileName[#]!=#||Not@DirectoryQ[#]&):>
              ExpandFileName@
                FileNameJoin@{
                  nbDir,
                  f
                  },
            {f__String}:>
              ExpandFileName@
                FileNameJoin@{
                  nbDir,
                  f
                  },
            Except[_String?(DirectoryQ)]:>
              nbDir
            }
          ];
      expName=
        Replace[Lookup[expOps, "Name", Automatic],
          {
            f_String:>
              If[FileExtension[f]=="", f<>".md", f],
            Except[_String?(DirectoryQ)]:>
              FileBaseName@
                Quiet[Replace[NotebookFileName[nb], $Failed->"Notebook"]]<>".md"
            }
          ];
      NotebookMarkdownSaveExportSown[root, Last[md]];
      NotebookMarkdownSaveExportMDFile[
        FileNameJoin@{
          expDir,
          expName
          },
        md[[1]],
        KeyDrop[meta, $NotebookMarkdownSaveIgnoredMeta]
        ]
      ];


End[];



