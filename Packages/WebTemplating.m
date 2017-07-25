(* ::Package:: *)

$packageHeader

HTMLTemplateBar::usage=
	"The bar used as the DockedCell";
HTMLDockedCellStyles::usage=
	"The styles used in building the docked cell";
HTMLTemplateStyles::usage=
	"The styles scraped to build an HTML page";
HTMLStyleSpecification::usage=
	"the basic specification for styles";


HTMLScrapePages::usage=
	"scrapes HTML data from the given notebook/cell group";
HTMLScrapeStyles::usage=
	"scrapes the style info from a given notebook / cell group";
HTMLBuildPages::usage=
	"builds HTML pages from the given spec";


XMLToCells::usage=
	"turns an XMLElement into a cell group";
HTMLNotebook::usage=
	"converts an XML spec into a notebook";


HTMLTemplateNotebook::usage=
	"Generates a template notebook to fill out";


PelicanNewFile::usage="";
PelicanNewSite::usage="";


PelicanBuild::usage="";
PelicanDeploy::usage="";


PelicanThemes::usage="";


PelicanNotebookToMarkdown::usage="";


Begin["`Private`"];


If[!StringQ@$WebTemplatingRoot,
	$WebTemplatingRoot=
		FileNameJoin@{
			$UserDocumentsDirectory,
			"Wolfram Mathematica",
			"WebPages"
			}
	];


htmlNullTags={
	"DOCTYPE",
	"html"
	};
htmlMainTags={
	"head",
	"body"
	};


htmlBuildTags=
	Join[{
		"PageNames",
		"DeployTo",
		"ResourceFiles",
		"ResourcePermissions"
		},
		ToString@*First/@Options@CloudDeploy
		];


htmlFakeTags=
	{
		"plaintext",
		"inlinetext",
		"style class",
		"php"
		};


htmlStdTags=
	{
		"a","abbr","acronym",
		"address","applet","area",
		"article","aside","audio",
		"b","base","basefont",
		"bdi","bdo","big",
		"blockquote","br","button",
		"buildto",
		"canvas","caption","center",
		"cite","code","col",
		"colgroup",
		"data","datalist",
		"dd","del","details",
		"dfn","dialog","dir",
		"div","dl","dt",
		"em","embed",
		"fieldset","figcaption","figure",
		"font","footer","form",
		"frame","frameset",
		"header","hr",
		"h1","h2","h3",
		"h4","h5","h6",
		"i","iframe","img",
		"inputcell",
		"input","ins",
		"kbd","keygen",
		"label","legend","li",
		"link",
		"main","map","mark",
		"menu","menuitem",
		"meta","meter",
		"nav","noframes",
		"noscript",
		"object","ol",
		"optgroup","option",
		"output",
		"p","param",
		"picture","pre",
		"progress",
		"q",
		"rp","rt","ruby",
		"s","samp","script",
		"section","select","small",
		"source","span","strike",
		"strong","style","sub",
		"summary","sup",
		"table","tbody","td",
		"textarea","tfoot","th",
		"thead","time","title",
		"tr","track","tt",
		"u","ul",
		"var","video",
		"wbr"
		};


cssStdProps=
	{
		"align-content","align-items","align-self",
		"all","animation","animation-delay",
		"animation-direction","animation-duration","animation-fill-mode",
		"animation-iteration-count","animation-name","animation-play-state",
		"animation-timing-function","backface-visibility","background",
		"background-attachment","background-blend-mode","background-clip",
		"background-color","background-image","background-origin",
		"background-position","background-repeat","background-size",
		"border","border-bottom","border-bottom-color",
		"border-bottom-left-radius","border-bottom-right-radius","border-bottom-style",
		"border-bottom-width","border-collapse","border-color",
		"border-image","border-image-outset","border-image-repeat",
		"border-image-slice","border-image-source","border-image-width",
		"border-left","border-left-color","border-left-style",
		"border-left-width","border-radius","border-right",
		"border-right-color","border-right-style","border-right-width",
		"border-spacing","border-style","border-top",
		"border-top-color","border-top-left-radius","border-top-right-radius",
		"border-top-style","border-top-width","border-width",
		"bottom","box-shadow","box-sizing",
		"caption-side","clear","clip",
		"color","column-count","column-fill",
		"column-gap","column-rule","column-rule-color",
		"column-rule-style","column-rule-width","column-span",
		"column-width","columns","content",
		"counter-increment","counter-reset","cursor",
		"direction","display","empty-cells",
		"filter","flex","flex-basis",
		"flex-direction","flex-flow","flex-grow",
		"flex-shrink","flex-wrap","float",
		"font","@font-face","font-family",
		"font-size","font-size-adjust","font-stretch",
		"font-style","font-variant","font-weight",
		"hanging-punctuation","height","justify-content",
		"@keyframes","left","letter-spacing",
		"line-height","list-style","list-style-image",
		"list-style-position","list-style-type","margin",
		"margin-bottom","margin-left","margin-right",
		"margin-top","max-height","max-width",
		"@media","min-height","min-width",
		"nav-down","nav-index","nav-left",
		"nav-right","nav-up","opacity",
		"order","outline","outline-color",
		"outline-offset","outline-style","outline-width",
		"overflow","overflow-x","overflow-y",
		"padding","padding-bottom","padding-left",
		"padding-right","padding-top","page-break-after",
		"page-break-before","page-break-inside","perspective",
		"perspective-origin","position","quotes",
		"resize","right","tab-size",
		"table-layout","text-align","text-align-last",
		"text-decoration","text-decoration-color","text-decoration-line",
		"text-decoration-style","text-indent","text-justify",
		"text-overflow","text-shadow","text-transform",
		"top","transform","transform-origin",
		"transform-style","transition","transition-delay",
		"transition-duration","transition-property","transition-timing-function",
		"unicode-bidi","user-select","vertical-align",
		"visibility","white-space","width",
		"word-break","word-spacing","word-wrap",
		"z-index","color","opacity",
		"background","background-attachment","background-blend-mode",
		"background-color","background-image","background-position",
		"background-repeat","background-clip","background-origin",
		"background-size","border","border-bottom",
		"border-bottom-color","border-bottom-left-radius","border-bottom-right-radius",
		"border-bottom-style","border-bottom-width","border-color",
		"border-image","border-image-outset","border-image-repeat",
		"border-image-slice","border-image-source","border-image-width",
		"border-left","border-left-color","border-left-style",
		"border-left-width","border-radius","border-right",
		"border-right-color","border-right-style","border-right-width",
		"border-style","border-top","border-top-color",
		"border-top-left-radius","border-top-right-radius","border-top-style",
		"border-top-width","border-width","box-shadow",
		"bottom","clear","clip",
		"display","float","height",
		"left","margin","margin-bottom",
		"margin-left","margin-right","margin-top",
		"max-height","max-width","min-height",
		"min-width","overflow","overflow-x",
		"overflow-y","padding","padding-bottom",
		"padding-left","padding-right","padding-top",
		"position","right","top",
		"visibility","width","vertical-align",
		"z-index","align-content","align-items",
		"align-self","flex","flex-basis",
		"flex-direction","flex-flow","flex-grow",
		"flex-shrink","flex-wrap","justify-content",
		"order","hanging-punctuation","letter-spacing",
		"line-height","tab-size","text-align",
		"text-align-last","text-indent","text-justify",
		"text-transform","white-space","word-break",
		"word-spacing","word-wrap","text-decoration",
		"text-decoration-color","text-decoration-line","text-decoration-style",
		"text-shadow","@font-face","font",
		"font-family","font-size","font-size-adjust",
		"font-stretch","font-style","font-variant",
		"font-weight","direction","unicode-bidi",
		"direction","user-select","border-collapse",
		"border-spacing","caption-side","empty-cells",
		"table-layout","counter-increment","counter-reset",
		"list-style","list-style-image","list-style-position",
		"list-style-type","@keyframes","animation",
		"animation-delay","animation-direction","animation-duration",
		"animation-fill-mode","animation-iteration-count","animation-name",
		"animation-play-state","animation-timing-function","backface-visibility",
		"perspective","perspective-origin","transform",
		"transform-origin","transform-style","transition",
		"transition-property","transition-duration","transition-timing-function",
		"transition-delay","box-sizing","content",
		"cursor","nav-down","nav-index",
		"nav-left","nav-right","nav-up",
		"outline","outline-color","outline-offset",
		"outline-style","outline-width","resize",
		"text-overflow","column-count","column-fill",
		"column-gap","column-rule","column-rule-color",
		"column-rule-style","column-rule-width","column-span",
		"column-width","columns","page-break-after",
		"page-break-before","page-break-inside","quotes",
		"filter"
		};


htmlFakeProps=
	{
		"buildto"
		};


htmlStdProps=
	DeleteDuplicates@Sort@
		Join[
			cssStdProps,{
				"version",
				"language"
			},
			{
				"abbr","accept","accept-charset",
				"accesskey","action","align",
				"alink","alt","async","autocomplete",
				"autofocus","autoplay","axis",
				"background","bgcolor","border",
				"cellpadding","cellspacing","char",
				"charoff","charset","checked",
				"cite","class","color",
				"cols","colspan","compact",
				"content","contenteditable","contextmenu",
				"controls","coords",
				"data","data-*","datetime",
				"default","defer","dir",
				"dirname","disabled","download",
				"draggable","dropzone",
				"enctype",
				"face","for","form",
				"formaction","formenctype",
				"formmethod","formnovalidate",
				"formtarget","frame",
				"frameborder",
				"headers","height","hidden",
				"high","href","hreflang",
				"hspace","http-equiv",
				"icon","id","ismap",
				"keytype","kind",
				"label","lang","link",
				"list","longdesc","loop",
				"low",
				"manifest","marginheight","marginwidth",
				"max","maxlength","media",
				"method","min","multiple",
				"muted",
				"name","nohref","noresize",
				"noshade","novalidate","nowrap",
				"onafterprint","onbeforeprint",
				"onbeforeunload","onblur",
				"onchange","onclick",
				"oncontextmenu","oncopy",
				"oncut","ondblclick",
				"ondrag","ondragend",
				"ondragenter","ondragleave",
				"ondragover","ondragstart",
				"ondrop","onerror","onfocus",
				"onhashchange","oninput",
				"oninvalid","onkeydown",
				"onkeypress","onkeyup",
				"onload",
				"onmousedown","onmousemove",
				"onmouseout","onmouseover",
				"onmouseup","onoffline","ononline",
				"onpageshow","onpaste",
				"onreset","onresize","onscroll",
				"onsearch","onselect","onshow",
				"onsubmit","ontoggle",
				"onunload","onwheel",
				"open","optimum",
				"pattern","placeholder",
				"poster","preload",
				"radiogroup","readonly",
				"rel","required",
				"rev","reversed",
				"rows","rowspan",
				"rules",
				"sandbox","scheme",
				"scope","scoped",
				"scrolling","selected",
				"shape","size","sizes",
				"span","spellcheck","src",
				"srcdoc","srclang","srcset",
				"start","step","style",
				"summary",
				"tabindex","target","text",
				"title","translate","type",
				"usemap",
				"valign","value",
				"vlink","vspace",
				"width","wrap",
				"xmlns"
				}
		];


