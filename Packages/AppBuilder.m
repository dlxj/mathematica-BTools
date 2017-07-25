(* ::Package:: *)

$packageHeader

(* ::Section:: *)
(*AppBuilder*)



(* ::Subsubsection::Closed:: *)
(*Find*)



$AppDirectoryRoot::usage="The directory root for finding apps";
$AppDirectoryName::usage="The basic extension to a directory for locating apps";
$AppDirectory::usage="Joins the root and name";
AppPath::usage=
	"A path parser for a given app name";
AppDirectory::usage=
	"Used by AppPath find appropriate directories";
AppNames::usage="Finds the names of apps matching a pattern";
AppPackage::usage="A function to find a package by name";
AppPackages::usage=
	"Finds the packages in a given app";
AppStylesheet::usage="A function to find a stylesheet by name";


(* ::Subsubsection::Closed:: *)
(*Edit*)



AppConfigure::usage=
	"Compiles an application from a series of packages or definitions";
AppConfigureSubapp::usage=
	"Creates a subapplication out of a set of packages or specs";


AppAddContent::usage="Adds a file to the app";


(*
AppAddPackage::usage="Adds a package";
AppAddPalette::usage="Adds a palette to the app";
AppAddStylesheet::usage="Adds a stylesheet to the app";
AppAddDocPage::usage="Adds a doc page for a symbol to the app";
AppAddGuidePage::usage="Adds a guide to the app";
AppAddTutorialPage::usage="Adds a tutorial page to the app";
*)


AppRegenerateDirectories::usage=
	"Regerates missing directories in the app";
AppRegenerateInit::usage=
	"Regenerates a default init file";


(* ::Subsubsection::Closed:: *)
(*Analyze*)



AppGet::usage=
	"Runs get on the specified app package";
AppNeeds::usage=
	"Runs Needs on the specified package";
AppPackageOpen::usage=
	"Opens a package .m file";
AppFromFile::usage=
	"Gets an app from the current file";


AppGenerateTestingNotebook::usage=
	"Generates a standard testing notebook for an app";


AppPackageFunctions::usage=
	"Gets the function names declared in a package or set of packages";
AppFunctionDependencies::usage=
	"Gets the package dependency chain for a function";
AppPackageDependencies::usage=
	"Gets the dependency structure for a full app package";


(* ::Subsubsection::Closed:: *)
(*Docs*)



AppRegenerateDocInfo::usage=
	"Regenerates the DocInfo.m file";
AppIndexDocs::usage=
	"Indexes the doc pages of an app";
AppSymbolNotebook::usage=
	"Generates a doc template for an app";
AppPackageSymbolNotebook::usage=
	"Generates a doc template for a package";
AppGuideNotebook::usage=
	"Generates a guide overview for the app";
AppPackageGuideNotebook::usage=
	"Generates a guide overview for a package";
AppTutorialNotebook::usage=
	"Generates a tutorial overview for the app";
AppDocumentationTemplate::usage=
	"Creates a total documentation template for an app";


AppSaveSymbolPages::usage=
	"Saves auto-generated symbol pages";
AppPackageSaveSymbolPages::usage=
	"Saves auto-generated symbol pages for a package";
AppSaveGuide::usage=
	"Saves an auto-generated guide for an app";
AppPackageSaveGuide::usage=
	"Saves auto-generated guide for a package";


AppGenerateDocumentation::usage=
	"Generates symbol pages and guide page for an app";
AppPackageGenerateDocumentation::usage=
	"Generates symbol pages and guide page for a package";


AppGenerateHTMLDocumentation::usage=
	"Generates HTML documentation for an app"; 


(* ::Subsubsection::Closed:: *)
(*Distribute*)



AppRegenerateBundleInfo::usage=
	"Regenerates the BundleInfo file";
AppRegenerateLoadInfo::usage=
	"Regenerates the LoadInfo file";
AppBundle::usage="Creates a sync bunde for an app";
AppUpload::usage="Uploads an application zip to the cloud";
AppDownload::usage="Downloads an app into a directory";
AppInstall::usage="Downloads/installs an application";
AppBackup::usage="Backs up the app";
AppBackups::usage="Gets all the backed-up versions of the app";
AppRestore::usage="Restores the most recent version of the app";
$AppCloudExtension::usage="The cloud extension for applications";


(* ::Subsubsection::Closed:: *)
(*Project*)



AppDeployReadme::usage=
	"Deploys the app README.md file";
AppDeployHTML::usage=
	"Deploys app HTML files";
AppDeployImages::usage=
	"Deploys the app img files";
AppDeployCSS::usage=
	"Deploys the app css files";


(* ::Subsubsection::Closed:: *)
(*Git*)



AppGitInit::usage=
	"Configures a Git repository for the app";
AppGitClone::usage=
	"Clones a Git repo";
AppGitCommit::usage=
	"Configures pushes to the git repo";
AppRegenerateGitIgnore::usage=
	"Rebuilds the .gitignore file";
AppRegenerateGitExclude::usage=
	"Rebuilds the .git/info/exclude file";


AppGitHubConfigure::usage=
	"Configures the app to be able to push to github";
AppGitHubPull::usage=
	"Pulls the app from its master branch";
AppGitHubPush::usage=
	"Pushes the app to its master branch"
AppGitHubDelete::usage=
	"Removes a repo from github";


AppRegenerateReadme::usage=
	"Generates a GitHub README.md file for the app";


(* ::Subsubsection::Closed:: *)
(*Paclets*)



AppRegenerateUploadInfo::usage=
	"Regenerates the UploadInfo.m file";
AppPacletBundle::usage=
	"Packs the .paclet file, removing the specified paths first";
AppPaclet::usage=
	"Generates the paclet expression for app";
AppPacletInfo::usage=
	"Gathers paclet info as an association";
AppRegeneratePacletInfo::usage=
	"Regenerates the PacletInfo file";
AppPacletSiteBundle::usage=
	"Generates the PacletSite.mz file for a collection of apps";
AppPacletSiteInfo::usage=
	"Pulls PacletSite expressions";
AppPacletUpload::usage=
	"Uploads paclet files to a server";
AppPacletDirectoryAdd::usage=
	"PacletDirectoryAdd on an app name";
AppPacletSiteURL::usage=
	"Gets an app paclet site to add";
AppPacletInstallerURL::usage=
	"Gets the URL to the auto-configured installer";
AppPacletUninstallerURL::usage=
	"Gets the URL to the auto-configure uninstaller";


AppSubpacletUpload::usage=
	"Uploads a sub-app";


AppPacletServerPage::usage=
	"Uploads a paclet access page to a server";


Begin["`Private`"];


(* ::Subsection:: *)
(*Builder*)



If[$appBuilderConfigLoaded//TrueQ//Not,
	$AppDirectoryRoot=$UserBaseDirectory;
	$AppDirectoryName="Applications";
	$AppDirectory:=
		FileNameJoin@{$AppDirectoryRoot,$AppDirectoryName};
	Replace[
		SelectFirst[
			`Package`PackageFilePath["Private","AppBuilderConfig."<>#]&/@{"m","wl"},
			FileExistsQ
			],
			f_String:>Get@f
		]
	];
$appBuilderConfigLoaded=True


(* ::Subsubsection::Closed:: *)
(*AppPath*)



AppPath[app_,e___]:=
	AppDirectory[app,e];


(* ::Subsubsection::Closed:: *)
(*AppDirectory*)



AppDirectory[app_,extensions___]:=
	FileNameJoin@Flatten@{
		$AppDirectoryRoot,$AppDirectoryName,app,
		Replace[{extensions},{
				"Palettes"->{"FrontEnd","Palettes"},
				"StyleSheets"->{"FrontEnd","StyleSheets"},
				"Guides"->{"Documentation","English","Guides"},
				"ReferencePages"->{"Documentation","English","ReferencePages"},
				"Symbols"->{"Documentation","English","ReferencePages","Symbols"},
				"Tutorials"->{"Documentation","English","Tutorials"},
				"Objects"->{"Objects"},
				"Private"->{"Private"}
				},
			1]};


AppPackage[app_:Automatic,pkg_String]:=
	Replace[
		AppPath[AppFromFile[app],"Packages",pkg],{
			f_?FileExistsQ:>
				f,
			f_:>
				If[FileExtension@f==="",
					SelectFirst[f<>#&/@{".nb",".m",".wl"},
						FileExistsQ
						],
					Missing["NotFound"]]
			}]


AppStylesheet[app_:Automatic,stylesheet_String]:=
	AppDirectory[AppFromFile[app],"StyleSheets",stylesheet<>".nb"]


(* ::Subsubsection::Closed:: *)
(*configureDirectories*)



configureDirectories[name_String]:=
Do[
If[Not@DirectoryQ@
			FileNameJoin@Flatten@{$AppDirectoryRoot,$AppDirectoryName,dir},
CreateDirectory@
			FileNameJoin@Flatten@{$AppDirectoryRoot,$AppDirectoryName,dir}
		],
{dir,
Table[Flatten@{name,e},
{e,
{"Kernel",
"FrontEnd",
"Packages",
				{"Packages","__Future__"},
{"FrontEnd","Palettes"},
				{"FrontEnd","Palettes",name},
{"FrontEnd","StyleSheets"},
				{"FrontEnd","StyleSheets",name},
"Documentation",
{"Documentation","English"},
				"Objects",
				"Private",
				$AppProjectExtension,
				{$AppProjectExtension,$AppProjectImages},
				{$AppProjectExtension,$AppProjectCSS}
}
}]~Prepend~name
}
];
AppRegenerateDirectories[app_String]:=
	configureDirectories[app];


(* ::Subsubsection::Closed:: *)
(*getDefinitions*)



getDefinitions[defs:(_Symbol|_String?(StringMatchQ[RegularExpression[".+`"]]))..]:=
	Replace[Thread[Hold[{defs}]],
		{Hold[def_String]:>
			Append[
				Prepend[
					ToExpression[Names@(def<>"*"),StandardForm,Hold],
					Hold["Begin[\""<>def<>"\"];"]
					],
				"End[];"]
			},
		1]//Flatten//DeleteDuplicates//
	DeleteCases[#/.{
		Hold[s:Except[_Symbol]]:>s,
		Hold[s_]:>ToString[Definition[s],InputForm]
		},
		"Null"
		]&//StringJoin@Riffle[#,"\n\n"]&;
getDefinitions~SetAttributes~HoldAll


(* ::Subsubsection::Closed:: *)
(*configurePackages*)