htmlHighPriorityTags={
	"div"->42,
	"div 2"->36,
	"div 3"->30,
	"div 4"->24,
	"div 5"->18,
	"div 6"->12,
	"div 7"->6,
	"div 8"->0,
	"header"->42,
	"footer"->42,
	"form"->6,
	"ul"->4,
	"ol"->4,
	"li"->2
	};
htmlLowPriorityTags={
	"span"->4,
	"b"->6,
	"i"->6,
	"s"->6,
	"area"->2,
	"br"->2,
	"inlinetext"->2,
	"style class"->2
	};


$htmlTagBaseGrouping=100;
$htmlPropBaseGrouping=200;


htmlHeaderCell//Clear


htmlHeaderCell[spec_,type:Except[_List]:None,choices_:{},ext:_String:"_tag"]:=
	Cell[BoxData[RowBox@{
		ToBoxes@
			ActionMenu[
				Mouseover[spec,Style[spec,"Hyperlink"]],
				Map[#:>(
						SelectionMove[ParentCell@EvaluationCell[],All,Cell];
						FrontEndTokenExecute[EvaluationNotebook[],"Style",
							StringReplace[#<>ext," "->"_"]
							]
						)&,
					choices
					],
				Appearance->None
				],
		Cell[BoxData@ToBoxes@Spacer[10]]
		}],
		If[type===None,Sequence@@{},type],
		Background->None,
		FontFamily->"Helvetica",
		FontWeight->Plain,
		FontSize->12,
		CellFrame->None,
		CellFrameColor->None,
		CellFrameMargins->{{0,10},{0,0}},
		CellElementSpacings->{
			"CellMinHeight"->1
			}
		];


HTMLTemplateStyles:=
	HTMLTemplateStyles=
	Join[
		{
			{"PAGE","Section"},
			{"MAIN","Subsection",
				CellFrameColor->Gray,
				CellFrame->{{0,0},{1,1}},
				Background->
					GrayLevel[.95],
				System`WholeCellGroupOpener->True,
				CellSize->{Automatic,10},
				CellElementSpacings->{
					"CellMinHeight"->10
					},
				DefaultNewCellStyle->"TAGInterpreter"
				},
			{"NULL","Text",
				CellGroupingRules->
					{"GroupTogetherGrouping",40}},
			{"TAG","Subsubsubsection",
				CellFrameColor->Gray,
				FontWeight->Plain,
				CellFrame->{{0,0},{1,0}},
				CellGroupingRules->{"SectionGrouping",$htmlTagBaseGrouping+2*10},
				CellMargins->{{100,Inherited},{Inherited,Inherited}},
				DefaultNewCellStyle->"TAGInterpreter",
				StyleKeyMapping->{
					"Backspace"->"TAGInterpreter"
					}
				},
			{"TAGText","TAG",
				FontColor->Automatic
				},
			{"TAGCode","TAG",
				FontColor->Automatic,
				FontWeight->"DemiBold",
				FontFamily->"SourceCodePro",
				FontSize->13
				},
			{"TAGInterpreter","TAG",
				Evaluatable->True,
				CellEvaluationFunction->
					With[{specs=Join[htmlStdTags,htmlFakeTags]},
						NotebookWrite[EvaluationCell[],
							Cell["",First[Nearest[specs,#]]<>"_tag"]
							]&
						],
				MenuCommandKey->"6",
				DefaultNewCellStyle->"PROPInterpreter"
				},
			{"PROP","Input",
				CellFrameColor->Gray,
				CellFrame->{{1,0},{0,0}},
				Background->GrayLevel[.95],
				CellGroupingRules->{"SectionGrouping",$htmlPropBaseGrouping+2*10},
				CellMargins->{{150,Inherited},{Inherited,Inherited}},
				DefaultNewCellStyle->"PROPInterpreter",
				StyleKeyMapping->{
					"Backspace"->"PROPInterpreter"
					},
				PageWidth->\[Infinity]
				},
			{"PROPInterpreter","PROP",
				DefaultFormatType->"Text",
				Evaluatable->True,
				CellEvaluationFunction->
					With[{specs=Join[htmlStdProps,htmlFakeProps]},
						NotebookWrite[EvaluationCell[],
							Cell[BoxData@{},
								First[Nearest[specs,#]]<>"_prop"]
							]&
						],
				MenuCommandKey->"8"
				},
			{"DIV","Subsubsection",
				CellFrameColor->Gray,
				FontWeight->Plain,
				CellFrame->{{0,0},{1,0}},
				DefaultNewCellStyle->"TAGInterpreter",
				CellBracketOptions->{"Color"->ColorData[97][11]}
				},
			{"LI","TAG",
				CellFrame->{{0,0},{1,0}},
				CellBracketOptions->{
					"Color"->RGBColor[1, 0.5, 0]
					}
				},
			{"BUILD","Input",
				CellFrame->{{1,0},{0,0}},
				Background->GrayLevel[.95],
				CellMargins->{{150,Inherited},{Inherited,Inherited}}
				},
			{"Subsubsection",None,
				MenuCommandKey->None
				},
			{"Text",None,
				MenuCommandKey->None
				},
			{"Code",None,
				MenuCommandKey->None
				}
			},
		Table[
			{t,"NULL"},
			{t,htmlNullTags}
			],
		Table[
			{t,"MAIN",
				CellDingbat->
					htmlHeaderCell[t,
						Append[htmlMainTags,"build"],
						""
						]
				},
			{t,
				Append[htmlMainTags,
					"build"]}
			],
		Table[
			{b<>"_option","BUILD",
				CellDingbat->
					htmlHeaderCell[b,htmlBuildTags,"_option"]
				},
			{b,htmlBuildTags}
			],
		Map[
			{StringReplace[First@#," "->"_"]<>"_tag",
				Which[
					StringMatchQ[First@#,"div*"],
						"DIV",
					StringMatchQ[First@#,"li"|"ul"|"ol"],
						"LI",
					True,
						"TAG"],
				CellDingbat->
					htmlHeaderCell[First@#,
						First/@DeleteCases[htmlHighPriorityTags,_->None],
						"_tag"],
				CellMargins->
					{{95-Last@#,Inherited},{Inherited,Inherited}},
				CellGroupingRules->{"SectionGrouping",$htmlTagBaseGrouping-Last@#+2*10}
				}&,
			DeleteCases[htmlHighPriorityTags,_->None]
			],
		Table[
			{t<>"_tag",
				Switch[t,
					"script"|"php"|"inlinetext"|"plaintext"|"p",
						"TAGText",
					"inputcell"|"code"|"output",
						"TAGCode",
					_,
						"TAG"
					],
				If[MatchQ[t,"script"|"php"],
					Sequence@@{
						FontFamily->"Arial",
						AutoQuoteCharacters->{},
						TabSpacings->1.5,
						AutoStyleWords->{
							"function"->{FontColor->Purple},
							"var"->{FontColor->Blue},
							Map[#->{FontColor->Gray}&,{"=","+","."}],
							Map[#->{FontColor->Darker@Green}&,{"{","}","(",")"}]
							}
						},
					Nothing
					],
				CellDingbat->
					htmlHeaderCell[t,
						Join[
							DeleteCases[Join[htmlStdTags,htmlFakeTags],
								Alternatives@@
									Join[
										First/@htmlHighPriorityTags,
										First/@htmlLowPriorityTags
										]
								],
							{
								"plaintext"
								}
							],
						"_tag"
						],
				If[t=="plaintext",
					MenuCommandKey->"7",
					Sequence@@{}
					]
				},
			{t,
				Join[
					DeleteCases[Join[htmlStdTags,htmlFakeTags],
						Alternatives@@
							Join[
								First/@htmlHighPriorityTags,
								First/@htmlLowPriorityTags
								]
						],
					{
						"plaintext"
						}
					]}
			],
		Map[
			{First@#,"TAG",
				CellDingbat->
					htmlHeaderCell[First@Last@#,First/@htmlLowPriorityTags,
						"_tag"],
				CellGroupingRules->{"SectionGrouping",$htmlTagBaseGrouping+Last@Last@#+2*10},
				CellMargins->
					{{105+Last@Last@#,Inherited},{Inherited,Inherited}}
				}&,
			Join[
				Map[StringReplace[First@#," "->"_"]<>"_tag"->{First@#,Last@#}&,
					htmlLowPriorityTags]
				]
			],
		Table[
			{p<>"_prop","PROP",
				CellDingbat->
					htmlHeaderCell[p,Join[htmlStdProps,htmlFakeProps],
						"_prop"
						]
				},
			{p,Join[htmlStdProps,htmlFakeProps]}
			]
		];


If[!ValueQ@htmlStyleSetter,
	htmlStyleSetter:=
		htmlStyleSetter=
		With[{spec=#},	
			MapIndexed[
				GradientActionMenu[First@#,
					Last@#,
					Appearance->
						If[#2=={Length@spec},
							{
								{
									"Palette",
									ImagePadding->{{1,0},{1,0}}
									},
								{
									"Palette",
									ImagePadding->{{1,1},{1,0}}
									}
								},
							{
								"Palette",
								ImagePadding->{{1,0},{1,0}}
								}
							],
					FrameMargins->5,
					ImageSize->{{Automatic,35},{Automatic,34}}
					]&,
				#]
			]&@{
				{"Insert section",
					Join[
						Map[
							With[{l=First@#,s=Last@#},
								l:>FrontEndTokenExecute[InputNotebook[],"Style",s]
								]&,
							Map[#->#&,
								Join[{
									"PAGE",
									"build"
									},
									htmlMainTags,
									htmlNullTags]
								]
							],
						SortBy[First]@Map[
							With[{l=First@#,s=Last@#},
								l:>FrontEndTokenExecute[InputNotebook[],"Style",s]
								]&,
							Join[
								#->
									StringReplace[#," "->"_"]<>"_tag"&/@
										Sort@Join[
											htmlStdTags,
											htmlFakeTags,
											Map["div "<>ToString@#&,
												Range[2,8]]
												]
								]
							]
						]
					},
				{"Insert prop",
					Map[
						With[{l=First@#,s=Last@#},
							l:>FrontEndTokenExecute[InputNotebook[],"Style",s]
							]&,
						#->#<>"_prop"&/@Sort@Join[htmlStdProps,htmlFakeProps]
						]
					}
				}
		];


(*htmlTemplater//Clear*)
If[!ValueQ@htmlTemplater,
	htmlTemplater:=
		htmlTemplater=
		GradientActionMenu["Insert Content",
			Map[
				If[MatchQ[#,_Rule|_RuleDelayed],
					With[{l=First@#,t=Last@#},
						l:>(
								SelectionMove[InputNotebook[],After,Cell,5];
								NotebookWrite[InputNotebook[],t]
								)
						],
					#
					]&,{
				"Line Break"->
					Cell["","br_tag"],
				"Input / Output"->
					Cell[
						CellGroupData[{
							Cell["input","inputcell_tag"],
							Cell["","br_tag"],
							Cell["output","output_tag"]
							}]
						],
				Delimiter,
				"Link"->
					Cell[CellGroupData[{
						Cell["link_title","a_tag"],
						Cell[BoxData@{"\"https://www.link.li\""},"href_prop"]
						}]],
				"Link Item"->
					Cell[CellGroupData[{
						Cell["","li"],
						Cell[CellGroupData[{
							Cell["link_title","a_tag"],
							Cell[BoxData@{"\"https://www.link.li\""},"href_prop"]
							}]]
						}]
						],
				"Link List"->
					Cell[
						CellGroupData[{
							Cell["","ul_tag"],
							Cell[CellGroupData[{
								Cell["","li_tag"],
								Cell[CellGroupData[{
									Cell["link_title","a_tag"],
									Cell[BoxData@{"\"https://www.link.li\""},"href_prop"]
									}]
									]
								}]
								]
							}]
						],
				Delimiter,
				"Image"->
					Cell[
						CellGroupData[{
							Cell["","img_tag"],
							Cell[BoxData@"\"path/to/image\"","src_prop"],
							Cell[BoxData@"\"hover text\"","alt_prop"]
							}]
						],
				"IFrame"->
					Cell[
						CellGroupData[{
							Cell["","iframe_tag"],
							Cell[BoxData@"\"https://www.embed.src\"","src_prop"]
							}]
						],
				Delimiter,
				"List"->
					Cell[
						CellGroupData[{
							Cell["","ul_tag"],
							Cell["","li_tag"]
							}]
						],
				"Item"->
					Cell["item text","li_tag"],
				Delimiter,
				"Page"->
					Cell[CellGroupData[{
						Cell["page_root","PAGE"],
						Cell[CellGroupData[Flatten@{
							Cell["","build"],
							Cell[BoxData@{},#<>"_option"]&/@htmlBuildTags
							}]],
						Cell[CellGroupData[{
							Cell["","head"],
							Cell[CellGroupData[{
								Cell["","style_tag"],
								Cell["body","style_class_tag"]
								}]]
							}]],
						Cell["","body"],
						Cell["","HTMLFooter"]
						}]],
				"Build Section"->
					Cell[CellGroupData[Flatten@{
						Cell["","build"],
						Cell[BoxData@{},#<>"_option"]&/@htmlBuildTags
						}]],
				"Style Section"->
					Cell[CellGroupData[{
						Cell["","style_tag"],
						Cell["body","style_class_tag"]
						}]],
				"Style Class"->
					Cell[
						CellGroupData[{
							Cell["class_name","style_class_tag"],
							Cell[BoxData@"\"font_color\"","color_prop"]
							}]
						]
				}],
			Appearance->
				{
					"Palette",
					ImagePadding->
						{{1,0},{1,0}}
					},
			FrameMargins->5,
			ImageSize->{{Automatic,35},{Automatic,34}}
			]
		];


pageButtonBar//Clear;
If[!ValueQ@pageButtonBar,
	pageButtonBar:=
		pageButtonBar=
		GradientButtonBar[{
			"Make Pages":>
				With[{s=
					DeleteDuplicates@Flatten@{
						htmlSpecDeploy@htmlPageSpecs@InputNotebook[]
						}
					},
					SystemOpen/@
						Replace[
							Select[
								s,
								!FreeQ[#,_String?(StringMatchQ["*.html"])]&
								],
							{}->s
							]
					],
			"Test Pages":>
				Switch[$OperatingSystem,
					"MacOSX",
						If[!FileExistsQ@#,
							Message[Import::nffil, SystemOpen],
							Quiet[
								Check[
									RunProcess[{"open",#,"-a","Google Chrome"}],
									Check[
										RunProcess[{"open",#,"-a","Safari"}],
											SystemOpen@#
											]
										],
								RunProcess::pnfd
								]
							]&,
					_,
						SystemOpen
					]/@
					Flatten@List@
						With[{s=
							Map[
								htmlSpecDeploy[#,
									FileNameJoin@{
										$TemporaryDirectory,
										"_web_page_prep_"
										}
									]&,
								htmlPageSpecs@InputNotebook[]
							]},
							Replace[
								Select[s,
									!FreeQ[#,_String?(StringMatchQ["*.html"])]&
									],
								{}->s
								]
							]
				},
			Method->"Queued",
			Appearance->{
				"Palette",
				ImagePadding->{Center,1,{1,0}}
				},
			ImageSize->{Automatic,35},
			FrameMargins->5
			]
		];


If[!ValueQ@genButtonBar,
	genButtonBar:=
		genButtonBar=
			GradientButtonBar[{
				"Increase Grouping":>
					Map[
						With[{g=CurrentValue[#,CellGroupingRules]},
							CurrentValue[#,CellGroupingRules]=
								ReplacePart[g,2->Max@{g[[2]]-2,0}]
							]&,
						SelectedCells@InputNotebook[]
						],
				"Decrease Grouping":>
					Map[
						With[{g=CurrentValue[#,CellGroupingRules]},
							CurrentValue[#,CellGroupingRules]=
								ReplacePart[g,2->g[[2]]+2]
							]&,
						SelectedCells@InputNotebook[]
						]
					},
				Method->"Queued",
				Appearance->{
					"Palette",
					ImagePadding->{Center,1,{1,0}}
					},
				ImageSize->{Automatic,35},
				FrameMargins->5
				]
		];


HTMLTemplateBar:=
	HTMLTemplateBar=
	Row@Flatten@{
		pageButtonBar,
		htmlTemplater,
		htmlStyleSetter,
		genButtonBar,
		GradientButton["",
			Null,
			Enabled->False,
			Appearance->{
				"Palette",
				ImagePadding->{{1,0},{1,0}}
				},
			ImageSize->{Scaled[1],35}
			]
		};


HTMLDockedCellStyles:=
	{
		{"Notebook",None,
			DockedCells->
				Cell[BoxData@ToBoxes@HTMLTemplateBar]
			},
		{"DockedCell",None,	
			CellFrame->None,
			CellMargins->{{0,0},{0,-1}},
			Background->None
			}};


HTMLStyleSpecification:=
	Join[
		HTMLDockedCellStyles,
		HTMLTemplateStyles
		];


htmlScrapePage//Clear;
htmlScrapePage[
	Cell[
		CellGroupData[{
			Cell[pgName_,"PAGE",___],
			data__
			},
			___],
		___]
	]:=
	With[{scrape=Reap[htmlScrapeElements[{data}]]},
		Join[{
			"PageRoot"->
				pgName,
			"PageXML"->
				XMLObject["Document"][
					{XMLObject["Declaration"]["Version"->"1.0","Standalone"->"yes"]},
					Replace[Cases[scrape[[1]],_XMLElement],{
						{x:XMLElement["html",_,_]}:>
							x,
						e_:>
							XMLElement["html",{},e]
						}],
					{}
					]
			},
			Join[
				Normal[
					Normal@*Merge[
						Flatten
						]/@
						GroupBy[First->Last]@
							Cases[Flatten@scrape,
								r:(_->(_?OptionQ)):>r
								]
						],
				Cases[Flatten@scrape,
					(Rule|RuleDelayed)[_,Except[_Rule|_RuleDelayed|_?OptionQ]]
					]
				]
			]
		];
htmlScrapePage[Cell[CellGroupData[c_,___],___]]:=
	htmlScrapePage@c;
htmlScrapePage[Cell[___]]:=
	Nothing;
htmlScrapePage[Notebook[c_,___]]:=
	DeleteCases[htmlScrapePage@c,
		{}
		];
htmlScrapePage[nb_NotebookObject]:=
	With[{dir=Quiet[NotebookDirectory@nb]},
		htmlScrapePage@
			Replace[NotebookRead@nb,
				Except@Cell[CellGroupData[{Cell[_,"PAGE",___]},___],___]:>
					NotebookGet@nb
				]/.(
					("ResourceFiles"->e_):>
						(
							"ResourceFiles"->(
								e/.(s_->f_String):>
									(
										s->
											If[FileExistsQ[FileNameJoin[{dir,f}]],
												FileNameJoin[{dir,f}],
												f
												]
										)
								)
							)
					)
		];
htmlScrapePage[Optional[Automatic,Automatic]]:=
	htmlScrapePage@InputNotebook[];
htmlScrapePage~SetAttributes~Listable;


htmlScrapeElements//Clear;
htmlScrapeElements[
	Cell[
		CellGroupData[{
			Cell[e_,type_,___],
			body___},
			___],
		___]
		]:=
	With[{
		t=htmlGetType[type]
		},
		Switch[t,
			"style",
				XMLElement["style",
					{},
					With[{
						s=
							htmlScrapeStyles[{body}],
						p=
							Normal@
								Merge[htmlScrapeProps[{body}],
									Replace[{s_}:>s]
									]
						},
						If[Length@p>0,
							Prepend[s,
								TemplateApply["`type` { `props`\n\t}\n",
									<|
										"type"->"body",
										"props"->
											StringJoin@
												Map[
													("\n\t"<>First@#<>": "<>Last@#<>";")&,
													p
													]
										|>
									]
								],
							s
							]
						]
					],
			_,
				XMLElement[t,
					Normal@
						Merge[htmlScrapeProps[{body}],
							Replace[{s_}:>s]
							],
					With[{b=
						DeleteCases[_String?(StringMatchQ[""|Whitespace])]@
							Flatten@{
								Replace[e,
									_String:>(
										StringTrim[e,Verbatim["(*"]|"-- "~~__~~Verbatim["*)"]|" --"]
										)
									],
								htmlScrapeElements[{body}]}
							},
						If[Length@b>0,
							Prepend[
								Riffle[b,"\n\t"],
								"\n\t"
								],
							{}
							]
						]
					]
			]
		];
htmlScrapeElements[
	Cell[
		CellGroupData[{
			Cell[e_,"build",___],
			b___},
			___],
		___]
	]:=
	htmlScrapeBuild[{b}];
htmlScrapeElements[Cell[e_,
	h_?(
		StringContainsQ[#,"_tag"]&&
		MemberQ[htmlStdTags,htmlGetType[#]]&
		),___]]:=
	XMLElement[htmlGetType[h],
		{},
		DeleteCases[_String?(StringMatchQ[""|Whitespace])]@
			{htmlContentConvert[e]}
		];
htmlScrapeElements[Cell[t_,"plaintext_tag"|"inlinetext_tag",___]]:=
	If[StringQ@t,
		t,
		htmlContentConvert[t]
		];
htmlScrapeElements[Cell[t_,"php_tag",___]]:=
	XMLElement["deletemeplease",
		{},
		"<?php\n"<>
			If[StringQ@t,
				t,
				htmlContentConvert[t]
				]
			<>"\n?>"
		];
htmlScrapeElements[Cell[___]]:=
	Nothing;
htmlScrapeElements~SetAttributes~Listable;


htmlScrapeBuild[
	Cell[
		e_,
		b_?(
			StringContainsQ[#,"_option"]&&
			MemberQ[htmlBuildTags,htmlGetType[#]]
			&),
		___]
	]:=
	Replace[ToExpression@e,{
		Null->Nothing,
		expr_:>
			(Replace[htmlGetType[b],
				t:Except[
					"PageNames"|
					"DeployTo"|
					"ResourceFiles"|
					"ResourcePermissions"
					]:>ToExpression[htmlGetType[b]]
				]->expr)
		}];
htmlScrapeBuild~SetAttributes~Listable;


htmlScrapeStyles//Clear;
htmlScrapeStyles[Cell[t_,"style_tag",___]]:=
	t;
htmlScrapeStyles[
	Cell[
		CellGroupData[{
			Cell[e_,"style_class_tag",___],
			b___
			},
			___],
		___]]:=
	TemplateApply["`type` { `props`\n\t}\n",
		<|
			"type"->e,
			"props"->
				StringJoin@
					Map[
						("\n\t"<>First@#<>": "<>Last@#<>";")&,
						Block[{$htmlStyleConversion=True},
							Normal@
								Merge[htmlScrapeProps[{b}],
									Replace[{s_}:>s]]
									]
						]
			|>
		];
htmlScrapeStyles[_Cell]:=
	Nothing;
htmlScrapeStyles[l_List]:=
	Flatten[htmlScrapeStyles/@l];


htmlScrapeProps//ClearAll;
htmlScrapeProps[
	Cell[e_,h_?(
		StringContainsQ[#,"_prop"]&&
		MemberQ[htmlStdProps,htmlGetType[#]]
		&),___]]:=
	htmlGetType[h]->
		Replace[e,{
			r:{__Rule}:>
				Map[(First@#->htmlContentConvert@Last@#)&,r],
			_:>htmlContentConvert@e
			}];
htmlScrapeProps[
	Cell[e_,"buildto_prop",___]
	]:=
	"buildto"->ToExpression[e];
htmlScrapeProps[Cell[___]]:=
	Nothing;
htmlScrapeProps[l_List]:=
	Flatten[htmlScrapeProps/@l];


htmlContentConvert//ClearAll;
htmlContentConvert[s_String]:=
	s;
htmlContentConvert[Cell[e_,___]]:=	
	htmlContentConvert[e];
htmlContentConvert[d_BoxData]:=
	htmlContentConvert@ToExpression[d];
htmlContentConvert[TextData[Cell[b_BoxData,___]]]:=
	htmlContentConvert[b];
htmlContentConvert[d_TextData]:=
	StringRiffle[ToString/@(htmlContentConvert@ToExpression[d])];
htmlContentConvert[Null]:=
	"";
htmlContentConvert[c_?ColorQ]:=
	"#"<>Map[
		StringPadLeft[
			IntegerString[#,16],
			2,
			"0"
			]&,
		Floor[255*Apply[List,ColorConvert[c,RGBColor]]]
		];


htmlContentConvert[i_Integer]:=
	ToString[i]<>"px";


htmlContentConvert[q_Quantity]:=
	StringReplace[
		ToString[q],
		" "->""
		];
htmlContentConvert[Inherited]:=
	"inherit";
htmlContentConvert[Scaled[i_]]:=
	ToString@Floor[i*100]<>"%";
htmlContentConvert[l_List]:=
	StringRiffle[htmlContentConvert/@Flatten@l];
htmlContentConvert[i_?ImageQ]:=
	With[{u=CreateUUID["img-"]<>".gif"},
		Sow["ResourceFiles"->{"img"->{u->i}}];
		XMLElement["img",
			{
				"src"->"img/"<>u,
				"alt"->u
				},{}]
		];
htmlContentConvert[g:_Graphics|_Graphics3D]:=
	htmlContentConvert@Rasterize[g,"Image",ImageResolution->120];


htmlContentConvert[URL[u_String]]:=
	"url(\""<>u<>"\")";
htmlContentConvert[r:{__Rule}]:=
	(First@#->htmlContentConvert[Last[#]])&/@r;
htmlContentConvert[e_]:=
	Block[{$xmlObjectRecursiveConversion=htmlContentConvert},
		Replace[
			xmlObjectConvert@
				ReplaceAll[e,{
					Rectangle->"rect"
					}],
			xmlObjectConvert[o_]:>
				ToLowerCase@ToString@o
			]
		];


htmlGetType[t_String]:=
	Replace[First@StringSplit[t,"_"],{
		"DOCTYPE"->"!DOCTYPE"
		}]


HTMLScrapeStyles[c_]:=
	If[KeyMemberQ[#,"XML"],
		FirstCase[#["XML"],
			XMLElement["style",_,s:{__}]:>StringRiffle[s,"\n"],
			None,
			\[Infinity]],
		None
		]&/@HTMLScrapePages[c];
HTMLScrapeStyles[]:=
	HTMLScrapeStyles[Automatic];


Options[htmlPageSpecs]:=
	Join[{
		"PageRoot"->Automatic,
		"PageNames"->Automatic,
		"DeployTo"->Automatic,
		"PageXML"->None,
		"ResourceFiles"->None,
		"ResourcePermissions"->Automatic
		},
		Options[CloudDeploy]
		];
htmlPageSpecs[ops:OptionsPattern[]]:=
	With[{
		root=
			Replace[OptionValue["PageRoot"],{
				Automatic|None->""
				}],
		xml=
			Replace[OptionValue["PageXML"],
				None->""
				]
		},
		With[{
			names=
				Replace[OptionValue["PageNames"],{
					Automatic:>
						Replace[
							DeleteDuplicates@
							Flatten@
								Cases[xml,{___,
									"buildto"->pg_,
									___}:>If[StringQ@pg,StringSplit@pg,pg],\[Infinity]],
							{}->{"main"}
							],
					e:Except[_List]:>{e}
					}],
			res=
				Replace[OptionValue["ResourceFiles"],{
					r:{__Rule}|_Association:>
						Association@
							Flatten[
								(r//.a_Association:>Normal[a])//.
									(k_->v:{(_Rule|_RuleDelayed)...}):>
										Map[
											URLBuild@{k,First@#}->
												Last@#&,
											v
											]
								],
					Except[_Association]-><||>
					}]/.{
						f_String?(FileExistsQ@#&):>
							File[f],
						url_String?(StringMatchQ[#,"http*"]&):>
							URLDownload[url]
						},
			to=
				OptionValue["DeployTo"],
			rperms=
				Replace[OptionValue["ResourcePermissions"],
					Automatic:>
						OptionValue[Permissions]
					]
			},
				Join[
					Map[
						<|
							"URI"->
								URLBuild@{root,If[FileExtension[#]==="",#<>".html",#]},
							"XML"->
								ReplaceAll[
									DeleteCases[#,
										XMLElement[
											Alternatives@@Map[First,htmlHighPriorityTags],
											{("buildto"->_)}|{},
											{(""|_String?(StringMatchQ[Whitespace]))...}
											]|
										("buildto"->_),
										\[Infinity]
										]&@
									DeleteCases[xml,
										XMLElement[_,
											{___,
												"buildto"->
													Except[
														#|(#<>".html")|
														{___,#|(#<>".html"),___}
														],
												___},_],
										\[Infinity]
										],{
									XMLElement[t_,p:{___,_->{__Rule},___},e_]:>
										XMLElement[t,
											Replace[p,
												(k_->r:{__Rule}):>
													Replace[Lookup[r,#,Lookup[r,#<>".html"]],{
														_Missing->Nothing,
														l_:>(k->l)
														}],
												1
												],
											e
											]
									}],
							"Options"->
								FilterRules[{ops},
									Options@CloudDeploy],
							"DeployTo"->
								to
							|>&,
						StringTrim[names,".html"]
						],
					KeyValueMap[
						<|
							"URI"->
								URLBuild@{root,#},
							"Data"->
								#2,
							"DeployTo"->
								to,
							"Options"->
								{Permissions->rperms}
							|>&,
						res
						]
					]
			]
		];
htmlPageSpecs[l:{__List}]:=
	htmlPageSpecs@@@l;
htmlPageSpecs[e:_Cell|_Notebook|_NotebookObject]:=
	htmlPageSpecs@htmlScrapePage[e];
htmlPageSpecs[Optional[Automatic,Automatic]]:=
	htmlPageSpecs@htmlScrapePage[Automatic];


XMLToCells[XMLElement[tag_,props_,data_]]:=
	If[Length@props>0||Length@data>0,
		Cell[CellGroupData[Flatten@{
			Cell[
				Replace[data,{
					{s_String,___}:>s,
					_->""
					}],
				tag<>If[MemberQ[htmlStdTags,tag],"_tag",""]],
			XMLToCells[props],
			XMLToCells[Replace[data,{_String,r___}:>{r}]]
			}]],
		Cell["",tag<>If[MemberQ[htmlStdTags,tag],"_tag",""]]
		];
XMLToCells[s_String]:=
	If[StringMatchQ[s,Whitespace],
		Nothing,
		Cell[s,"inlinetext_tag"]
		];
XMLToCells[k_->v_String]:=
	Cell[BoxData@("\""<>v<>"\""),k<>"_prop"];
XMLToCells[XMLObject[_][_,e_,___]]:=
	XMLToCells@e;
XMLToCells[URL[s_]|File[s_]]:=
	Cell[CellGroupData[Flatten@{
		Cell[FileBaseName@DirectoryName@s,"PAGE"],
		XMLToCells@Import[s,{"HTML","XMLObject"}]
		}]
		];
XMLToCells~SetAttributes~Listable;


HTMLNotebook[spec_]:=
	Replace[
		XMLToCells@
			Replace[spec,{
				_String?FileExistsQ:>File[spec],
				_String:>URL[spec]
				}],{
		c_Cell:>
			Notebook[{c},
				StyleDefinitions->
					FrontEnd`FileName[Evaluate@{`Package`$PackageName},"HTMLTemplating.nb"]
				],
		_->$Failed
		}]