configurePackages[
	name_?StringQ,
	packages:(_String|_Symbol|{(_String|_Symbol|{_String,_String|{__String}})..})
	]:=
	With[{
		files=
			Cases[
				Replace[Hold[packages],Hold[{p__}]:>Hold[p]],
				_String?FileExistsQ|{_String?FileExistsQ,_}
				],
		defs=
			getDefinitions@@
				Replace[
					Thread[
						Cases[Replace[Hold[packages],Hold[{p__}]:>Hold[p]],
							s:(_Symbol|_String?(StringMatchQ[RegularExpression[".+`"]])):>Hold[s]
							],
						Hold],
					Hold[{ds__}]:>Hold[ds]
					]
		},
		If[MatchQ[defs,_String],
			With[{defFile=
				OpenWrite@
					FileNameJoin@{
						$AppDirectoryRoot,
						$AppDirectoryName,
						name,"Packages",
						"ContextPackage.m"
						}
					},
				WriteString[defFile,defs];
				Close@defFile;
				]
			];
		
		Do[
			If[DirectoryQ@
				If[StringQ@f,
					f,
					First@f
					],
				CopyDirectory,
				CopyFile[##,OverwriteTarget->True]&
				][
				If[StringQ@f,
					f,
					First@f
					],
				(If[!FileExistsQ@#,
					If[DirectoryQ@
						If[StringQ@f,
							f,
							First@f
							],
						Quiet[
							DeleteDirectory@#;
							CreateDirectory[DirectoryName@#,
								CreateIntermediateDirectories->True
								]
							],
						CreateFile@#
						];
					];#)&@
				AppPath[name,"Packages",
					If[StringQ@f,
						FileNameTake@f,
						Sequence@@Flatten@{Last@f}
						]
					]
				],
			{f,files}
			]
		];
configurePackages~SetAttributes~HoldAll;


(* ::Subsubsection::Closed:: *)
(*InitTemplates*)



$appInitStrings:=
	Association[
		FileBaseName[#]->
			StringReplace[
				StringReplace[
					StringTrim[
						Import[#,"Text"],
						Verbatim["(* ::Package:: *)\n\n"]
						],
					"`"->"`tick`"
					],{
				"$InitCode"->"`cores`",
				"$Name"->"`name`"
				}]&/@
				FileNames[
					"*.wl",
					`Package`PackageFilePath[
						"Templates",
						"Initialization"
						]
					]
			]


appInitTemplate[pkg_]:=
	With[{strings=$appInitStrings},
		TemplateApply[
			TemplateApply[strings["__init__"],<|
				"cores"->
					StringRiffle[StringTrim/@{
						strings["Constants"],
						strings["Paths"],
						strings["Loading"],
						strings["Autocomplete"],
						strings["SyntaxInformation"],
						strings["Usage"],
						strings["FrontEnd"],
						strings["Objects"]
						},
						"\n"
						],
				"tick"->"`tick`",
				"name"->"`name`"
				|>],<|
			"name"->pkg,
			"tick"->"`"
			|>]
		];


(* ::Subsubsection::Closed:: *)
(*AppRegenerateInit*)



AppRegenerateInit[name]~`Package`PackageAddUsage~
	"regenerates the main package .m file for the application name";
AppRegenerateInit[name_String]:=
	With[{
		p=name<>"`"<>name<>"`",
		pkg=AppDirectory[name,name<>".wl"],
		init=AppDirectory[name,"Kernel","init.m"]
		},
		Export[pkg,appInitTemplate[name],"Text"];
		Put[Unevaluated[Get[p];],init]
		];


(* ::Subsubsection::Closed:: *)
(*configureDocs*)



configureDocs[
	app_String,
	docNotebooks:(_String|_File)?FileExistsQ..]:=
	Do[
		With[{f=
			FileNameJoin@Flatten@{
				$AppDirectoryRoot,
				$AppDirectoryName,
				app,
				"Documentation",
				"English",
				Replace[FileNameSplit@d,
					{___,"Documentation","English",p__}:>
						p
					]
				}
			},
			CopyFile[d,f,
				OverwriteTarget->True]
			],
		{d,docNotebooks}
		]


(* ::Subsubsection::Closed:: *)
(*AppPacletDocs*)



Options[AppPacletDocs]=
	Options[PacletDocsInfo]
AppPacletDocs[ops:OptionsPattern[]]:=
	PacletDocsInfo[ops];
AppPacletDocs[app_String,ops:OptionsPattern[]]:=
	PacletDocsInfo[AppDirectory[app],ops];


(* ::Subsubsection::Closed:: *)
(*AppPaclet*)



Options[AppPaclet]=
	Options[PacletExpression];
AppPaclet[ops:OptionsPattern[]]:=
	PacletExpression[ops];
AppPaclet[app_String,ops:OptionsPattern[]]:=
	PacletExpression[
		AppDirectory[app],
		"Kernel"->{
			Root -> ".",
			Context -> 
				Join[
					{app<>"`"},
					StringRiffle[
						Prepend[app]@
							FileNameSplit[
								FileNameDrop[#,
									FileNameDepth@AppDirectory[app,"Packages"]
									]
								],
						"`"]<>"`"
						&/@
						Select[
							FileNames["*",AppDirectory[app,"Packages"],\[Infinity]],
							DirectoryQ@#&&
								AllTrue[
									FileNameSplit@
										FileNameDrop[#,FileNameDepth@AppDirectory[app,"Packages"]],
									StringMatchQ[
										#,
										(WordCharacter|"$")..
										]
									]&
							]
					]
			},
		ops];


(* ::Subsubsection::Closed:: *)
(*AppPacletInfo*)



AppPacletInfo[app_String]:=
	PacletInfoAssociation@AppDirectory[app];


(* ::Subsubsection::Closed:: *)
(*AppRegeneratePacletInfo*)



Options[AppRegeneratePacletInfo]=
	Options[AppPaclet];
AppRegeneratePacletInfo[name_,
	pacletOps:OptionsPattern[]
	]:=
	PacletExpressionBundle[
		AppPaclet[name,pacletOps],
		AppDirectory[name]
		];


(* ::Subsubsection::Closed:: *)
(*AppConfigure*)



Options[AppConfigure]={
	Directory->Automatic,
	Extension->Automatic,
	"Palettes"->{},
	"Documentation"->{},
	"StyleSheets"->{},
	"AutoCompletionData"->{},
	"PacletInfo"->{},
	"BundleInfo"->{},
	"LoadInfo"->None,
	"UploadInfo"->None
	};
AppConfigure[
	name_?StringQ,
	packages:
		(_Symbol|Except[_Symbol]?(MatchQ[(_String|_File)?FileExistsQ]))|
			{(
				_Symbol|Except[_Symbol]?(MatchQ[(_String|_File)?FileExistsQ])|
					{
						Except[_Symbol]?(MatchQ[(_String|_File)?FileExistsQ]),
						Except[_Symbol]?(MatchQ[_String|{__String}])
						}
				)...}:
		None,
	ops:OptionsPattern[]
	]:=
	Block[{
		$AppDirectoryRoot=
			Replace[OptionValue@Directory,Automatic:>$AppDirectoryRoot],
		$AppDirectoryName=
			Replace[OptionValue@Extension,{
				Automatic:>$AppDirectoryRoot,
				Except[_String]->Nothing
				}]
		},
		configureDirectories@name;
		Replace[
			Hold[packages]/.{
				None->{},
				f:Except[_Symbol]:>
					With[{r=f},r/;True]
				},
			Hold[p__]:>configurePackages[name,p]
			];
		AppRegenerateInit@name;
		configureDocs[name,
			Sequence@@Flatten@{OptionValue@"Documentation"}
			];
		If[OptionValue["PacletInfo"]=!=None,
			AppRegeneratePacletInfo[name,
				Sequence@@Flatten@{OptionValue@"PacletInfo"}]
			];
		If[OptionValue["LoadInfo"]=!=None,
			AppRegenerateLoadInfo[name,OptionValue["LoadInfo"]]
			];
		If[OptionValue["UploadInfo"]=!=None,
			AppRegenerateUploadInfo[name,OptionValue["UploadInfo"]]
			];
		If[OptionValue["BundleInfo"]=!=None,
			AppRegenerateBundleInfo[name,OptionValue["BundleInfo"]]
			];
		FileNameJoin@{$AppDirectoryRoot,$AppDirectoryName,name}
		];
AppConfigure~SetAttributes~HoldAll;


(* ::Subsubsection::Closed:: *)
(*AppConfigureSubapp*)



Options[AppConfigureSubapp]=
	DeleteDuplicatesBy[First]@
		Join[
			{
				"Name"->Automatic,
				"Packages"->{},
				"StyleSheets"->{},
				"Palettes"->{},
				"Documentation"->{},
				"Symbols"->{},
				"Guides"->{},
				"Tutorials"->{}
				},
			FilterRules[Options@AppConfigure,
				Except[Directory|Extension]
				]
			];
AppConfigureSubapp[
	appName_:Automatic,
	path_String?(StringLength@DirectoryName@#>0&&FileExistsQ@DirectoryName@#&),
	ops:OptionsPattern[]
	]:=
	With[{app=AppFromFile[appName]},
		With[{
			packages=
				Map[
					{#,
						FileNameSplit@
							FileNameDrop[#,FileNameDepth@AppDirectory[app,"Packages"]]
						}&
					]@
						DeleteCases[Except[_String?(StringLength@#>0&&FileExistsQ@#&)]]@
						Flatten[
							{
								AppPackage[app,StringTrim[#,".nb"|".m"|".wl"]],
								Replace[
									AppPackage[app,
										StringTrim[#,".nb"|".m"]<>".m"
										],
									$Failed:>
										AppPackage[app,
											StringTrim[#,".nb"|".wl"]<>".wl"
											]
									]
								}&/@
								Flatten[{OptionValue["Packages"]},1]
							],
			palettes=
				DeleteCases[Except[_String?(StringLength@#>0&&FileExistsQ@#&)]]@
				AppPath[app,"Palettes",
					StringTrim[#,".nb"]<>".nb"]&/@
					Flatten@{OptionValue["Palettes"]},
			stylesheets=
				DeleteCases[Except[_String?(StringLength@#>0&&FileExistsQ@#&)]]@
				AppPath[app,"StyleSheets",
					StringTrim[#,".nb"]<>".nb"]&/@
					Flatten@{OptionValue["StyleSheets"]},
			docs=
				DeleteCases[Except[_String?(StringLength@#>0&&FileExistsQ@#&)]]@
				Join[
					AppPath[app,"Symbols",
						StringTrim[#,".nb"]<>".nb"]&/@
							Flatten@{OptionValue["Symbols"]},
					AppPath[app,"Symbols",
						StringTrim[#,".nb"]<>".nb"]&/@
							Flatten@{OptionValue["Guides"]},
					AppPath[app,"Symbols",
						StringTrim[#,".nb"]<>".nb"]&/@
							Flatten@{OptionValue["Tutorials"]},
					AppPath[app,"Documentation","English",
						If[StringQ@#,StringTrim[#,".nb"]<>".nb",#]
						]&/@
							Flatten@{OptionValue["Documentation"]}
					]
			},
			AppConfigure[
				FileBaseName@path,
				packages,
				Evaluate@FilterRules[{
					ops,
					"Palettes"->palettes,
					"StyleSheets"->stylesheets,
					"Documentation"->docs,
					Directory->DirectoryName@path,
					Extension->None
					},
					Options@AppConfigure
					]
				]
			]
		];
AppConfigureSubapp[
	app_:Automatic,
	name:_String|{__String},
	ops:OptionsPattern[]
	]:=
	With[{
		appName=
			Replace[OptionValue@"Name",
				Automatic:>
					First@Flatten@{name}
				]
		},
		AppConfigureSubapp[
			app,
			Quiet@
				DeleteDirectory[
					FileNameJoin@{$TemporaryDirectory,appName},
					DeleteContents->True
					];
			FileNameJoin@{$TemporaryDirectory,appName},
			FilterRules[{
				"Packages"->
					Join[
						#,
						OptionValue["Packages"]
						],
				ops,
				"LoadInfo"->{
					"Hidden"->
						DeleteCases[#,Alternatives@@Flatten@{name}]
					}
				},
				Options@AppConfigureSubapp
				]&@Keys@AppPackageDependencies[app,name]
			]
		];


(* ::Subsection:: *)
(*Find*)



(* ::Subsubsection::Closed:: *)
(*AppNames*)



AppNames[pat_:"*"]:=
	FileNames[pat,$AppDirectory];


(* ::Subsubsection::Closed:: *)
(*AppPackages*)



AppPackages[
	app:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	FileNames["*.m"|"*.wl",
		AppDirectory[AppFromFile@app,"Packages"]
		];


(* ::Subsubsection::Closed:: *)
(*AppStyleSheets*)



AppStyleSheets[
	appName:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	With[{app=AppFromFile@appName},
		Join[
			FileNames["*.nb",
				AppDirectory[app,"StyleSheets"]
				],
			FileNames["*.nb",
				AppDirectory[app,
					"StyleSheets",app]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppPalettes*)



AppPalettes[
	appName:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	With[{app=AppFromFile@appName},
		Join[
			FileNames["*.nb",
				AppDirectory[app,"Palettes"]
				],
			FileNames["*.nb",
				AppDirectory[app,
					"Palettes",app]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppSymbolPages*)



AppSymbolPages[
	appName:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	With[{app=AppFromFile@appName},
		FileNames["*.nb",
			AppDirectory[app,"Symbols"]
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppGuides*)



AppGuides[
	appName:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	With[{app=AppFromFile@appName},
		FileNames["*.nb",
			AppDirectory[app,"Guides"]
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppTutorials*)



AppTutorials[
	appName:_String?(MemberQ[FileBaseName/@AppNames[],#]&)|Automatic:Automatic
	]:=
	With[{app=AppFromFile@appName},
		FileNames["*.nb",
			AppDirectory[app,"Tutorials"]
			]
		];


(* ::Subsection:: *)
(*Edit*)



(* ::Subsubsection::Closed:: *)
(*Add Content*)



AppAddContent[name_,file_String?FileExistsQ,path__String,
	o:(OverwriteTarget->True|False):(OverwriteTarget->False)]:=
	With[{copyTo=AppDirectory[name,path,FileNameTake@file]},
		If[Not@FileExistsQ@DirectoryName@copyTo,
			CreateDirectory[DirectoryName@copyTo,
				CreateIntermediateDirectories->True]
			];
		CopyFile[file,copyTo,o]
		];
AppAddContent[name_,file_String?FileExistsQ,
	o:(OverwriteTarget->True|False):(OverwriteTarget->False)]:=
	With[{path=
		Switch[
			{FileBaseName@file,FileExtension@file},
			{"PacletInfo","m"},{},
			{_,"m"},"Packages",
			{_,"nb"},
				Replace[Get@file,{
					nb:Notebook[data_,
						{___,
							StyleDefinitions->_?(
									Not@*FreeQ@FrontEnd`FileName[{"Wolfram"},"Reference"]
									),___}]:>
							If[FreeQ[data,Cell[__,"GuideTitle",___]],
								"Symbols",
								"Guides"
								],
					Notebook[_,
						{___,(_Rule|_RuleDelayed)[AutoGeneratedPackage,Except[False]],___}]->
						"Packages",
					Notebook[
						_?(MemberQ[NotebookTools`FlattenCellGroups@#,
								Cell[StyleData[__],___]]&),
						___]->
						"StyleSheets",
					_->"Packages"
					}],
			_,{}
			]},
		AppAddContent[name,file,path,o]
		];
AppAddContent[appName_,
	nb:(_NotebookObject|Automatic):Automatic,
	o:(OverwriteTarget->True|False):(OverwriteTarget->False)]:=
	Replace[
		NotebookFileName@Replace[nb,Automatic:>EvaluationNotebook[]],{
			fName_String:>AppAddContent[appName,nb,FileBaseName@fName,o],
			_:>$Failed
			}
		];
AppAddContent[appName_,
	nb:(_NotebookObject|Automatic):Automatic,
	fName_String?(StringMatchQ[Except[$PathnameSeparator]..]),
	path:__String|None:None,
	o:(OverwriteTarget->True|False):(OverwriteTarget->False)]:=
	With[{file=
			NotebookSaveRename[
				Replace[nb,Automatic:>EvaluationNotebook[]],
				FileNameJoin@{$TemporaryDirectory,
					fName<>If[FileExtension[fName]==="",".nb",""]
					}
				]},
		With[{new=
			Check[
				If[{path}=!={None},
					AppAddContent[appName,file,path,o],
					AppAddContent[appName,file,o]
					],
				$Failed]},
			If[MatchQ[new,_String?FileExistsQ],
				SystemOpen@new;
				NotebookClose@Replace[nb,Automatic:>EvaluationNotebook[]],
				$Failed
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Add Elements*)



AppAddPackage[name_,file_]:=AppAddContent[name,file,"Packages"];


AppAddStylesheet[name_,file_]:=AppAddContent[name,file,"StyleSheets"];


AppAddPalette[name_,file_]:=AppAddContent[name,file,"Palettes"];


AppAddDocPage[name_,file_]:=AppAddContent[name,file,"Symbols"];


AppAddGuidePage[name_,file_]:=AppAddContent[name,file,"Guides"];


AppAddTutorialPage[name_,file_]:=AppAddContent[name,file,"Tutorials"];


(* ::Subsubsection::Closed:: *)
(*RegenerateBundleInfo*)



Options[AppRegenerateBundleInfo]=
	Options@AppPacletBundle;
AppRegenerateBundleInfo[app_String,ops:OptionsPattern[]]:=
	Export[AppPath[app,"BundleInfo.m"],
		DeleteDuplicatesBy[First]@
			Flatten@{
				ops,
				"RemovePaths"->{
					"Private"
					},
				"RemovePatterns"->{
					"Packages/*.nb",
					"Packages/*/*.nb",
					"Packages/*/*/*.nb",
					".DS_Store"
					}
				}
		];


(* ::Subsubsection::Closed:: *)
(*RegenerateLoadInfo*)



Options[AppRegenerateLoadInfo]=
	{
		"PreLoad"-> None,
		"Hidden" -> {},
		"HiddenContexts"->None
		};
AppRegenerateLoadInfo[app_String,ops:OptionsPattern[]]:=
	Export[AppPath[app,"LoadInfo.m"],
		DeleteDuplicatesBy[First]@
			Flatten@{
				ops,
				Options@AppRegenerateLoadInfo
			}
		];


(* ::Subsection:: *)
(*Docs*)



(* ::Subsubsection::Closed:: *)
(*DocInfo*)



Options[AppRegenerateDocInfo]=
	Options@DocContextTemplate;
AppRegenerateDocInfo[app_String,ops:OptionsPattern[]]:=
	Export[AppPath[app,"Documentation","DocInfo.m"],
		Flatten@{
			ops,
			"Usage"->Automatic,
			"Functions"->Automatic,
			"Details"->Automatic,
			"Examples"->Defer,
			"RelatedLinks"->None,
			"GuideOptions"->{},
			"TutorialOptions"->{}
			}
		];


(* ::Subsubsection::Closed:: *)
(*AppIndexDocs*)



AppIndexDocs[app_,lang:_String:"English"]:=
	IndexDocumentation[
		AppPath[app,"Documentation",lang]
		];


(* ::Subsubsection::Closed:: *)
(*AppSymbolNotebook*)



Options[AppSymbolNotebook]=
	Prepend["DocInfo"->Automatic]@
		Options@SymbolPageTemplate;
AppSymbolNotebook[app_,ops:OptionsPattern[]]:=
	Replace[OptionValue@"DocInfo",{
		Automatic:>
			AppSymbolNotebook[app,
				"DocInfo"->
					AppPath[app,
						"Documentation",
						"DocInfo.m"],
				ops],
		f_String?FileExistsQ:>
			AppSymbolNotebook[app,
				"DocInfo"->None,
				ops,
				Sequence@@
					FilterRules[
						DeleteCases[Import[f],
								Alternatives@@Options@AppSymbolNotebook],
						Options@AppSymbolNotebook
						]
					],
		e_:>
			With[{fs=AppPackageFunctions[app]},
				Notebook[
					Flatten@{
						Cell[app<>" Documentation Template","Title"],
						Cell[BoxData@RowBox@{"<<",app<>"`"},
							"Input"],
						Cell[BoxData@RowBox@{"$DocActive","=","\""<>app<>"\"",";"},
							"Input"],
						Cell["","BlockSeparator"],
						First/@#
						},
					Sequence@@Rest@First@#
					]&@
					KeyValueMap[
						SymbolPageTemplate[#2,
							Sequence@@FilterRules[{ops},
								Options@SymbolPageTemplate],
							"Usage"->Automatic,
							"Details"->Automatic,
							"Functions"->#2,
							"Examples"->Defer,
							"RelatedGuides"->{
								app<>" Overview"->app,
								#<>" Package"->#<>"Package"
								},
							"RelatedTutorials"->{
								app<>" Tutorial"
								},
							"RelatedLinks"->None
							]&,
						fs
						]
				]
		}];


(* ::Subsubsection::Closed:: *)
(*AppPackageSymbolNotebook*)



Options[AppPackageSymbolNotebook]=
	Prepend[Options@SymbolPageTemplate,
		"DocInfo"->Automatic
		];
AppPackageSymbolNotebook[app_,pkg_,ops:OptionsPattern[]]:=
	Replace[OptionValue@"DocInfo",{
		Automatic:>
			AppPackageSymbolNotebook[app,pkg,
				"DocInfo"->
					AppPath[app,
						"Documentation",
						"DocInfo.m"],
				ops],
		f_String?FileExistsQ:>
			AppPackageSymbolNotebook[app,pkg,
				"DocInfo"->None,
				ops,
				Sequence@@
					FilterRules[
						DeleteCases[Import[f],
								Alternatives@@Options@AppPackageSymbolNotebook],
						Options@AppPackageSymbolNotebook
						]
					],
		e_:>
			With[{fs=AppPackageFunctions[app,pkg]},
				Replace[
					SymbolPageTemplate[fs,
						Sequence@@FilterRules[{ops},
							Options@SymbolPageTemplate],
						"Usage"->Automatic,
						"Details"->Automatic,
						"Functions"->fs,
						"Examples"->Defer,
						"RelatedGuides"->{
							app<>" Overview"->app,
							pkg<>" Package"->pkg<>"Package"
							},
						"RelatedTutorials"->{
							app<>" Tutorial"
							},
						"RelatedLinks"->None
						],
					Notebook[{a__},o___]:>
						Notebook[{
							Cell[app<>" Documentation Template","Title"],
							Cell[BoxData@RowBox@{"<<",app<>"`"},
								"Input"],
							Cell[BoxData@RowBox@{"$DocActive","=","\""<>app<>"\"",";"},
								"Input"],
							Cell["","BlockSeparator"],
							a
							},
							o
							]
					]
				]
		}];


(* ::Subsubsection::Closed:: *)
(*AppGuideNotebook*)



Options[AppGuideNotebook]=
	Prepend["DocInfo"->Automatic]@
		Options@GuideTemplate;
AppGuideNotebook[app_,ops:OptionsPattern[]]:=
	Replace[OptionValue@"DocInfo",{
		Automatic:>
			AppGuideNotebook[app,
				"DocInfo"->
					AppPath[app,
						"Documentation",
						"DocInfo.m"],
				ops],
		f_String?FileExistsQ:>
			AppGuideNotebook[app,
				"DocInfo"->None,
				ops,
				Sequence@@
					FilterRules[
						DeleteCases[Lookup[Import[f],"GuideOptions",{}],
								Alternatives@@Options@AppGuideNotebook],
						Options@AppGuideNotebook
						]
					],
		e_:>
			With[{fs=AppPackageFunctions[app]},
				GuideTemplate[app,
					Sequence@@FilterRules[{ops},
						Options@GuideTemplate],
					"Title"->app<>" Application Overview",
					"Link"->app,
					"Abstract"->
						TemplateApply[
							"The `` app has `` subpackages and `` top-level functions",{
								app,
								Length@fs,
								Length/@fs//Total
								}],
					"Functions"->
						Flatten[List@@fs],
					"Subsections"->
						KeyValueMap[(#->(#<>"Package"))->#2&]@
							Map[Take[#,UpTo[4]]&,fs],
					"RelatedGuides"->
						Map[#->#<>"Package"&,
							Keys@fs],
					"RelatedTutorials"->
						Flatten@{
							app<>" Tutorial"
							},
					"RelatedLinks"->
						None
					]//
					Replace[
						Notebook[{a__},o___]:>
							Notebook[{
								Cell[app<>" Documentation","Title"],
								Cell[BoxData@RowBox@{"<<",app<>"`"},
									"Input"],
								Cell[BoxData@RowBox@{"$DocActive","=","\""<>app<>"\"",";"},
									"Input"],
								Cell["","BlockSeparator"],
								a
								},
								o
								]
							
						]
				]
	}];


(* ::Subsubsection::Closed:: *)
(*AppPackageGuideNotebook*)



Options[AppPackageGuideNotebook]=
	Prepend["DocInfo"->Automatic]@
		Options@GuideTemplate;
AppPackageGuideNotebook[app_,pkg_,ops:OptionsPattern[]]:=
	Replace[OptionValue@"DocInfo",{
		Automatic:>
			AppPackageGuideNotebook[app,pkg,
				"DocInfo"->
					AppPath[app,
						"Documentation",
						"DocInfo.m"],
				ops],
		f_String?FileExistsQ:>
			AppPackageGuideNotebook[app,pkg,
				"DocInfo"->None,
				ops,
				Sequence@@
					FilterRules[
						DeleteCases[Lookup[Import[f],"GuideOptions",{}],
								Alternatives@@Options@AppPackageGuideNotebook],
						Options@AppPackageGuideNotebook
						]
					],
		e_:>
			With[{fs=AppPackageFunctions[app,pkg]},
				GuideTemplate[pkg,
					Sequence@@FilterRules[{ops},
						Options@GuideTemplate],
					"Title"->pkg<>" Package Overview",
					"Link"->pkg<>"Package",
					"Abstract"->
						TemplateApply[
							"The `` package has `` top-level functions",{
								pkg,
								Length@fs
								}],
					"Functions"->
						fs,
					"Subsections"->
						Normal@GroupBy[Sort[fs],StringTake[#,1]&],
					"RelatedGuides"->
						{
							(app<>" Application Overview")->app
							},
					"RelatedTutorials"->
						Flatten@{
							app<>" Tutorial"
							},
					"RelatedLinks"->
						None
					]//
					Replace[
						Notebook[{a__},o___]:>
							Notebook[{
								Cell[app<>" "<>pkg,"Title"],
								Cell[BoxData@RowBox@{"<<",app<>"`"},
									"Input"],
								Cell[BoxData@RowBox@{"$DocActive","=","\""<>app<>"\"",";"},
									"Input"],
								Cell["","BlockSeparator"],
								a
								},
								o
								]
							
						]
				]
		}];


(* ::Subsubsection::Closed:: *)
(*AppTutorialNotebook*)



Options[AppTutorialNotebook]=
	Prepend["DocInfo"->Automatic]@
		Options@TutorialTemplate;
AppTutorialNotebook[app_,ops:OptionsPattern[]]:=
	Replace[OptionValue@"DocInfo",{
		Automatic:>
			AppTutorialNotebook[app,
				"DocInfo"->
					AppPath[app,
						"Documentation",
						"DocInfo.m"],
				ops],
		f_String?FileExistsQ:>
			AppTutorialNotebook[app,
				"DocInfo"->None,
				ops,
				Sequence@@
					FilterRules[
						DeleteCases[Lookup[Import[f],"TutorialOptions",{}],
								Alternatives@@Options@AppTutorialNotebook],
						Options@AppTutorialNotebook
						]
					],
		e_:>
			With[{fs=AppPackageFunctions[app]},
				TutorialTemplate[app,
					Sequence@@FilterRules[{ops},
						Options@TutorialTemplate],
					"Title"->(app<>" Tutorial"),
					"Description"->
						TemplateApply["Tutorial for the `` application",app],
					"Content"->
						KeyValueMap[
							#->{
								TemplateApply["The `` package has `` functions.",
									{#,Length@#2}],
								"These are:",
								Thread@{#2}
								}&,
							fs],
					"Functions"->
						Flatten@(Values@fs),
					"RelatedGuides"->
						Prepend[
							Map[#->#<>"PackageGuide"&,
								Keys@fs],
							(app<>" Overview")->app
							],
					"RelatedTutorials"->
						None,
					"RelatedLinks"->
						None
					]//
					Replace[
						Notebook[{a__},o___]:>
							Notebook[{
								Cell[app<>" Documentation Template","Title"],
								Cell[BoxData@RowBox@{"<<",app<>"`"},
									"Input"],
								Cell[BoxData@RowBox@{"$DocActive","=","\""<>app<>"\"",";"},
									"Input"],
								Cell["","BlockSeparator"],
								a
								},
								o
								]
							
						]
				]
		}];


(* ::Subsubsection::Closed:: *)
(*AppDocumentationTemplate*)



AppDocumentationTemplate[app_]:=
	With[{docs=
		AppSymbolNotebook[app]},
		Notebook[
			Flatten@
				{
					Cell[app<>" Documentation Template","Title"],
					Cell[BoxData@RowBox@{"<<",app<>"`"},"Input"],
					Cell[BoxData@ToBoxes@Unevaluated[$DocActive=app;],
						"Input"
						],
					Cell["","BlockSeparator"],
					Cell[app<>" Ref Pages","Chapter"],
					First@docs,
					Cell[app<>" Guide Pages","Chapter"],
					First@AppGuideNotebook[app],
					Map[
						First@AppPackageGuideNotebook[app,#]&,
						FileBaseName/@AppPackages[app]
						],
					Cell[app<>" Tutorial Page","Chapter"],
					First@AppTutorialNotebook[app]
					},
			Sequence@@Rest@docs
			]
	]


(* ::Subsubsection::Closed:: *)
(*AppSaveSymbolPages*)



Options[AppSaveSymbolPages]=
	Join[
		Options[AppPackageSymbolNotebook],
		Options[SaveSymbolPages]
		];
AppSaveSymbolPages[
	appName_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		With[{pkgs=FileBaseName/@AppPackages[app]},
			Map[
				With[{nb=
					If[TrueQ@OptionValue[Monitor],
						With[{pkg=#},
							Function[
								Null,
								Monitor[#,
									Internal`LoadingPanel[
										"Creating symbol template notebook for ``"~TemplateApply~pkg
										]
									],
								HoldFirst
								]
							],
						Identity
						]@
					CreateDocument[
						AppPackageSymbolNotebook[app,#,
							FilterRules[{ops},
								Options[AppPackageSymbolNotebook]
								]
							],
						Visible->False
						]
					},
					Function[NotebookClose[nb]; #]@
						SaveSymbolPages[
							nb,
							Replace[dir,Automatic:>AppDirectory[app,"Symbols"]],
							extension,
							FilterRules[{ops},
								Options[SaveSymbolPages]
								]
							]
					]&,
				pkgs
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppPackageSaveSymbolPages*)



Options[AppPackageSaveSymbolPages]=
	Join[
		Options[AppPackageSymbolNotebook],
		Options[SaveSymbolPages]
		];
AppPackageSaveSymbolPages[
	appName_,
	pkg_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		With[{nb=
			If[TrueQ@OptionValue[Monitor],
				Function[
					Null,
					Monitor[#,
						Internal`LoadingPanel[
							"Creating symbol template notebook"
							]
						],
					HoldFirst
					],
				Identity
				]@
			CreateDocument[
				AppPackageSymbolNotebook[app,pkg,
					FilterRules[{ops},
						Options[AppPackageSymbolNotebook]
						]
					],
				Visible->False
				]
			},
			Function[NotebookClose[nb]; #]@
				SaveSymbolPages[
					nb,
					Replace[dir,Automatic:>AppDirectory[app,"Symbols"]],
					extension,
					FilterRules[{ops},
						Options[SaveSymbolPages]
						]
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppSaveGuide*)



Options[AppSaveGuide]=
	Join[
		Options[AppGuideNotebook],
		Options[SaveGuide]
		];
AppSaveGuide[
	appName_, 
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops : OptionsPattern[]] :=
	With[{app = AppFromFile[appName]},
		With[{nb =
			If[TrueQ@OptionValue[Monitor],
				Function[
					Null,
					Monitor[#,
						Internal`LoadingPanel[
							"Creating guide template notebook"
							]
						],
					HoldFirst
					],
				Identity
				]@
			CreateDocument[
				AppGuideNotebook[app, 
					FilterRules[{ops},
						Options[AppGuideNotebook]
						]
					], 
				Visible -> False]
			},
			Function[NotebookClose[nb]; #]@
				SaveGuide[
					nb,
					Replace[dir,Automatic:>AppDirectory[app, "Guides"]],
					extension,
					FilterRules[{ops},
						Options[SaveGuide]
						]
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppPackageSaveGuide*)



Options[AppPackageSaveGuide]=
	Join[
		Options[AppPackageGuideNotebook],
		Options[SaveGuide]
		];
AppPackageSaveGuide[
	appName_,
	pkg_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops:OptionsPattern[]
	]:=
	With[{
		app=AppFromFile[appName]
		},
		With[{nb=
			If[TrueQ@OptionValue[Monitor],
				Function[
					Null,
					Monitor[#,
						Internal`LoadingPanel[
							"Creating guide template notebook"
							]
						],
					HoldFirst
					],
				Identity
				]@
			CreateDocument[
				AppPackageGuideNotebook[app,pkg,
					FilterRules[{ops},
						Options[AppPackageGuideNotebook]
						]
					],
				Visible->False
				]
			},
			Function[NotebookClose[nb];#]@
				SaveGuide[
					nb,
					Replace[dir,Automatic:>AppDirectory[app,"Guides"]],
					extension,
					FilterRules[{ops},
						Options[SaveGuide]
						]
					]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppGenerateDocumentation*)



Options[AppGenerateDocumentation]=
	Join[
		Options[AppSaveSymbolPages],
		Options[AppSaveGuide]
		];
AppGenerateDocumentation[
	app_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops:OptionsPattern[]
	]:=
	Module[{docs=dir},
		If[extension&&dir=!=Automatic,
			CreateDirectory[
				FileNameJoin@{dir,"Documentation","English"},
				CreateIntermediateDirectories->True
				];
			docs=FileNameJoin@{dir,"Documentation","English"}
			];
		AppSaveSymbolPages[app,docs,extension,ops];
		AppSaveGuide[app,docs,extension,ops];
		docs
		]


(* ::Subsubsection::Closed:: *)
(*AppPackageGenerateDocumentation*)



Options[AppPackageGenerateDocumentation]=
	Join[
		Options[AppPackageSaveSymbolPages],
		Options[AppPackageSaveGuide]
		];
AppPackageGenerateDocumentation[
	app_,
	pkg_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	extension:True|False:False,
	ops:OptionsPattern[]
	]:=
	Module[{docs=dir},
		If[extension&&dir=!=Automatic,
			CreateDirectory[
				FileNameJoin@{dir,"Documentation","English"},
				CreateIntermediateDirectories->True
				];
			docs=FileNameJoin@{dir,"Documentation","English"}
			];
		AppPackageSaveSymbolPages[app,pkg,docs,extension,ops];
		AppPackageSaveGuide[app,pkg,docs,extension,ops];
		docs
		]


(* ::Subsubsection::Closed:: *)
(*AppGenerateHTMLDocumentation*)



AppGenerateHTMLDocumentation[
	app_,
	dir:(_String|_File)?DirectoryQ|Automatic:Automatic,
	which:"ReferencePages"|"Guides"|"Tutorials"|All:All,
	pattern:_String:"*",
	ops:OptionsPattern[]
	]:=
	With[{
		fils=
			Select[FileExistsQ@#&&StringMatchQ[FileBaseName[#],pattern]&]@
				FileNames[
					"*.nb",
					If[which===All,
						Replace[dir,{
							Automatic:>
								AppDirectory[app,"Documentation","English"],
							d_?DirectoryQ:>
								If[!FileNameSplit[d][[-2;;]]=={"Documentation","English"},
									FileNameJoin@{d,"Documentation","English"},
									d
									]
							}],
						Replace[dir,{
							Automatic:>
								AppDirectory[app,which],
							d_?DirectoryQ:>
								If[FileNameTake[d]=!=which,
									FileNameJoin@{
										If[!FileNameSplit[d][[-2;;]]=={"Documentation","English"},
											FileNameJoin@{d,"Documentation","English"},
											d
											],
										which
										},
									d
									]
								}]
						],
					\[Infinity]
					]
		},
		GenerateHTMLDocumentation[
			Automatic,
			fils,
			ops
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppPackageGenerateHTMLDocumentation*)



AppPackageGenerateHTMLDocumentation[
	app_,
	pkg_,
	which:"ReferencePages"|"Guides"|"Tutorials"|All:All,
	pattern:_String:"*",
	ops:OptionsPattern[]]:=
	With[{
		fils=
			Select[FileExistsQ@#&&StringMatchQ[FileBaseName[#],pattern]&]@
				Join[
					AppPath[app,"Symbols",#<>".nb"]&/@AppPackageFunctions[app,pkg],
					AppPath[app,#,pkg<>".nb"]&/@{"Guides","Tutorials"}
					]
		},
		GenerateHTMLDocumentation[
			Automatic,
			fils,
			ops
			]
		];


(* ::Subsection:: *)
(*Git*)



(* ::Subsubsection::Closed:: *)
(*GitInit*)



AppGitInit[appName_:Automatic]:=
	With[{app=AppFromFile[appName]},
		With[{d=AppDirectory[app]},
			GitInit[d];
			AppRegenerateGitExclude[app];
			AppRegenerateGitIgnore[app];
			d
			]
		];


(* ::Subsubsection::Closed:: *)
(*RegenerateGitIgnore*)



AppRegenerateGitIgnore[appName_:Automatic,
	patterns:_String|{__String}:{
		"Packages/*.nb","Packages/*/*.nb","Packages/*/*/*/*.nb"}]:=
	With[{
		app=
			AppFromFile[appName]
			},
		If[GitRepoQ@AppDirectory[app],
			With[{f=OpenWrite[AppPath[app,".gitignore"]]},
				WriteLine[f,
					StringJoin@Riffle[Flatten@{patterns},"\n"]
					];
				Close@f
				],
			$Failed
			]
		];


(* ::Subsubsection::Closed:: *)
(*RegenerateGitExclude*)



AppRegenerateGitExclude[appName_:Automatic,
	patterns:_String|{__String}:{"Private/*"}]:=
	With[{
		app=
			AppFromFile[appName]
			},
		If[GitRepoQ@AppDirectory[app],
			If[Not@DirectoryQ@AppDirectory[app,".git","info"],
				CreateDirectory[AppDirectory[app,".git","info"]]
				];
			With[{f=OpenWrite[AppPath[app,".git","info","exclude"]]},
				WriteLine[f,
					StringJoin@Riffle[Flatten@{patterns},"\n"]
					];
				Close@f
				],
			$Failed
			]
		];


(* ::Subsubsection::Closed:: *)
(*RegenerateReadme*)



appREADMETemplate:=
	StringReplace[
		Import[
			PackageAppPath["Templates","README.md"],
			"Text"
			],{
		"`"->"`tick`",
		"$"~~l:LetterCharacter..~~"$":>"`"<>l<>"`"
		}]


Options[AppRegenerateReadme]={
	"Header"->"",
	"Footer"->""
	};
AppRegenerateReadme[appName:_String|Automatic:Automatic]:=
	With[{app=AppFromFile[appName]},
		GitHubCreateReadme[AppDirectory[app],
			TemplateApply[appREADMETemplate,<|
				"tick"->"`",
				"Name"->
					app,
				"FunctionCount"->
					(
						Needs[app<>"`"];
						Length@Names[app<>"`*"]
						),
				"PackageCount"->
					Length@AppPackages[app],
				"SymbolPages"->
					Replace[Length@AppSymbolPages[app],{
						0->
							"no ref pages",
						1->
							"1 ref page",
						n_:>
							ToString[n]<>" ref pages"
						}],
				"GuidePages"->
					Replace[Length@AppGuides[app],{
						0->
							"no guide pages",
						1->
							"1 guide page",
						n_:>
							ToString[n]<>" guide pages"
						}],
				"TutorialPages"->
					Replace[Length@AppTutorials[app],{
						0->
							"no tutorial pages",
						1->
							"1 tutorial page",
						n_:>
							ToString[n]<>" tutorial pages"
						}],
				"Stylesheets"->
					Replace[Length@AppStyleSheets[app],{
						0->
							"no stylesheets",
						1->
							"1 stylesheet",
						n_:>
							ToString[n]<>" stylesheet"
						}],
				"Palettes"->
					Replace[Length@AppPalettes[app],{
						0->
							"no palettes",
						1->
							"1 palette",
						n_:>
							ToString[n]<>" palettes"
						}],
				"Installer":>
					AppPacletInstallerURL@app,
				"Uninstaller":>
					AppPacletUninstallerURL@app
				|>]
			]
		]


(* ::Subsubsection::Closed:: *)
(*GitClone*)



AppGitClone[base_String]:=
	With[{
		url=
			If[StringMatchQ@MatchQ[base,"http*"],
				base,
				GitHubRepo[base]
				],
		app=
			AppFromFile[base]
		},
		GitClone[url,
			AppDirectory[app]
			]
		]


(* ::Subsubsection::Closed:: *)
(*GitCommit*)



AppGitCommit[
	appName:_String|Automatic:Automatic,
	message:_String|Automatic:Automatic,
	add:True|False:True
	]:=
	Replace[AppFromFile[appName],
		app_String:>
			With[{d=AppDirectory[app]},
				If[add,GitAdd[d,"-A"]];
				GitCommit[d,
					Message->
						Replace[message,
							Automatic:>
								TemplateApply[
									"Committed `` application @ ``",
									{
										app,
										StringReplace[
											DateString["ISODateTime"],
											"T"->"_"
											]}
									]
							]
					]
				]
		];


(* ::Subsubsection::Closed:: *)
(*GitHubRepo*)



$AppGitHubPrefix=
	"mathematica-";


AppGitHubRepo[appName_,password_:Automatic]:=
	Replace[AppFromFile[appName],
		s_String:>
			formatGitHubPath[$AppGitHubPrefix<>s,"Password"->password]
		];


(* ::Subsubsection::Closed:: *)
(*GitHubConfigure*)



AppGitHubConfigure[appName_:Automatic]:=
	With[{app=AppFromFile[appName]},
		If[GitRepoQ@AppDirectory[app],
			Replace[AppGitHubRepo[appName],{
				r:Except[$Failed]:>(
					If[Not@Between[URLRead[r,"StatusCode"],{200,299}],
						GitHubImport["Create",$AppGitHubPrefix<>app]
						];
					Quiet@
						Check[
							GitAddRemote[AppDirectory[app],
								r
								],
							GitRemoveRemote[AppDirectory[app],
								r
								];
							GitAddRemote[AppDirectory[app],
								r
								]
							];
						r
					)
				}]
			]
		];


(* ::Subsubsection::Closed:: *)
(*GitHubPush*)



AppGitHubPush[appName_:Automatic]:=
	With[{app=AppFromFile[appName]},
		If[GitRepoQ@AppDirectory[app],
			Block[{$GitHubEncodePassword=True},
				GitPush[AppDirectory[app],
					AppGitHubRepo[appName,Automatic]
					]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*GitHubRemove*)



AppGitHubDelete[appName_:Automatic]:=
	With[{app=AppFromFile[appName]},
		If[GitRepoQ@AppDirectory[app],
			Replace[AppGitHubRepo[appName],{
				r:Except[$Failed]:>(
					If[Between[URLRead[r,"StatusCode"],{200,299}],
						GitHubImport["Delete",$AppGitHubPrefix<>app]
						];
					)
				}]
			]
		];


(* ::Subsection:: *)
(*Loading*)



(* ::Subsubsection::Closed:: *)
(*AppGet*)



AppGet[appName_,pkgName_String]:=
	With[{
		app=AppFromFile[appName],
		cont=$Context
		},
		If[DirectoryQ@AppPath[app,"Packages",pkgName],
			BeginPackage[app<>"`"];
			Begin["`"<>StringTrim[StringReplace[pkgName,$PathnameSeparator->"`"],"`"]<>"`"];
			FrontEnd`Private`GetUpdatedSymbolContexts[];
			EndPackage[],
			With[{
				pkg=
					SelectFirst[
						SortBy[FileNameDepth]@
							FileNames[
								StringTrim[pkgName,".m"]<>".m",
								AppPath[app,"Packages"],
								Infinity
								],
						FileExistsQ
						]
				},
				If[FileExistsQ@pkg,
					With[{
						pkCont=
							StringReplace[
								app<>"`"<>
									StringReplace[
										FileNameDrop[DirectoryName@pkg,
											FileNameDepth@AppDirectory[app,"Packages"]],
										$PathnameSeparator->"`"
										]<>"`",
								"``"->"`"
								]
						},
						BeginPackage[pkCont]
						];
					$ContextPath=
						DeleteDuplicates@
							Join[`Package`$PackageContexts,$ContextPath];
					CheckAbort[
						Get@pkg;
						EndPackage[],
						EndPackage[];
						Catch[
							Catch[
								Do[
									If[i<100,
										If[$Context===cont,Throw[$Context,"success"],End[]],
										Throw[$Failed,"fail"]
										],
									{i,1000}
									],
								"fail",
								Begin[cont]&
								],
							"success"
							];
						]
					]
				]
			];
		Catch[
			Catch[
				Do[
					If[i<100,
						If[$Context===cont,Throw[$Context,"success"],End[]],
						Throw[$Failed,"fail"]
						],
					{i,1000}
					],
				"fail",
				Begin[cont]&
				],
			"success"
			];
		];
AppGet[appName_,pkgName:{__String}]:=
	AppGet[appName,FileNameJoin@pkgName];
AppGet[appName_,Optional[Automatic,Automatic]]:=
	AppGet[appName,FileBaseName@NotebookFileName[]];
AppGet[Optional[Automatic,Automatic]]:=
	With[{app=FileNameTake[NotebookFileName[],{FileNameDepth@$AppDirectory+1}]},
		AppGet[app,Automatic]
		];


(* ::Subsubsection::Closed:: *)
(*AppNeeds*)



If[Not@AssociationQ@$AppLoadedPackages,
	$AppLoadedPackages=<||>
	];
AppNeeds[appName_,pkgName_String]:=
	If[!Lookup[$AppLoadedPackages,Key@{appName,pkgName},False],
		$AppLoadedPackages[{appName,pkgName}]=True;
		AppGet[appName,pkgName];
		];
AppNeeds[appName_,Optional[Automatic,Automatic]]:=
	AppNeeds[appName,FileBaseName@NotebookFileName[]];
AppNeeds[Optional[Automatic,Automatic]]:=
	With[{app=FileNameTake[NotebookFileName[],{FileNameDepth@$AppDirectory+1}]},
		AppNeeds[app,Automatic]
		];


(* ::Subsubsection::Closed:: *)
(*AppFromFile*)



AppFromFile[f_String]:=
	Which[
		StringMatchQ[ExpandFileName@f,$AppDirectory~~__],
			FileNameTake[
				FileNameDrop[f,FileNameDepth@$AppDirectory],
				1
				],
		StringMatchQ[f,"http*"~~"/"~~WordCharacter..],
			URLParse[f]["Path"]//Last,
		MemberQ[FileNameTake/@AppNames[],f],
			f,
		True,
			(
				$Failed
				)
		];
AppFromFile[nb_NotebookObject]:=
	Replace[Quiet@NotebookFileName[nb],
		s_String:>
			AppFromFile[s]
		];
AppFromFile[Optional[Automatic,Automatic]]:=
	AppFromFile@InputNotebook[];


(* ::Subsubsection::Closed:: *)
(*AppPackageOpen*)



AppPackageOpen[app_:Automatic,pkg_]:=
	Replace[AppPackage[app,pkg<>".m"],{
		f_String?FileExistsQ:>
			SystemOpen@f,
		_->$Failed
		}];
AppPackageOpen[Optional[Automatic,Automatic]]:=
	Replace[Quiet@NotebookFileName[],
		f_String:>
			AppPackageOpen[Automatic,
				FileBaseName@f
				]
		]


(* ::Subsubsection::Closed:: *)
(*AppPackageFunctions*)



AppPackageFunctions[app_:Automatic,pkgFile_String?FileExistsQ]:=
	With[{
		f=OpenRead[pkgFile],
		cont=
			Replace[
				Replace[app,{
					Automatic:>AppFromFile[pkgFile],
					_->None
					}],
				s_String:>
					StringTrim[s,"`"]<>"`"
				]
		},
		Block[{pkgFuncCheckedCache=<||>},
			Cases[
				Reap[
					Do[Replace[
						ReadList[f,Hold[Expression],1],{
							{}->Return[EndOfFile],
							{Hold[_Begin|_BeginPackage|
								CompoundExpression[_Begin|_BeginPackage,___]]}:>
								Return[Begin],
							{e_}:>Sow[e]
							}],
						Infinity];
					Close@f;
					][[2,1]],
				s_Symbol?(
					Function[sym,
						Not@KeyMemberQ[pkgFuncCheckedCache,Hold[sym]]&&
						With[{v=
								If[cont===None,
									!StringMatchQ[Quiet[Context[sym]],
										"System`"|("*`*Private*")|$Context
										],
									With[{pcont=Quiet[Context[sym]]},
										StringMatchQ[pcont,cont<>"*"]&&
											!StringContainsQ[pcont,"Private`"]	
										]
									]
							},
							pkgFuncCheckedCache[Hold[sym]]=v
							],
						HoldFirst]
						):>
						ToString[Unevaluated[s]],
				Infinity
				]
			]
		];
AppPackageFunctions[
	app:
		_String?(MemberQ[FileBaseName/@AppNames[],#]&)|
		Automatic:Automatic,
	path_String]/;
		MemberQ[FileBaseName/@AppPackages[app],path]:=
	AppPackageFunctions[app,
		AppPackage[app,StringTrim[path,".m"]<>".m"]
		];
AppPackageFunctions[app_:Automatic,paths:{__String}]:=
	AssociationMap[
		AppPackageFunctions[app,#]&,
		paths
		];
AppPackageFunctions[
	app:
		_String?(MemberQ[FileBaseName/@AppNames[],#]&)|
		Automatic:Automatic]:=
	AppPackageFunctions[app,
		FileBaseName/@FileNames["*.m",
			AppDirectory[AppFromFile@app,"Packages"]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppFunctionPackage*)



AppFunctionPackage[app_:Automatic,f:{__String}]:=
	With[{funcs=AppPackageFunctions[app]},
		AssociationMap[
			Replace[Keys@Select[funcs,MemberQ[#]],{
				{}->None,
				{p_}:>p
				}]&,
			f
			]
		];
AppFunctionPackage[app_:Automatic,f_String]:=
	First@AppFunctionPackage[{f}];
AppFunctionPackage[app_:Automatic,f:{(_Symbol|_String)..}]:=
	AppFunctionPackage[
		Replace[app,
			Automatic:>
				FirstCase[f,s_Symbol:>StringTrim[Context[s],"`"]]
			],
		Replace[f,s_Symbol:>SymbolName[s],1]
		];
AppFunctionPackage[app_:Automatic,f_Symbol]:=
	AppFunctionPackage[
		Replace[app,
			Automatic:>StringTrim[Context[f],"`"]
			],
		SymbolName[f]
		];


(* ::Subsubsection::Closed:: *)
(*AppFunctionDependencies*)



functionCallChain[conts_,function_]:=
	With[{cpats=Alternatives@@Map[#<>"*"&,conts]},
		Cases[
			Hold[s_Symbol]?(
				Function[Null,
					Quiet[StringMatchQ[Context@@#,cpats],Context::ssle]&&
						Length[OwnValues@@#]==0,
					HoldFirst
					]):>s
			]@
		FixedPoint[
			Union[#,
				Cases[
					Flatten@
						(Through[
							Map[Apply,{DownValues,UpValues,OwnValues,SubValues}]@#
							]&/@#),
					s_Symbol?(
						Function[Null,
							Quiet[
								StringMatchQ[Context[#],cpats]&&
								Length[
									Flatten@
										Through[
											Map[Apply,
												{DownValues,UpValues,OwnValues,SubValues}
												]@Hold[#]
											]
									]>0
								],
							HoldFirst
							]
						):>Hold[s],
					\[Infinity],
					Heads->True
					]
				]&,
			Thread[Hold[Evaluate@Flatten@{function}]],
			25
			]
		];
AppFunctionDependencies[app_:Automatic,function:_Symbol|{__Symbol}]:=
	With[{conts=
		{#,#<>"Private`"}&@Quiet@Context@Evaluate@First@Flatten@{function}
		},
		Replace[
			AppFunctionPackage[app,
				Select[functionCallChain[conts,function],
					With[{c=First@conts},
						Quiet@Context[#]==c
						]&]
				],{
			a_Association:>
				GroupBy[First->Last]@
					KeyValueMap[Thread[#2->#]&,a],
			_:>
				<||>
			}]
		];


(* ::Subsubsection::Closed:: *)
(*AppPackageDependencies*)



AppPackageDependencies[app_:Automatic,pkg:_String|{__String}]:=
	(
		AppNeeds[app,#]&/@Flatten@{pkg};
		AppFunctionDependencies[
			app,
			ToExpression[
				With[{a=AppFromFile[app]},
					StringJoin@{a,"`",#}&/@
						Flatten@Apply[List,AppPackageFunctions[app,pkg]]
					],
				StandardForm,
				GeneralUtilities`HoldFunction[
					If[Length@DownValues[#]==0,
						Nothing,
						#
						]
					]
				]
			]
		);
AppPackageDependencies[app_:Automatic,f_Symbol]:=
	AppPackageDependencies[
		Replace[app,
			Automatic:>
				StringTrim[Context[f],"`"]
			],
		AppFunctionPackage[app,f]
		];


(* ::Subsubsection::Closed:: *)
(*AppGenerateTestingNotebook*)



AppGenerateTestingNotebook[app_]:=
	Notebook[{
		Cell[app<>" Testing","CodeChapter"],
		Cell[BoxData@RowBox@{"<<",app<>"`"},"CodeInput"],
		MapIndexed[
			Cell[
				CellGroupData[Flatten@{
					Cell[First@#,"Section"],
					Cell[BoxData@RowBox@{
							"AppGet","[","\""<>app<>"\"",",",
							"\""<>First@#<>"\"","]"
							},
						"CodeInput"
						]
					},
					If[First@#2==1,Open,Closed]
					]
				]&,
			Normal@AppPackageFunctions[app]
			]
		},
		StyleDefinitions->
			FrontEnd`FileName[Evaluate@{`Package`$PackageName},"CodeNotebook.nb"]
		];
AppGenerateTestingNotebook[Optional[Automatic,Automatic]]:=
	AppGenerateTestingNotebook[AppFromFile[]]


(* ::Subsection:: *)
(*ZIP dist*)



$AppCloudExtension="applications";
$AppBackupDirectoryName="_appcache"


(* ::Subsubsection::Closed:: *)
(*AppInstall*)



AppInstall[
		name_String?(StringMatchQ[Except[WhitespaceCharacter|"/"|"_"|"."]..]),
		loadFE_:Automatic]:=
	With[{},
		If[!DirectoryQ@AppDirectory@name,AppDownload@name];
		If[Replace[loadFE,
			Automatic:>(FileNames["*",{
				AppDirectory[name,"Palettes"],
				AppDirectory[name,"StyleSheets"]}
				]=!={})
			],
			DialogInput[Column@{
"Front end must quit to complete installation. 
Would you like to do that now?",
				Row@{
					DefaultButton["Quit Now",
						FrontEndTokenExecute@"FrontEndQuit"],
					Button["Wait",
						DialogReturn[]]
					}
				},
				WindowTitle->"Quit Mathematica"
				];
			];
		Get@FileNameJoin@{$UserBaseDirectory,"Applications",name,"Kernel","init.m"};
	];


AppInstall[try___]:=
	With[{result=AppDownload[try]},
		Replace[result,{
			_AppDownload:>$Failed,
			f_:>If[DirectoryQ@AppDirectory@FileNameTake@f,
					AppInstall@f
					];
			}]
		]


(* ::Subsubsection::Closed:: *)
(*AppDownload*)



Options[AppDownload]:=
	Options@DownloadFile;
AppDownload[
		file:File[_String?DirectoryQ]|_String?DirectoryQ,
		name:(
				_String?(StringMatchQ[Except[WhitespaceCharacter|"/"|"_"|"."]..])|
				Automatic
				):Automatic,
		root:File[_String?DirectoryQ]|_String?DirectoryQ|Automatic:Automatic,
		ops:OptionsPattern[]
		]:=
	With[{appName=StringReplace[
		FileBaseName@file,{
			Whitespace->"",
			Except[WordCharacter|DigitCharacter]->"$"
			}]},
			Block[{$BackupDirectoryName=$AppBackupDirectoryName},
				BackupCopyFile[file,name,Replace[root,Automatic:>$AppDirectory],ops]
				]
			];


AppDownload[
		file:(
				File[_String?(FileExtension@#==="zip"&)]|
				_String?(FileExtension@#==="zip"&)
				),
		name:(
				_String?(StringMatchQ[Except[WhitespaceCharacter|"/"|"_"|"."]..])|
				Automatic
				):Automatic,
		root:File[_String?DirectoryQ]|_String?DirectoryQ|Automatic:Automatic,
		ops:OptionsPattern[]
		]:=
	Block[{$BackupDirectoryName=$AppBackupDirectoryName},
		DownloadFile[file,name,Replace[root,Automatic:>$AppDirectory],ops]
		];


AppDownload[
		file:(_CloudObject|_URL|_String),
		name:(
				_String?(StringMatchQ[Except[WhitespaceCharacter|"/"|"_"|"."]..])|
				Automatic
				):Automatic,
		root:File[_String?DirectoryQ]|_String?DirectoryQ|Automatic:Automatic,
		ops:OptionsPattern[]
		]:=
	Block[{$BackupDirectoryName=$AppBackupDirectoryName},
		DownloadFile[
			Replace[file,_String:>
				Switch[
					OptionValue@"DownloadFrom",
					CloudObject,
						URLBuild@{$AppCloudExtension,file},
					"Google Drive",
						FileNameJoin@{$AppDirectoryName,file}
					]
				],
			name,
			Replace[root,Automatic:>$AppDirectory],
			ops]
		];


AppDownload[
	file_,
	name:(
				_String?(StringMatchQ[Except[WhitespaceCharacter|"/"|"_"|"."]..])|
				Automatic
				):Automatic,
	root:File[_String?DirectoryQ]|_String?DirectoryQ,
	source:Except[_Rule],
	ops:OptionsPattern[]
	]:=
	AppDownload[file,name,root,"DownloadFrom"->source,ops];


(* ::Subsubsection::Closed:: *)
(*AppBundle*)



Options[AppBundle]:=
	Join[
		Options@CreateSyncBundle,{
		"BundleInfo"->Automatic
		}];
AppBundle[
	paths:_String|{__String},
	exportDir:_String?DirectoryQ|Automatic:Automatic,
	metadata:{(_Rule|_RuleDelayed)..}|_Assocation:{},
	ops:OptionsPattern[]]:=
	Replace[OptionValue["BundleInfo"],{
		Automatic:>
			AppBundle[paths,exportDir,metadata,
				"BundleInfo"->
					Replace[AppPath[First@Flatten@{paths},"BundleInfo.m"],
						Except[_String?FileExistsQ]:>
							AppPath[First@Flatten@{paths},"BundleInfo.wl"]
						],
				ops
				],
		f:(_String|_File)?FileExistsQ|_URL:>
			AppBundle[paths,exportDir,metadata,
				"BundleInfo"->None,
				Replace[Import[f],{
					o:{__?OptionQ}:>
						(Sequence@@FilterRules[o,Options@AppBundle]),
					_:>(Sequence@@{})
					}],
				ops
				],
		_:>
			bundleApp[paths,exportDir,metadata,ops]
		}];
Options[bundleApp]=
	Options@AppBundle;
bundleApp[paths_,
	exportDir:_String?DirectoryQ|Automatic:Automatic,
	metadata:{(_Rule|_RuleDelayed)..}|_Assocation:{},
	ops:OptionsPattern[]]:=
	With[{bundle=
		CreateSyncBundle[
			Table[If[!FileExistsQ@app,AppDirectory@app,app],{app,Flatten@{paths}}],
			metadata,
			FilterRules[{
				ops,
				Directory->
					Automatic,
				Root->
					If[!FileExistsQ@First@Flatten@{paths},
						AppDirectory@First@Flatten@{paths},
						$AppDirectory
						]
				},
				Options@CreateSyncBundle
				]
			]},
		If[exportDir=!=Automatic,
			RenameFile[bundle,FileNameJoin@{exportDir,FileNameTake@bundle}],
			bundle
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppUpload*)



(* ::CodeInput::Plain:: *)
Options[AppUpload]:=
	Join[
		Options@AppBundle,
		Options@UploadFile,
		{
			Directory->Automatic
			}
		];
AppUpload[
	appName_String,
	ops:OptionsPattern[]]:=
	With[{dir=
		Block[{
			$AppDirectoryRoot=
				Replace[
					OptionValue@Directory,
					Except[_String?DirectoryQ]:>
						$AppDirectoryRoot
					]},
			If[!FileExistsQ@appName,AppDirectory@appName,appName]
			]},
		UploadFile[
			If[FileExistsQ@appName,
				appName,
				AppBundle[appName,
					FilterRules[{ops},Options@AppBundle]]
				],
			$AppCloudExtension,
			ops
			]
		];


AppUpload[
	appName_,
	sourceLink:"Google Drive"|CloudObject|Automatic,
	ops:OptionsPattern[]
	]:=
	AppUpload[appName,
		"UploadTo"->sourceLink,
		ops]


(* ::Subsubsection::Closed:: *)
(*AppBackup*)



AppBackup[appName_]:=
	With[{
		appDir=AppDirectory[appName]
		},
		BackupFile[appDir,$AppDirectory,$AppBackupDirectoryName]
		];	


(* ::Subsubsection::Closed:: *)
(*AppIndex*)



AppIndex[]:=Table[
{"Name","LastModified"}/.First@CloudObjectInformation@o,
{o,CloudObjects@CloudObject["applications"]}
];


(* ::Subsubsection::Closed:: *)
(*AppBackups*)



AppBackups[appName_:""]:=
	FileBackups[appName,AppDirectory@$AppBackupDirectoryName];


(* ::Subsubsection::Closed:: *)
(*AppRestore*)



AppRestore[appName_]:=
	RestoreFile[
		appName,
		AppDirectory@$AppBackupDirectoryName,
		$AppDirectory
		];


(* ::Subsection:: *)
(*Project Dist*)



$AppProjectExtension="project";
$AppProjectImages="img";
$AppProjectCSS="css";


(* ::Subsubsection::Closed:: *)
(*Readme*)



Options[AppDeployReadme]=
	{
		"UploadTo"->"Paclet"
		};
AppDeployReadme[appName_,ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		If[FileExistsQ@AppPath[app,"README.md"],
			Replace[OptionValue["UploadTo"],{
				"Paclet":>
					XMLDeploy[
						MarkdownGenerate[AppPath[app,"README.md"]],
						URLBuild@{AppPacletSiteURL[app],"README"},
						Permissions->"Public"
						],
				CloudObject[o_,___]:>
					XMLDeploy[
						MarkdownGenerate[AppPath[app,"README.md"]],
						URLBuild@{o,"README"},
						Permissions->"Public"
						],
				d_String?DirectoryQ:>
					XMLExport[
						MarkdownGenerate[AppPath[app,"README.md"]],
						FileNameJoin@{d,"README.html"}
						],
				d_String?SyncPathQ:>
					XMLExport[
						MarkdownGenerate[AppPath[app,"README.md"]],
						FileNameJoin@{SyncPath[d],"README.html"}
						]
				}
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Imgs*)



Options[AppDeployImages]=
	{
		"UploadTo"->"Paclet"
		};
AppDeployImages[appName_,ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		With[{imgFiles=
			FileNames["*."~~
				Alternatives@@ToLowerCase@Image`$ExportImageFormats,
				AppPath[app,$AppProjectExtension,$AppProjectImages]
				]
			},
			If[Length@imgFiles>0,
				Replace[OptionValue["UploadTo"],{
					"Paclet":>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										AppPacletSiteURL[app],
										$AppProjectExtension,$AppProjectImages,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							imgFiles
							],
					CloudObject[o_,___]:>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										o,
										$AppProjectExtension,$AppProjectImages,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							imgFiles
							],
					d_String?DirectoryQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									d,
									$AppProjectExtension,$AppProjectImages,
									FileNameTake[#]
									}
								]&,
							imgFiles
							],
					d_String?SyncPathQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									SyncPath[d],
									$AppProjectExtension,
									$AppProjectImages,
									FileNameTake[#]
									}
								]&,
							imgFiles
							]
					}
					]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*CSS*)



Options[AppDeployCSS]=
	{
		"UploadTo"->"Paclet"
		};
AppDeployCSS[appName_,ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		With[{cssFiles=
			FileNames["*.css",
				AppPath[app,$AppProjectExtension,$AppProjectCSS]
				]
			},
			If[Length@cssFiles>0,
				Replace[OptionValue["UploadTo"],{
					"Paclet":>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										AppPacletSiteURL[app],
										$AppProjectExtension,$AppProjectCSS,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							cssFiles
							],
					CloudObject[o_,___]:>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										o,
										$AppProjectExtension,$AppProjectCSS,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							cssFiles
							],
					d_String?DirectoryQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									d,
									$AppProjectExtension,$AppProjectCSS,
									FileNameTake[#]
									}
								]&,
							cssFiles
							],
					d_String?SyncPathQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									SyncPath[d],
									$AppProjectExtension,
									$AppProjectCSS,
									FileNameTake[#]
									}
								]&,
							cssFiles
							]
					}
					]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*HTML*)



Options[AppDeployHTML]=
	{
		"UploadTo"->"Paclet"
		};
AppDeployHTML[appName_,ops:OptionsPattern[]]:=
	With[{app=AppFromFile[appName]},
		With[{htmlFiles=
			FileNames["*.html",
				AppPath[app,$AppProjectExtension]
				]
			},
			If[Length@htmlFiles>0,
				Replace[OptionValue["UploadTo"],{
					"Paclet":>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										AppPacletSiteURL[app],
										$AppProjectExtension,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							htmlFiles
							],
					CloudObject[o_,___]:>
						Map[
							CopyFile[File[#],
								CloudObject[
									URLBuild@{
										o,
										$AppProjectExtension,
										FileNameTake[#]
										},
									Permissions->"Public"
									]
								]&,
							htmlFiles
							],
					d_String?DirectoryQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									d,
									$AppProjectExtension,
									FileNameTake[#]
									}
								]&,
							htmlFiles
							],
					d_String?SyncPathQ:>
						Map[
							CopyFile[
								#,
								FileNameJoin@{
									SyncPath[d],
									$AppProjectExtension,
									FileNameTake[#]
									}
								]&,
							htmlFiles
							]
					}
					]
				]
			]
		];


(* ::Subsection:: *)
(*Paclet Dist*)



(* ::Subsubsection::Closed:: *)
(*AppRegenerateUploadInfo*)



Options[AppRegenerateUploadInfo]=
	Join[
		Options@AppPacletSiteURL,
		Options@AppPacletSiteMZ
		];
AppRegenerateUploadInfo[app_String,ops:OptionsPattern[]]:=
	Export[AppPath[app,"UploadInfo.m"],
		Flatten@{
			ops,
			"ServerName"->
				Automatic,
			CloudConnect->
				False
			}];


(* ::Subsubsection::Closed:: *)
(*AppPacletSiteURL*)



Options[AppPacletSiteURL]=
	Options[PacletSiteURL];
AppPacletSiteURL[ops:OptionsPattern[]]:=
	PacletSiteURL[ops];
AppPacletSiteURL[app_String,ops:OptionsPattern[]]:=
	AppPacletSiteURL[ops,"ServerName"->app];


(* ::Subsubsection::Closed:: *)
(*AppPacletSiteInfo*)



Options[AppPacletSiteInfo]=
	Options@AppPacletSiteURL;
AppPacletSiteInfo[app_String,o:OptionsPattern[]]:=
	PacletSiteInfo@
		StringReplace[
			URLBuild@{
				AppPacletSiteURL[app,o],
				"PacletSite.mz"
				},
			StartOfString~~"file:":>"file://"
			];


(* ::Subsubsection::Closed:: *)
(*AppPacletSiteBundle*)



Options[AppPacletSiteBundle]=
	DeleteDuplicatesBy[First]@
		Join[{
			"BuildRoot":>$AppDirectory,
			"FilePrefix"->Automatic
			},
			Options[PacletSiteBundle]
			];
AppPacletSiteBundle[apps__String,ops:OptionsPattern[]]:=
	PacletSiteBundle[Sequence@@Map[AppDirectory,{apps}],
		FilterRules[{
			ops,
			If[OptionValue["FilePrefix"]===Automatic,
				"FilePrefix"->First@{apps},
				Nothing
				],
			Options[AppPacletSiteBundle]
			},
			Options[PacletSiteBundle]
			]
		]


(* ::Subsubsection::Closed:: *)
(*AppPacletBundle*)



Options[AppPacletBundle]=
	DeleteDuplicatesBy[First]@
		Join[{
			"BuildRoot":>$AppDirectory,
			"BundleInfo"->Automatic,
			"AppRegeneratePacletInfo"->False
			},
			Options[PacletBundle]
			];
AppPacletBundle[app_String?(FileExistsQ[AppDirectory[#]]&),
	ops:OptionsPattern[]]:=
	Replace[OptionValue["BundleInfo"],{
		Automatic:>
			AppPacletBundle[app,
				"BundleInfo"->
					Replace[AppPath[First@{app},"BundleInfo.m"],
						Except[_String?FileExistsQ]:>
							AppPath[First@{app},"BundleInfo.wl"]
						],
				ops
				],
		f:(_String|_File)?FileExistsQ|_URL:>
			AppPacletBundle[app,
				"BundleInfo"->None,
				ops,
				Replace[Import[f],{
					o:{__?OptionQ}:>
						(Sequence@@FilterRules[o,Options@AppPacletBundle]),
					_:>(Sequence@@{})
					}]
				],
		_:>
			PacletBundle[
				AppDirectory[app],
				FilterRules[{ops,Options[AppPacletBundle]},
					Options[PacletBundle]
					]
				]
		}];


(* ::Subsubsection::Closed:: *)
(*AppPacletInstallerURL*)



Options[AppPacletInstallerURL]=
	Options@PacletInstallerURL;
AppPacletInstallerURL[ops:OptionsPattern[]]:=
	PacletInstallerURL[ops];
AppPacletInstallerURL[app_String,ops:OptionsPattern[]]:=
	PacletInstallerURL[ops,"ServerName"->app];


(* ::Subsubsection::Closed:: *)
(*AppPacletInstaller*)



Options[AppPacletUploadInstaller]:=
	Options[PacletUploadInstaller];
AppPacletUploadInstaller[ops:OptionsPattern[]]:=
	PacletUploadInstaller[ops];
AppPacletUploadInstaller[app_,ops:OptionsPattern[]]:=
	PacletUploadInstaller[ops,"ServerName"->app]


(* ::Subsubsection::Closed:: *)
(*AppPacletUninstallerURL*)



Options[AppPacletUninstallerURL]=
	Options@PacletUninstallerURL;
AppPacletUninstallerURL[ops:OptionsPattern[]]:=
	PacletUninstallerURL[ops];
AppPacletUninstallerURL[app_String,ops:OptionsPattern[]]:=
	PacletUninstallerURL[ops,"ServerName"->app];


(* ::Subsubsection::Closed:: *)
(*AppPacletUninstaller*)



Options[AppPacletUploadUninstaller]:=
	Options[PacletUploadUninstaller];
AppPacletUploadUninstaller[ops:OptionsPattern[]]:=
	PacletUploadUninstaller[ops];
AppPacletUploadUninstaller[app_,ops:OptionsPattern[]]:=
	PacletUploadUninstaller[ops,"ServerName"->app]


(* ::Subsubsection::Closed:: *)
(*AppPacletUpload*)



Options[AppPacletUpload]=
	DeleteDuplicatesBy[First]@
		Join[
			{
				"PacletFiles"->Automatic,
				"UploadInfo"->Automatic,
				"RebundlePaclets"->True,
				"UploadSiteFile"->True,
				"UploadInstaller"->False,
				"UploadInstallLink"->Automatic,
				"UploadUninstaller"->False
				},
			Options[PacletUpload],
			Options[AppPacletBundle]
			];
AppPacletUpload[apps__String,ops:OptionsPattern[]]:=
	Replace[OptionValue["UploadInfo"],{
			Automatic:>
				AppPacletUpload[apps,
					"UploadInfo"->
						With[{app=
							If[Length@{apps}>0,
								First@{apps},
								OptionValue@"ServerName"]
							},
							If[StringQ@app,
								Replace[AppPath[app,"UploadInfo.m"],
									Except[_String?FileExistsQ]:>
										AppPath[app,"UploadInfo.wl"]
									],
								None
								]
							],
					ops
					],
			f:(_String|_File)?FileExistsQ|_URL:>
				AppPacletUpload[apps,
					Sequence@@FilterRules[{ops},
						Except["UploadInfo"]
						],
					"UploadInfo"->None,
					Replace[Import[f],{
						o:{__?OptionQ}:>
							(Sequence@@
								FilterRules[
									DeleteCases[o,Alternatives@@Options@AppPacletUpload],
									Options@AppPacletUpload]),
						_:>(Sequence@@{})
						}]
					],
			_:>
				With[{
					pacletFiles=
						Replace[OptionValue["PacletFiles"],
							Automatic:>
								If[OptionValue["RebundlePaclets"]//TrueQ,
									AppPacletBundle[#,
										FilterRules[{ops},Options@AppPacletBundle]
										]&/@{apps},
									If[FileExistsQ@
											AppPath[$PacletBuildExtension,#<>".paclet"],
										AppPath[$PacletBuildExtension,#<>".paclet"],
										AppPacletBundle[#,
											FilterRules[{ops},
												Options@AppPacletBundle
												]]
										]&/@{apps}
									]
							],
					site=
						Replace[OptionValue["SiteFile"],
							Except[_String?FileExistsQ]:>
								If[Not@FileExistsQ@
									AppPath[$PacletBuildExtension,
										First@{apps}<>"-PacletSite.mz"],
									AppPacletSiteBundle[apps],
									AppPath[$PacletBuildExtension,
										First@{apps}<>"-PacletSite.mz"]
									]
							]
					},
					PacletUpload[pacletFiles,
						FilterRules[
							Flatten@{
								"ServerName"->
									Replace[OptionValue["ServerName"],{
										Automatic:>First@{apps}
										}],
								ops,
								Options[AppPacletUpload],
								"SiteFile"->site
								},
							Options@PacletUpload
							]]
					]
			}];


(* ::Subsubsection::Closed:: *)
(*AppPacletDirectoryAdd*)



AppPacletDirectoryAdd[app_]:=
	If[DirectoryQ@AppDirectory[app],	
		PacletDirectoryAdd@AppDirectory[app]
		];


(* ::Subsubsection::Closed:: *)
(*AppSubpacletUpload*)



Options[AppSubpacletUpload]=
	Join[
		Options@AppPacletUpload,
		Options@AppConfigureSubapp
		];
AppSubpacletUpload[
	app_:Automatic,
	name:_String|{__String},
	ops:OptionsPattern[]
	]:=
	With[{
		dir=
			AppConfigureSubapp[app,name,
				FilterRules[{
					ops,
					"PacletInfo"->{
						"Description"->
							TemplateApply["A subpaclet of ``",AppFromFile[app]]
						}
					},
					Options@AppConfigureSubapp
					]
				]
		},
		Block[{
			$AppDirectoryRoot=DirectoryName@dir,
			$AppDirectoryName=Nothing,
			appName=FileBaseName@dir
			},
			AppPacletBundle[appName];
			AppPacletUpload[appName,
				FilterRules[{
					ops
					},
					Options@AppPacletUpload
					]
				]
			]
		];


(* ::Subsubsection::Closed:: *)
(*AppPacletServerPage*)



Options[AppPacletServerPage]=
	Options[PacletServerPage];
AppPacletServerPage[ops:OptionsPattern[]]:=
	PacletServerPage[ops];
AppPacletServerPage[app:Except[_?OptionQ],ops:OptionsPattern[]]:=
	AppPacletServerPage[
		"ServerName"->
			Lookup[
				Association@Flatten@{ops},
				"ServerName",
				AppFromFile@app
				],
		ops
		];


End[];