safeParentDirQ=(StringLength@#>0&&DirectoryQ@#&@DirectoryName@#&);


safeDirQ=(StringLength@#>0&&DirectoryQ@#&@#&);


htmlGetAuthCredentials[creds:{__}]:=
	With[{
		credentials=
			Replace[DeleteCases[creds,(_String|_File)?safeDirQ],{
				l:{_String?(StringContainsQ["\@"]),_String}:>
					{l},
				e_:>
					Replace[e,{
						s_String?(StringContainsQ["\@"]):>
							{s,$CloudBase},
						c_String:>
							{$WolframID,c},
						{c_,u_String}:>
							{
								Replace[c,Automatic->$CloudBase],
								Replace[u,Automatic->$WolframID]
								},
						_->Nothing
						},
						1]
				}]
		},	
		KeyChainGet[credentials,True]
		];
htmlGetAuthCredentials[c_String]:=
	htmlGetAuthCredentials@{c};


htmlCloudBaseConnect[base_]:=
	Replace[base,{
			cloud_String?(
				FailureQ[Interpreter["EmailAddress"]@#]||
				AnyTrue[Lookup[URLParse[#],{"Scheme","Domain"}],
					MatchQ[Except[None]]
					]&):>
				With[{
					l=Replace[KeyChainGet[{cloud,$WolframID},True],_Missing->None],
					c=
						With[{p=URLParse[cloud]},
							URLBuild@
								ReplacePart[p,{
									"Scheme"->"https",
									"Domain"->Replace[p["Domain"],None->First@p["Path"]],
									"Path"->Replace[p["Domain"],None->{}]
									}]
							]},
					If[$CloudBase=!=c,
						If[$WolframID=!=None,
							CloudConnect[$WolframID,Replace[l,None:>Sequence@@{}],
								CloudBase->c
								],
							CloudConnect[Automatic,Replace[l,None:>Sequence@@{}],
								CloudBase->c
								]
							]
						]
					],
			uname_String:>
				With[{l=Replace[KeyChainGet[{$CloudBase,uname},True],_Missing->None]},
					If[$WolframID=!=uname,
						CloudConnect[uname,Replace[l,None:>Sequence@@{}]]
						]
					],
			{uname_String,
				cloud_String?(
					FailureQ[Interpreter["EmailAddress"]@#]||
					AnyTrue[Lookup[URLParse[#],{"Scheme","Domain"}],
						MatchQ[Except[None]]
						]&)}:>
				With[{l=Replace[KeyChainGet[{cloud,uname}],_Missing->None]},
					If[$CloudBase=!=cloud||$WolframID=!+uname,
						CloudConnect[uname,Replace[l,None:>Sequence@@{}],
							CloudBase->
								With[{p=URLParse[cloud]},
									URLBuild@
										ReplacePart[p,{
											"Scheme"->"https",
											"Domain"->Replace[p["Domain"],None->First@p["Path"]],
											"Path"->Replace[p["Domain"],None->{}]
											}]
									]
							]
						]
					],
			{uname_String,pass_String}:>
				If[$WolframID=!=uname,
					CloudConnect[uname,pass]
					],
			{{uname_String,pass_String},cloud_String}:>
				If[$CloudBase=!=cloud||$WolframID=!+uname,
					CloudConnect[uname,pass,
						CloudBase->
							URLBuild@ReplacePart[URLParse[cloud],
								"Scheme"->"https"
								]
						]
					]
			}];


htmlExportString[x_]:=
	StringReplace[
		ExportString[x/.{
			(k_->v_String):>
				(
					k->
						StringReplace[v,{
							"<"->"[--lessthan--]",
							">"->"[--greaterthan--]",
							"&"->"[--ampersandescape--]",
							"\""|"\[OpenCurlyDoubleQuote]"|"\[CloseCurlyDoubleQuote]"->"[--doublequoteescape--]",
							"'"|"\[OpenCurlyQuote]"|"\[CloseCurlyQuote]"->"[--singlequoteescape--]"
							}]
					),
			style:XMLElement[tag:"style"|"script",ops_,cont_]:>
				XMLElement[tag,
					ops/.s_String:>
						StringReplace[s,{
							"<"->"[--lessthan--]",
							">"->"[--greaterthan--]",
							"&"->"[--ampersandescape--]",
							"\""|"\[OpenCurlyDoubleQuote]"|"\[CloseCurlyDoubleQuote]"->"[--doublequoteescape--]",
							"'"|"\[OpenCurlyQuote]"|"\[CloseCurlyQuote]"->"[--singlequoteescape--]"
							}],
					cont/.s_String:>
						StringReplace[s,{
							"<"->"[--lessthan--]",
							">"->"[--greaterthan--]",
							"&"->"[--ampersandescape--]",
							"\""|"\[OpenCurlyDoubleQuote]"|"\[CloseCurlyDoubleQuote]"->"[--doublequoteescape--]",
							"'"|"\[OpenCurlyQuote]"|"\[CloseCurlyQuote]"->"[--singlequoteescape--]"
							}]
					]
			},
			"XML"
			],
		{
			"[--lessthan--]"->"<",
			"[--greaterthan--]"->">",
			"[--ampersandescape--]"->"&",
			"[--doublequoteescape--]"->"\"",
			"[--singlequoteescape--]"->"'",
			"<deletemeplease>"|"</deletemeplease>"->""
			}
		];


htmlSpecDeploy//ClearAll;
htmlSpecDeploy[
	specAssoc_Association,
	base:Except[(_String|_File)?safeParentDirQ]
	]:=
	With[{
		uri=
			specAssoc["URI"],
		export=
			Lookup[specAssoc,"XML",
				Lookup[specAssoc,"Data"]],
		ops=
			Lookup[specAssoc,"Options",{}]
		},
			If[AllTrue[{uri,export},Not@*MissingQ],
				htmlCloudBaseConnect[base];
					Replace[export,{
						f_File:>
							(
								CopyFile[
									f,
									CloudObject[uri]
									];
								SetOptions[CloudObject[uri],ops];
								CloudObject[uri]
								),
						e_ExportForm:>
							CloudDeploy[e,uri,ops],
						Except[_ExportForm]:>
							CloudDeploy[
								ExportForm[
									Replace[export,
										x:XMLObject[___][___]:>
											If[FileExtension[specAssoc["URI"]]=="css",
												StringRiffle[
													Flatten@
														Cases[x,
															XMLElement["style",_,s_]:>s,
															\[Infinity]
															],
													"\n"
													],
												htmlExportString[x]
												]
										],
									Replace[export,{
										(data_->mimeType_):>
											mimeType,
										s:_String|
											XMLObject[___][___]?(
												FileExtension[specAssoc["URI"]]=="css"&
												):>
											{"Text","CSS"},
										i_?ImageQ:>
											"PNG",
										{__?ImageQ}:>
											"GIF",
										_:>"HTML"
										}]
									],
								uri,
								ops
								]
						}]
			]
		];


htmlSpecDeploy[
	specAssocs:{__Association},
	base:(_String|_File)?safeParentDirQ
	]:=
	Map[
		With[{
			file=
				FileNameJoin@{
					base,
					Sequence@@URLParse[#URI]["Path"]
					}<>
					If[FileExtension@#URI==""&&KeyMemberQ[#,"XML"],
						".html",
						""
						]
			},
			Quiet@
				If[FileExtension@file!="",
					CreateFile[file,
						CreateIntermediateDirectories->True
						],
					CreateDirectory[file,
						CreateIntermediateDirectories->True
						]
					];
			If[KeyMemberQ[#,"XML"],
				Export[file,
					If[FileExtension[#["URI"]]=="css",
						StringRiffle[
							Flatten@Cases[#["XML"],
								XMLElement["style",_,s_]:>s,
								\[Infinity]
								],
							"\n"
							],
						htmlExportString@#["XML"]
						],
					"Text"
					],
				Replace[#["Data"],{
					f_File:>
						CopyFile[f,file,OverwriteTarget->True],
					d:Except[_ExportForm]:>
						Export[file,d,
							Replace[d,{
								_String:>{"Text","CSS"},
								_?ImageQ:>"PNG",
								{__?ImageQ}:>
									"GIF",
								_:>
									(Sequence@@{})
								}]
							],
					exp_:>
						Export[file,exp]
					}]
				]
			]&,
		specAssocs
		];
htmlSpecDeploy[specAssoc_,path:(_String|_File)?safeParentDirQ]:=
	htmlSpecDeploy[{specAssoc},path];


htmlSpecDeploy[specAssoc_Association]:=
	With[{locs=Lookup[specAssoc,"DeployTo",Automatic]},
		If[ListQ@locs,
			htmlSpecDeploy[specAssoc,#]&/@locs,
			htmlSpecDeploy[specAssoc,locs]
			]
		];
htmlSpecDeploy[a:{__Association}]:=
	Block[{$htmlAuthFailures={}},
		With[{locs=Lookup[a,"DeployTo",Automatic]},
			htmlGetAuthCredentials@
				DeleteCases[
					DeleteDuplicates@
						Replace[locs,
							s:{_String?(Not@*StringContainsQ["\@"]),_String}:>
								Sequence@@s,
							1
							],
					Except[_String|{_String,_String}]
					]
			];
		Map[
			With[{l=Lookup[#,"DeployTo",Automatic]},
				If[!MemberQ[$htmlAuthFailures,l],
					With[{co=htmlSpecDeploy[#]},
						If[
							MatchQ[co,
								Except[_CloudObject|{__CloudObject}]],
							AppendTo[$htmlAuthFailures,l];
							$KeyChain[l]=.
							];
						co
						],
					$Failed
					]
				]&,
			Flatten@Values@GroupBy[a,#DeployTo&]
			]		
		];


HTMLScrapePages[s_:Automatic]:=
	Replace[htmlPageSpecs[s],
		Except[_List]:>
			$Failed
		];


HTMLBuildPages[s:Except[{__Association}]:Automatic]:=
	Replace[HTMLScrapePages[s],
		Except[$Failed]:>
			htmlSpecDeploy[s]
		];
HTMLBuildPages[s:{__Association}]:=
	htmlSpecDeploy[s];


HTMLTemplateNotebook[
	name_:"html_page"
	]:=
	Replace[{
		nb_Notebook:>CreateDocument[nb],
		f_:>CreateDocument@Import@f
		}]@
	SelectFirst[
		FileNames["*.nb",PackageFilePath["Templates","HTML"]],
		FileBaseName[#]===name&,
		Notebook[{
			Cell[name,"PAGE"],
			Cell[CellGroupData[Flatten@{
				Cell["","build"],
				Cell[BoxData@{},#<>"_option"]&/@htmlBuildTags
				}]],
			Cell[CellGroupData[{
				Cell["","head"],
				Cell[CellGroupData[{
					Cell["","style_tag"],
					Cell["body","style_class_tag"]
					}]]
				}]],
			Cell["","body"],
			Cell["","HTMLFooter"]
			},
			StyleDefinitions->
				FrontEnd`FileName[
					Evaluate@{$PackageName},
					"HTMLTemplating.nb"
					]
			]
		]


$PelicanRoot=
	FileNameJoin@{
		$WebTemplatingRoot,
		"pelican"
		};


PelicanSiteBase[f_String]:=
	Replace[FileNameSplit[f],{
		{d:Shortest[___],"content"|"output",___}:>FileNameJoin@{d},
		_:>f
		}]


PelicanContentPath[f_String]:=
	Replace[FileNameSplit[f],{
		{Shortest[___],"content",p___}:>FileNameJoin@{p},
		_:>f
		}]


PelicanOutputPath[f_String]:=
	Replace[FileNameSplit[f],{
		{Shortest[___],"output",p___}:>FileNameJoin@{p},
		_:>f
		}]


PelicanInitializedQ[]:=
	(
		$PyVenv;
		Length[
			FileNames[
				FileNameJoin@{$PyVenvRoot,"pelican","lib","*","site-packages","pelican"}
				]
			]>0
		)


PelicanInitialize[]:=
	PyVenvRun["pelican",
	{"pip","install","pelican","Markdown","typogrify"},
	"Delay"->1
	]


$PelicanSitesDirectory=
	FileNameJoin@{
		$UserDocumentsDirectory,
		"Wolfram Mathematica",
		"WebPages",
		"pelican"
		};


$pelicanpublishconf=
"#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys
sys.path.append(os.curdir)
from pelicanconf import *

SITEURL = '`URL`'
RELATIVE_URLS = `UseRelativeURLs`

FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

DELETE_OUTPUT_DIRECTORY = True

# Following items are often useful when publishing

#DISQUS_SITENAME = \"\"
#GOOGLE_ANALYTICS = \"\"
";


$pelicanconf=
"#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'`Author`'
SITENAME = u'`Title`'
SITEURL = '`URL`'

PATH = 'content'
STATIC_PATHS = ['posts','img']

TIMEZONE = '`Timezone`'

DEFAULT_LANG = u'`Language`'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Enable Markdown
MARKDOWN = {
	`MarkdownExtensions`
	}

# Theme

THEME = '`Theme`'

# Blogroll
LINKS = `Links`

# Social widget
SOCIAL = `Social`

DEFAULT_PAGINATION = `PaginationNumber`

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = `UseRelativeURLs`";


pelicanAtomPrep[s_String]:=
	"'"<>s<>"'";
pelicanAtomPrep[e_]:=
	ToString[e];


pelicanDictPrep[k_->v_?AtomQ]:=
	k<>": "<>pelicanAtomPrep[v];
pelicanDictPrep[k_->e_]:=
	pelicanDictPrep[k,pelicanDictPrep[e]];
pelicanDictPrep[l_List?OptionQ]:=
	"{\n\t"<>
		StringRiffle[pelicanDictPrep/@l,",\n\t"]<>
		"\n\t}";
pelicanDictPrep[a_Association]:=
	pelicanDictPrep[Normal[a]];


pelicanSettingsPrep[ops_]:=
	Association@
		KeyValueMap[
			#->
				Switch[#,
					"Links"|"Social",
						StringReplace[
							"(``,)"~TemplateApply~
								StringRiffle[
									Map[
										TemplateApply[
											"( '``', '``' )",
											Take[Flatten@ConstantArray[List@@#,2],2]
											]&,
										Replace[#2,a_?AtomQ:>{a,a},1]
										],
									","
									],
							"(,)"->"()"
							],
					"MarkdownExtensions",
						pelicanDictPrep[If[!OptionQ[#2],{},#2]],
					_,
						#2
					]&,
			Association[ops]
			]


pelicanNewSiteTestingNB[assoc_]:=
	Notebook[{
		Cell[Lookup[assoc,"Title","Untitled"],"Section"],
		Cell[BoxData@RowBox@{"<<","BTools`"},"Input"],
		(*Settings*)
		Cell[
			CellGroupData[{
				Cell["Settings","Subsection"],
				Cell[
					CellGroupData[{
						Cell["Open Pelican Settings","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									SystemOpen@FileNameJoin@{NotebookDirectory[],"pelicanconf.py"}
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Open Publish Settings","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									SystemOpen@FileNameJoin@{NotebookDirectory[],"publishconf.py"}
									],
							"Input"
							]
						}]
					]
				}]
			],
		(*Openers*)
		Cell[
			CellGroupData[{
				Cell["Pages","Subsection"],
				Cell[
					CellGroupData[{
						Cell["List Pages","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									FileNames[
										"*.md",
										FileNameJoin@{NotebookDirectory[],"content"},
										\[Infinity]
										]
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Open Page","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									BTools`Formatting`openPage[BTools`Formatting`page_]:=
										SystemOpen@
											FileNameJoin@{
												NotebookDirectory[],
												"content",
												BTools`Formatting`page
												}
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["New Page","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									PelicanNewFile[
										BTools`Formatting`name,
										BTools`Formatting`ops
										]
									],
							"Input"
							]
						}]
					]
				}]
			],
		Cell[
			CellGroupData[{
				Cell["Images","Subsection"],
				Cell[
					CellGroupData[{
						Cell["List Images","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									FileNames[
										"*.png"|"*.gif"|"*.jpg",
										FileNameJoin@{NotebookDirectory[],"img"},
										\[Infinity]
										]
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Open Image","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									BTools`Formatting`openImage[BTools`Formatting`img_]:=
										SystemOpen@
											FileNameJoin@{
												NotebookDirectory[],
												"img",
												BTools`Formatting`img
												}
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Export Image","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									BTools`Formatting`exportImage[
										BTools`Formatting`name_,
										BTools`Formatting`img_
										]:=
										Export[
											FileNameJoin@{
												NotebookDirectory[],
												"img",
												If[FileExtension[BTools`Formatting`name]=="",
													BTools`Formatting`name<>".png",
													BTools`Formatting`name
													]
												},
											BTools`Formatting`img
											]
									],
							"Input"
							]
						}]
					]
				}]
			],
		Cell[
			CellGroupData[{
				Cell["Build","Subsection"],
				Cell[
					CellGroupData[{
						Cell["Build Site","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									PelicanBuild[]
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Open Site","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									PySimpleServerOpen[
										FileNameJoin@{NotebookDirectory[],"output"}
										]
									],
							"Input"
							]
						}]
					],
				Cell[
					CellGroupData[{
						Cell["Deploy Site","Subsubsection"],
						Cell[
							BoxData@ToBoxes@
								Unevaluated[
									PelicanDeploy[]
									],
							"Input"
							]
						}]
					]
				}]
			]
		},
		CellContext->Notebook
		]


Options[PelicanNewSite]=
	{
		"Title"->"",
		"Author"->"",
		"URL"->"",
		"Timezone":>LocalTimeZone[Here,Today,"InternetName"],
		"PaginationNumber"->10,
		"UseRelativeURLs"->True,
		"Language":>ToLowerCase@StringTake[$Language,2],
		"PagesFolder"->True,
		"Links"->{},
		"Social"->{},
		"Theme"->"simple",
		"MarkdownExtensions"->{}
		};
PelicanNewSite[
	contentDir:_String?DirectoryQ,
	open:True|False:True,
	ops:OptionsPattern[]
	]:=
	With[{op=
		pelicanSettingsPrep@
			Join[
				Options[PelicanNewSite],
				{
					ops
					}
				]
		},
		If[open,
			#["Notebook"]//SystemOpen,
			#
			]&@
		<|
			"BuildSettings"->
				Export[FileNameJoin@{contentDir,"pelicanconf.py"},
					TemplateApply[
						$pelicanconf,
						op
						],
					"Text"
					],
			"PublishSettings"->
				Export[FileNameJoin@{contentDir,"publishconf.py"},
					TemplateApply[
						$pelicanpublishconf,
						op
						],
					"Text"
					],
			"ContentDirectory"->
				(
					If[!DirectoryQ@FileNameJoin@{contentDir,"content"},
						CreateDirectory[FileNameJoin@{contentDir,"content"}]
						];
					FileNameJoin@{contentDir,"content"}
					),
			If[OptionValue["PagesFolder"]//TrueQ,
				"PagesDirectory"->
					(
						If[!DirectoryQ@FileNameJoin@{contentDir,"content","pages"},
							CreateDirectory[FileNameJoin@{contentDir,"content","pages"}]
							];
						FileNameJoin@{contentDir,"content","pages"}
						),
				Nothing
				],
			"OutputDirectory"->
				(
					If[!DirectoryQ@FileNameJoin@{contentDir,"output"},
						CreateDirectory[FileNameJoin@{contentDir,"output"}]
						];
					FileNameJoin@{contentDir,"output"}
					),
			"Notebook"->
				Export[
					FileNameJoin@{contentDir,"edit.nb"},
					Block[{$Context="BTools`Formatting`"},
						pelicanNewSiteTestingNB[op]
						]
					]
			|>
		];
PelicanNewSite[
	s_String,
	open:True|False:True,
	ops:OptionsPattern[]
	]:=
	PelicanNewSite[
		If[!DirectoryQ[#],
			CreateDirectory[#,CreateIntermediateDirectories->True],
			#
			]&@FileNameJoin@{$PelicanSitesDirectory,s},
		open,
		ops
		];


$PelicanSiteSettingsBoundary="\" ----!!!!----!!!!-----!!!!----- \"";


PelicanSiteSettings[
	site_String?DirectoryQ,
	settings:(_String|{__String}|All):All
	]:=
	Replace[
		SetDirectory[site];
		(ResetDirectory[];#)&@
			PyVenvRun["pelican",
				{
					"python",
					"-c",
					"'"<>(
						StringRiffle[{
							"from __future__ import print_function",
							"from pelicanconf import *",
							"glob = locals()",
							"print(0, end=`boundary`)",
							If[settings === All,
								"[ print(\"-\",\"\\\"\"+s+\"\\\"\",\"->\",\"\\\"\",glob[s],\"\\\"\",\"-\", end=`boundary`, sep=\"\") if s not in (\"glob\", \"unicode_literals\", \"print_function\", \"__name__\", \"__builtins__\") else None for s in glob.keys() ]",
								"[ print(\"-\",glob[s],\"-\", end=`boundary`, sep=\"\") if s in glob else print(\"$Failed\",end=`boundary`) for s in `settings` ]"
								],
							"print(0, end=`boundary`)"
							},
							"; "
							]~TemplateApply~<|
								"boundary"->
									$PelicanSiteSettingsBoundary,
								"settings"->
									If[settings===All,
										"",
										"["<>StringRiffle["\""<>#<>"\""&/@Flatten@{settings},", "]<>"]"
										]
								|>
						)<>"'"
				}
				],
		a_Association:>
			If[settings === All,
				Association@
					ToExpression@
						StringTrim[
							Most@Rest@
								StringSplit[
									a["StandardOutput"],
									StringTrim[$PelicanSiteSettingsBoundary,"\""]
									],
							"-"
							],
				AssociationThread[
					settings,
					StringTrim[
						Most@Rest@
							StringSplit[
								a["StandardOutput"],
								StringTrim[$PelicanSiteSettingsBoundary,"\""]
								],
						"- "|" -"
						]
					]
				]
		]
PelicanSiteSettings[s_String,settings:(_String|{__String}|All):All]:=
	If[DirectoryQ[FileNameJoin@{$PelicanRoot,s}],
		PelicanSiteSettings[FileNameJoin@{$PelicanRoot,s},settings],
		$Failed
		]


$pelicannewmdfiletemplate=
"
`headers`

`body`
";


pelicanFileMetadataTitle[t_,name_]:=
	Replace[t,
		{
			Automatic:>name
			}];


pelicanFileMetadataSlug[t_,name_]:=
	Replace[t,
		{
			Automatic:>
				ToLowerCase@
					StringReplace[pelicanFileMetadataTitle[t,name],Whitespace->"-"]
			}];


pelicanFileMetadata[val_]:=
	Replace[val,{
		_List:>
			StringRiffle[ToString/@val,","],
		_DateObject:>
			StringReplace[DateString[val,"ISODateTime"],"T"->" "]
		}]


pelicanMetadataFormat[name_,ops_]:=
	Function[StringRiffle[#,"\n"]]@
		KeyValueMap[
			#<>": "<>
				ToString@
					Switch[#,
						"Title",
							pelicanFileMetadataTitle[#2,name],
						"Slug",
							pelicanFileMetadataSlug[#2,name],
						_,
							pelicanFileMetadata[#2]
						]&,
			KeySortBy[
				Switch[#,"Title",0,_,1]&
				]@
				Association@ops
			];


Options[PelicanNewFile]=
	{
		"Title"->Automatic,
		"Date":>Now,
		"Modified":>Now,
		"Category"->None,
		"Tags"->{},
		"Slug"->Automatic,
		"Authors"->{},
		"Summary"->None,
		"Status"->None,
		"Body"->"",
		"Folder"->"posts",
		"Notebook"->True
		};
PelicanNewFile[
	site:(_String?DirectoryQ|Automatic):Automatic,
	name_String,
	open:True|False:True,
	ops:OptionsPattern[]
	]:=
	With[{siteDir=Replace[site,Automatic:>NotebookDirectory[]]},
		If[!DirectoryQ@
			FileNameJoin@{
				siteDir,
				"content",
				Replace[OptionValue["Folder"],
					Except[_String]->Nothing
					]
				},
			CreateDirectory[
				FileNameJoin@{
					siteDir,
					"content",
					Replace[OptionValue["Folder"],
						Except[_String]->Nothing
						]
					},
				CreateIntermediateDirectories->True
				]
			];
		If[OptionValue["Notebook"]//TrueQ,
			If[open,SystemOpen,Identity]@
				Export[
					FileNameJoin@{
						siteDir,
						"content",
						Replace[OptionValue["Folder"],
							Except[_String]->Nothing
							],
						name<>".nb"
						},
					Notebook[
						{
							Cell[
								BoxData@ToBoxes@
									DeleteCases[None]@
										KeyDrop[
											Association@
												Join[
													Options[PelicanNewFile],
													{
														ops
														}
													],
											{"Body","Folder","Notebook"}
											],
								"Metadata"
								],
							Cell[
								Lookup[{ops},"Body",""],
								"Text"
								]
							},
						StyleDefinitions->
							FrontEnd`FileName[
								Evaluate@{`Package`$PackageName},
								"PelicanMarkdown.nb"
								]
						]
					],
		If[open,SystemOpen,Identity]@
			Export[
				FileNameJoin@{siteDir,
					"content",
					Replace[OptionValue["Folder"],
						Except[_String]->Nothing
						],
					name<>".md"},
				StringTrim@
					TemplateApply[
						$pelicannewmdfiletemplate,
						<|
							"headers"->
								pelicanMetadataFormat[
									name,
									DeleteCases[None]@
										KeyDrop[
											Association@
												Join[
													Options[PelicanNewFile],
													{
														ops
														}
													],
											{"Body","Folder","Notebook"}
											]
									],
							"body"->OptionValue["Body"]
							|>
						],
				"Text"
				]
			]
		]


PelicanBuild[f_String?(FileExistsQ[#]&&MemberQ[FileNameSplit[#],"content"]&)]:=
	With[{path=Reverse@FileNameSplit[f]},
		PelicanBuild[
			FileNameJoin@Reverse@Flatten@#[[3;;]],
			FileNameJoin@Reverse@#[[1]]
			]&@SplitBy[path,MatchQ["content"]]
		];
PelicanBuild[
	site:(_String?DirectoryQ|Automatic):Automatic,
	file:_String?(Not@*FileExistsQ)|All:All
	]:=
	With[{
		startedRunning=
			MatchQ[
				$PyVenv["Environment"],
				_String?(StringEndsQ["pelican"])
				],
		siteDir=Replace[site,Automatic:>NotebookDirectory[]]
		},
		If[!PelicanInitializedQ[],PelicanInitialize[]];
		If[!startedRunning,PyVenvStart["pelican"]];
		PyVenvRun["pelican",
			{"cd",File@ExpandFileName[siteDir]}
			];
		SetDirectory[siteDir];
		(ResetDirectory[];If[!startedRunning,PyVenvKill[]];#)&@
			If[file===All,
				PyVenvRun["pelican",
					"pelican",
					TimeConstraint->10
					],
				PyVenvRun["pelican",
					{"pelican","--write-selected",File[FileNameJoin@{"output",file}]},
					TimeConstraint->10
					]
				]
		];


PelicanDeploy[
	file:(_String?(FileExistsQ@#&&Not@DirectoryQ@#&)),
	uri:_String|Automatic:Automatic,
	ops:OptionsPattern[]
	]:=
	PelicanDeploy[
		PelicanSiteBase[file],
		FileNameForms->FileNameJoin@{"output",PelicanOutputPath[file]},
		ops
		]


Options[PelicanDeploy]=
	Options[WebSiteDeploy];
PelicanDeploy[
	site:(_String?DirectoryQ|Automatic),
	uri:_String|Automatic:Automatic,
	ops:OptionsPattern[]
	]:=
	With[{
		outDir=
			PelicanSiteBase[Replace[site,Automatic:>NotebookDirectory[]]]
		},
		With[{
			info=
				If[FileExistsQ[FileNameJoin@{outDir,"deployInfo.m"}],
					Import[FileNameJoin@{outDir,"deployInfo.m"}],
					{}
					]
			},
			Export[FileNameJoin@{outDir,"deployInfo.m"},
				KeyDrop[
					Association@
						Flatten@{
							Normal@info,
							ops,
							"LastDeployment"->Now
							},
					FileNameForms
					]
				];
			WebSiteDeploy[
				FileNameJoin@{outDir,"output"},
				Replace[uri,Automatic:>FileBaseName[outDir]],
				Flatten@{
					ops,
					Normal@info
					}
				]
			]
		];
PelicanDeploy[
	s_String?(Not@*DirectoryQ),
	uri:_String|Automatic:Automatic,
	ops:OptionsPattern[]
	]:=
	If[DirectoryQ@FileNameJoin@{$PelicanRoot,s,"output"},
		PelicanDeploy[
			FileNameJoin@{$PelicanRoot,s},
			uri,
			ops
			],
		$Failed
		]


PelicanThemes[Optional["List","List"],verbose:True|False:False]:=
	PyVenvRun["pelican",
		{"pelican-themes","-l",If[verbose,"-v",Nothing]}
		]


PelicanThemes["Install",f_String?FileExistsQ]:=
	PyVenvRun["pelican",
		{"pelican-themes","--install",f}
		];
PelicanThemes["Install",f_String]:=
	With[{u=
		If[GitHubRepoQ[f],
			GitHub["Clone",f,
				FileNameJoin@{$TemporaryDirectory,StringTrim[URLParse[f,"Path"][[-1]],"pelican-"]}
				],
			If[FileExtension[#]==="zip",
				First@
					MinimalBy[Select[ExtractArchive[#],DirectoryQ],FileNameDepth],
				#
				]&@
				URLDownload[f,StringTrim[URLParse[f,"Path"][[-1]],"pelican-"]]
			]
		},
		PelicanThemes["Install",u]
		]


PelicanNotebookMetadata[c:{Cell[_BoxData,"Metadata",___]...}]:=
	Join@@Select[Normal@ToExpression[First@First@#]&/@c,OptionQ];
PelicanNotebookMetadata[nb_Notebook]:=
	PelicanNotebookMetadata@
		Cases[
			NotebookTools`FlattenCellGroups[First@nb],
			Cell[_BoxData,"Metadata",___]
			];
PelicanNotebookMetadata[nb_NotebookObject]:=
	PelicanNotebookMetadata@
		Cases[
			NotebookRead@Cells[nb,CellStyle->"Metadata"],
			Cell[_BoxData,___]
			]


PelicanNotebookToMarkdown//Clear


PelicanNotebookToMarkdown[nb_NotebookObject]:=
	With[{dir=
		NotebookDirectory[nb]
		},
		If[!DirectoryQ[dir],
			$Failed,
			With[{
				d2=
					PelicanSiteBase[dir],
				path=
					FileNameJoin@ConstantArray["..",1+FileNameDepth[PelicanContentPath[dir]]]
				},
				StringRiffle[
					DeleteCases[""]@
						PelicanNotebookToMarkdown[
							d2,
							path,
							#
							]&/@NotebookRead@
							Cells[nb,
								CellStyle->{
									"Section","Subsection","Subsubsection",
									"Code","Output","Text",
									"Quote","PageBreak","Item","Subitem"
									}
								],
					"\n\n"
					]
				]
			]
		];


PelicanNotebookToMarkdown[root_,path_,Cell[a___,CellTags->t_,b___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,Cell[a,b]],
		s:Except[""]:>
			TemplateApply[
				"<a id=\"``\" >&zwnj;</a>",
				ToLowerCase@StringJoin@Flatten@{t}
				]<>"\n\n"<>s
		];
PelicanNotebookToMarkdown[root_,path_,Cell[a___,FontSlant->"Italic"|Italic,b___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,Cell[a,b]],
		s:Except[""]:>
			"_"<>s<>"_"
		];
PelicanNotebookToMarkdown[root_,path_,Cell[a___,FontWeight->"Bold"|Bold,b___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,Cell[a,b]],
		s:Except[""]:>
			"*"<>s<>"*"
		];
PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Section",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>
			Replace[
				FrontEndExecute@
					ExportPacket[Cell[t],"PlainText"],{
				{id_String,___}:>
					TemplateApply[
						"<a id=\"``\" >&zwnj;</a>",
						ToLowerCase@StringReplace[id,Whitespace->"-"]
						]<>"\n\n",
				_->""
				}]<>
			"# "<>s
		];
PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Subsection",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>"## "<>s
		];
PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Subsubsection",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>
			"### "<>s
		];


PelicanNotebookToMarkdown[root_,path_,Cell[t_,"PageBreak",___]]:=
	"---"


PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Text",___]]:=
	PelicanNotebookToMarkdown[root,path,t];


PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Item",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>"* "<>s
		];
PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Subitem",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>"  * "<>s
		];


PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Quote",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>StringReplace[s,StartOfString->"> "]
		];


PelicanNotebookToMarkdown[root_,path_,Cell[t_,"Quote",___]]:=
	Replace[PelicanNotebookToMarkdown[root,path,t],
		s:Except[""]:>StringReplace[s,StartOfString->"> "]
		];


PelicanNotebookToMarkdownOutputStringForms=
	_TooltipBox|_GraphicsBox;


$PelicanNotebookToMarkdownToStripStart=
	"\"<!STRIP_ME_FROM_OUTPUT>";
$PelicanNotebookToMarkdownToStripEnd=
	"</!STRIP_ME_FROM_OUTPUT>\""


$PelicanNotebookToMarkdownUnIndentedLine=
	"\"<!NO_INDENT>\"";


pelicanCodeCellGraphicsFormat[root_,path_,e_,
	style_,postFormat_]:=
	Replace[
		StringReplace[
			First@
			FrontEndExecute@
				FrontEnd`ExportPacket[
					Cell[e/.{
						g:PelicanNotebookToMarkdownOutputStringForms:>
							Replace[PelicanNotebookToMarkdown[root,path,g],
								s:Except[""]:>
									"\n"<>$PelicanNotebookToMarkdownUnIndentedLine<>
										$PelicanNotebookToMarkdownToStripStart<>
											StringTrim@s<>
											$PelicanNotebookToMarkdownToStripEnd<>"\n"
								],
						s_String?(StringMatchQ["\t"..]):>
							StringReplace[s,"\t"->" "]
						}],
					style
					],{
				$PelicanNotebookToMarkdownUnIndentedLine~~" \\\n"->
					$PelicanNotebookToMarkdownUnIndentedLine,
				$PelicanNotebookToMarkdownToStripStart~~
					inner:Shortest[__]~~
					$PelicanNotebookToMarkdownToStripEnd:>
					StringReplace[inner,"\\\n"->""]
				}],
		s:Except[""]:>
				StringReplace[postFormat@s,{
				("\t"...)~~$PelicanNotebookToMarkdownUnIndentedLine->
					""
				}]
		];


PelicanNotebookToMarkdown[root_,path_,Cell[e_,"Code"|"Input",___]]:=
	pelicanCodeCellGraphicsFormat[root,path,e,
		"InputText",
		StringReplace[#,StartOfLine->"\t"]&
		];
PelicanNotebookToMarkdown[root_,path_,Cell[e_,"InlineInput",___]]:=
	pelicanCodeCellGraphicsFormat[root,path,e,
		"InputText",
		"```"<>#<>"```"&
		];
PelicanNotebookToMarkdown[root_,path_,Cell[e_,"Output",___]]:=
	pelicanCodeCellGraphicsFormat[root,path,e,
		"PlainText",
		StringReplace["(*Out:*)\n\n"<>#,{
			StartOfLine->"\t"
			}]&
		]


PelicanNotebookToMarkdown[root_,path_,s_String]:=
	s;
PelicanNotebookToMarkdown[root_,path_,s_TextData]:=
	StringRiffle[
		Map[PelicanNotebookToMarkdown[root,path,#]&,List@@s//Flatten]
		];
PelicanNotebookToMarkdown[root_,path_,b_BoxData]:=
	Replace[
		PelicanNotebookToMarkdown[root,path,First@b],
		"":>
			First@
				FrontEndExecute@
					FrontEnd`ExportPacket[
						Cell[b],
						"PlainText"
						]
		];
PelicanNotebookToMarkdown[root_,path_,Cell[e_,___]]:=
	PelicanNotebookToMarkdown[root,path,e]


PelicanNotebookToMarkdown[
	root_,
	path_,
	ButtonBox[d_,
		o___,
		BaseStyle->"Hyperlink",
		r___
		]]:=
	With[{t=PelicanNotebookToMarkdown[root,path,d]},
		"["<>t<>"]("<>
			PelicanNotebookToMarkdown[root,path,
				FirstCase[
					Flatten@List@Replace[
						Lookup[{o,r},ButtonData,t],
						s_String?(StringFreeQ["/"]):>"#"<>s
						],
					_String|_FrontEnd`FileName|_URL|_File,
					t
					]
				]<>")"
		];


PelicanNotebookToMarkdown[
	root_,
	path_,
	ButtonBox[d_,
		o___,
		BaseStyle->"Link",
		r___
		]]:=
	With[{t=PelicanNotebookToMarkdown[root,path,d]},
		"[```"<>t<>"```]("<>
			Replace[
				FirstCase[
					Flatten@{Lookup[{o,r},ButtonData,t]},
					_String,
					t
					],
				s_String:>
					With[{page=
						Replace[Documentation`ResolveLink[s],
							Null:>
								If[StringStartsQ[s,"paclet:"],
									FileNameJoin@URLParse[s,"Path"],
									FileNameJoin@{"ref",s}
									]
							]},
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
											{___,"English",e___}:>
												FileNameJoin@{e},
											{___,a_,b_,c_}:>
												FileNameJoin@{a,b,c},
											_:>
												page
											}]
							}
						]
				]
			<>")"
		];


PelicanNotebookToMarkdown[
	root_,
	path_,
	TooltipBox[g_GraphicsBox,t_,___]
	]:=
	With[{h=Hash[g]},
		If[!DirectoryQ[FileNameJoin@{root,"content","img"}],
			CreateDirectory[FileNameJoin@{root,"content","img"}]
			];
		If[!FileExistsQ[FileNameJoin@{root,"content","img",ToString[h]<>".png"}],
			Export[
				FileNameJoin@{root,"content","img",ToString[h]<>".png"},
				ToExpression@g
				]
			];
		"!["<>"image-"<>ToString[h]<>"]("<>
			StringRiffle[{"{filename}","img",ToString[h]<>".png"},"/"]<>")"
		]
PelicanNotebookToMarkdown[
	root_,
	path_,
	g_GraphicsBox
	]:=
	With[{h=Hash[g]},
		If[!DirectoryQ[FileNameJoin@{root,"content","img"}],
			CreateDirectory[FileNameJoin@{root,"content","img"}]
			];
		If[!FileExistsQ[FileNameJoin@{root,"content","img",ToString[h]<>".png"}],
			Export[
				FileNameJoin@{root,"content","img",ToString[h]<>".png"},
				ToExpression@g
				]
			];
		"!["<>"image-"<>ToString[h]<>"]("<>
			StringRiffle[{"{filename}","img",ToString[h]<>".png"},"/"]<>")"
		]


PelicanNotebookToMarkdown[root_,path_,f_FrontEnd`FileName]:=
	StringRiffle[FileNameSplit[ToFileName[f]],"/"];
PelicanNotebookToMarkdown[root_,path_,u:_URL]:=
	First@u;
PelicanNotebookToMarkdown[root_,path_,f_File]:=
	StringRiffle[FileNameSplit[First[f]],"/"];


PelicanNotebookToMarkdown[root_,path_,e_]:=
	"";


PelicanNotebookSave[
	nbObj:_NotebookObject|Automatic:Automatic
	]:=
	With[{nb=Replace[nbObj,Automatic:>InputNotebook[]]},
		With[{meta=
			pelicanMetadataFormat[
				FileBaseName@NotebookFileName[nb],
				Association@
					Flatten[
						{
							"Modified":>Now,
							PelicanNotebookMetadata[nb]
							}
						]
				]
			},
			Export[
				StringReplace[NotebookFileName[nb],".nb"~~EndOfString->".md"],
				StringTrim@
					TemplateApply[
						$pelicannewmdfiletemplate,
						<|
							"headers"->meta,
							"body"->PelicanNotebookToMarkdown[nb]
							|>
						],
				"Text"
				]
			]
		]


End[];



