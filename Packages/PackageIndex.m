(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Section:: *)
(*PackageIndex*)



(* ::Subsection:: *)
(*Index*)



PackageIndexRefresh::usage=
	"Pulls syncs down the PackageIndex";
$PackageIndex::usage=
	"An index of packages and authors";
PackageIndexLoad::usage=
	"Adds the index to the $EntityStores";
PackageIndexData::usage=
	"A data function layered on top of the paclet data";
PackageAuthorData::usage=
	"A data function layered on top of the paclet author data";


(* ::Subsection:: *)
(*Edit*)



PackageIndexEdit::usage=
	"Edits the index";
PackageIndexNew::usage=
	"Adds a new Entity to the index";
PackageIndexExport::usage=
	"Exports the package index to a site";


(* ::Subsection:: *)
(*API*)



PackageIndexAPI::usage=
	"A web api for submitting new packages to the index";
PackageSubmitForm::usage=
	"A web interface for submitting new packages to the index";


(* ::Subsection:: *)
(*Install*)



PackageIndexInstall::usage=
	"Installs a package from the index";
PackageIndexUninstall::usage=
	"Uninstalls a package from the index";


Begin["`Private`"];


(* ::Subsection:: *)
(*Config*)



$PackageIndexURIData=
	<|
		"Root"->"PackageIndex",
		"EntityStore"->"EntityStore.mx",
		"SubmissionForm"->"submit",
		"API"->"api",
		"AccountURL"->
			"user-13f6055a-bf2f-4f56-b49e-4e7b72430c04",
		"Log"->
			"log"
		|>;
PackageIndexURI[parts__String]:=
	URLBuild@
		Lookup[$PackageIndexURIData,{parts}];
$PackageIndexCloudObject=
	CloudObject[
		URLBuild[<|
			"Scheme"->"user",
			"Path"->
				Lookup[$PackageIndexURIData,
					{"AccountURL","Root","EntityStore"}
					]
			|>]
		];


(* ::Subsection:: *)
(*Basics*)



(* ::Subsubsection::Closed:: *)
(*PackageIndexRefresh*)



$UseCloudIndex=True;
$CachePackageIndex=True;


PackageIndexRefresh[useCloud:True|False|Automatic:Automatic]:=(
	Replace[e_EntityStore:>($PackageIndex=e)]@
	If[Replace[useCloud,Automatic->$UseCloudIndex],
		Replace[
			If[FileExistsQ@
					LocalObject[PackageIndexURI["Root","EntityStore"]],
				TimeConstrained[
					CloudImport[$PackageIndexCloudObject],
					5
					],
				CloudImport[$PackageIndexCloudObject]
				],{
			Except[_EntityStore]:>
				Replace[
					Quiet[
						Import@LocalObject[PackageIndexURI["Root","EntityStore"]],
						Import::nffil
						],
					Except[_EntityStore]:>
						EntityStore[{
							"Package"-><|
								"Entities"-><|
								
									|>,
								"Properties"-><|
									"Name"-><|
										"Label"->"name"
										|>,
									"Author"-><|
										"Label"->"author"
										|>,
									"Description"-><|
										"Label"->"description"
										|>,
									"HomePage"-><|
										"Label"->"home page"
										|>,
									"Location"-><|
										"Label"->"location"
										|>,
									"Keywords"-><|
										"Label"->"keywords"
										|>,
									"Label"-><|
										"Label"->"entity label",
										"DefaultFunction"->
											(#["Name"]&)
										|>
									|>,
								"Label"->
									"Mathematica package",
								"LabelPlural"->
									"Mathematica packages"
								|>,
							"PackageAuthor"-><|
								"Entities"-><|
									
									|>,
								"Properties"-><|
									"Name"-><|
										"Label"->"name"
										|>,
									"Bio"-><|
										"Label"->"bio"
										|>,
									"HomePage"-><|
										"Label"->"home page"
										|>,
									"Links"-><|
										"Label"->"links"
										|>,
									"Label"-><|
										"Label"->"entity label",
										"DefaultFunction"->
											(#["Name"]&)
										|>
									|>,
								"Label"->
									"package author",
								"LabelPlural"->
									"package authors"
									|>
								}
							]
					],
				e_EntityStore:>
					(
						Put[e,LocalObject[PackageIndexURI["Root","EntityStore"]]];
						e
						)
				}
			],
		Quiet@
			Import@LocalObject[PackageIndexURI["Root","EntityStore"]]
			]//
		Replace[
			e_EntityStore:>(
				If[$PackageIndexLoaded,
					PackageIndexLoad[]
					];
				e
				)
			]
	);


(* ::Subsubsection::Closed:: *)
(*$PackageIndex*)



If[!MatchQ[OwnValues@$PackageIndex,{_:>(_EntityStore)}],
	$PackageIndex:=PackageIndexRefresh[]
	];


(* ::Subsubsection::Closed:: *)
(*Install*)



$PackageIndexLoaded:=
	!MissingQ@
		SelectFirst[
			$EntityStores,
			Keys[#[[1,"Types"]]]=={"Package","PackageAuthor"}&
			];


PackageIndexLoad[]:=
	$EntityStores=
		Prepend[
			Select[$EntityStores,
				Keys[#[[1,"Types"]]]!={"Package","PackageAuthor"}&
				],
			$PackageIndex
			];


(* ::Subsubsection::Closed:: *)
(*Data*)



PackageIndexData[name_String]:=
	(
		If[!$PackageIndexLoaded,PackageIndexLoad[]];
		EntityList@
			EntityClass[
				"Package",
				"Name"->StringMatchQ[name]
				]
		);
PackageIndexData[name_String,properties_]:=
	EntityValue[PackageIndexData[name],properties];


PackageAuthorData[name_]:=
	(
		If[!$PackageIndexLoaded,PackageIndexLoad[]];
		EntityList@
			EntityClass[
				"PackageAuthor",
				"Name"->StringMatchQ[name]
				]
		);
PackageAuthorData[name_String,properties_]:=
	EntityValue[PackageAuthorData[name],properties];


(* ::Subsection:: *)
(*Edits*)



(* ::Subsubsection::Closed:: *)
(*PackageIndexEdit*)



(PackageIndexEdit[
	ent:"Package"|"PackageAuthor":"Package",
	data_Association,
	property:"Entities"|"Properties":"Entities"
	]/;If[property==="Entities",
			AllTrue[Keys@data,StringQ]&&
			StringContainsQ[First@Keys@data,"::"],
			AllTrue[Keys@data,StringQ]
			]
	):=
	(
		$PackageIndex=
			ReplacePart[$PackageIndex,
				{1,"Types",ent,property}->
					Merge[{
						$PackageIndex[ent,property],
						If[property==="Entities",
							KeySelect[
								MatchQ[
									Alternatives@@
										Keys@$PackageIndex[ent,"Properties"]
									]
								],
							KeySelect[
								MatchQ["Label"|"DefaultFunction"]
								]
							]/@data
						},
						Apply@Join
						]
				];
		If[$PackageIndexLoaded,PackageIndexLoad[]];
		$PackageIndex
		);
PackageIndexEdit[
	ent:"Package"|"PackageAuthor":"Package",
	data:{__Association?(KeyMemberQ[#,"CanonicalName"]&)},
	property:"Entities"|"Properties":"Entities"
	]:=
	PackageIndexEdit[ent,
		Association[
			#["CanonicalName"]->
				KeyDrop[#,"CanonicalName"]
			&/@data
			],
		property];
PackageIndexEdit[
	ent:"Package"|"PackageAuthor":"Package",
	data:_Association?(KeyMemberQ[#,"CanonicalName"]&),
	property:"Entities"|"Properties":"Entities"
	]:=
	PackageIndexEdit[ent,{data},property];
PackageIndexEdit[
	ent:"Package":"Package",
	data:{__Association?(KeyMemberQ[#,"Name"]&&KeyMemberQ[#,"Author"]&)},
	Optional["Entities","Entities"]
	]:=
	With[{
		ents=
			Map[
				With[{d=#},
					Replace[
						Select[
							$PackageIndex[ent,"Entities"],
							#["Name"]==d["Name"]&&
								(
									MissingQ@d["Author"]||
										#["Author"]==d["Author"]
									)&
							],{
							a_Association:>
								First@Keys@a,
							_->None	
						}]
					]->#&,
				data
				]
		},
		With[{
			edits=
				GroupBy[Normal@ents,
					First@#===None&->(If[First@#===None,Last@#,#]&),
					Map[Association]
					]
			},
			PackageIndexNew[ent,
				edits[True]
				];
			PackageIndexEdit[ent,
				Join@@
					edits[False]
				];
			$PackageIndex
			]
		];
PackageIndexEdit[
	ent:"Package":"Package",
	data:_Association?(KeyMemberQ[#,"Name"]&&KeyMemberQ[#,"Author"]&),
	Optional["Entities","Entities"]
	]:=
	PackageIndexEdit[ent,{data},"Entities"];


PackageIndexEdit[
	ent:Entity["Package"|"PackageAuthor",_],
	data_Association
	]:=
	PackageIndexEdit[
		EntityTypeName@ent,
		<|
			CanonicalName[ent]->data
			|>,
		"Entities"
		];


PackageIndexEdit::nope=
	"Multiple entities found for name ``. Choose one of ``";
PackageIndexEdit::nope=
	"No entities found for name ``";
PackageIndexEdit[
	Optional["Package","Package"],
	name_String,
	data_Association
	]:=
	Replace[PackageIndexData[name],{
		{e_}:>
			PackageIndexEdit[e,data],
		e:{_,__}:>
			(Message[PackageIndexEdit::ambig,name,e];$Failed),
		{}:>
			(Message[PackageIndexEdit::nope,name];$Failed)
		}];


(* ::Subsubsection::Closed:: *)
(*PackageIndexNew*)



PackageIndexNew[
	ent:"Package"|"PackageAuthor":"Package",
	props:{__Association}
	]:=
	PackageIndexEdit[
		ent,
		Association@
			Map[
				StringJoin@{
					StringReplace[#["Name"],
						Except[WordCharacter]->""
						],
					"::",
					RandomSample[
						Join[Alphabet[],ToString/@Range[0,9]],
						5
						]
					}->#&,
				props
				],
	"Entities"
	];
PackageIndexNew[
	ent:"Package"|"PackageAuthor":"Package",
	name_String,
	props___?OptionQ
	]:=
	PackageIndexNew[ent,{
		Association@
			Flatten@{
				"Name"->name,
				props
				}
		}]


(* ::Subsection:: *)
(*Web Interface*)



(* ::Subsubsection::Closed:: *)
(*PackageIndexExport*)



Options[PackageIndexExport]=
	Join[{
		Permissions->"Public"
		},
		Options[CloudExport]
		];
PackageIndexExport[
	file:(_String|_File)?(DirectoryQ@DirectoryName@#&)
	]:=
	Export[file,
		$PackageIndex,
		"MX"
		];
PackageIndexExport[
	uri:(_String|_URL|_CloudObject):PackageIndexURI["Root","EntityStore"],
	ops:OptionsPattern[]
	]:=
	CloudExport[
		$PackageIndex,
		"MX",
		uri,
		ops,
		Options[PackageIndexExport]
		]


(* ::Subsubsection::Closed:: *)
(*PackageIndexAPI*)



Options[PackageIndexAPI]=
	Join[{
		Permissions->"Public"
		},
		Options[CloudDeploy]
		];
PackageIndexAPI[
	uri:(_String|_URL|_CloudObject):PackageIndexURI["Root","API"],
	index:(_String|_URL|_CloudObject):PackageIndexURI["Root","EntityStore"],
	ops:OptionsPattern[]
	]:=
	With[{$PackageIndexObject=CloudObject[index]},
		CloudDeploy[
			APIFunction[{
				"Action"->
					Restricted["String",{{"Edit","View"}}]->
						"View",
				"Type"->
					Restricted["String",{{"Package","PackageAuthor"}}]->
						"Package",
				"Data"->"Expression"-><||>
				},
				(
					$PackageIndex=
						CloudImport@$PackageIndexObject;
					If[#Action=="Edit",
						PackageIndexEdit[#Type,#Data];
						PackageIndexExport[index,ops]
						];
					Switch[#Action,
						"View",
							ExportForm[
								Flatten@{
									"Credits left:",
										$CloudCreditsAvailable,
									Style["Packages:","Subsubsection"],
									Map[
										If[!MissingQ@#["HomePage"],
											Hyperlink[#["Name"],#["HomePage"]],
											#["Name"]
											]&,
										SortBy[
											KeyMap[CanonicalName]/@
												PackageIndexData["*",
													"PropertyAssociation"],
											#Name&
											]
										]
									}//Column,
								"HTML"
								],
						"Edit",
							Length@PackageIndexData["*"]
						]
					)&
				],
			uri,
			ops,
			Options[PackageSubmitAPI]
			]
		];


(* ::Subsubsection::Closed:: *)
(*PackageSubmitForm*)



Options[PackageSubmitForm]=
	Join[{
		Permissions->"Public"
		},
		Options[CloudDeploy]
		];
PackageSubmitForm[
	uri:(_String|_URL|_CloudObject):PackageIndexURI["Root","SubmissionForm"],
	index:(_String|_URL|_CloudObject):PackageIndexURI["Root","EntityStore"],
	ops:OptionsPattern[]
	]:=
	With[{$PackageIndexObject=CloudObject[index]},
		CloudDeploy[
			FormFunction[{
				Style["Package Index: Submit",
					"Title"
					],
				Style["This will submit your package to the package index",
					"Text"
					],
				Style["The only required fields are the name, author and location, but a description is nice and a home page provide easy linking",
					"Text"
					],
				Style["This deployment is from a free account and so may disappear or run out of credits at any time, so try not to over-use it.",
					"Text"
					],
				Style[
					Row@{
						"If a new deployment needs to be created email",
						Spacer[2],
						Hyperlink[
							"mpmindex@gmail.com",
							"mailto:mpmindex@gmail.com?subject=New%20package%20deployment"
							]
						},
					"Text"
					],
				"Name"->"String",
				"Author"->"String",
				"Location"->"String",
				{"HomePage","Home Page"}->""->"",
				"Description"->"TextArea"->""
				},
				(
					$PackageIndex=
						CloudImport@$PackageIndexObject;
					PackageIndexEdit["Package",#];
					PackageIndexExport[index,ops];
					Flatten@{
						"Credits left:",
							$CloudCreditsAvailable,
						Style["Packages:","Subsubsection"],
						Map[
							If[!MissingQ@#["HomePage"],
								Hyperlink[#["Name"],#["HomePage"]],
								#["Name"]
								]&,
							SortBy[
								KeyMap[CanonicalName]/@
									PackageIndexData["*",
										"PropertyAssociation"],
								#Name&
								]
							]
						}//Column
					)&
				],
			uri,
			ops,
			Options[PackageSubmitForm]
			]
		];


 


(* ::Subsection:: *)
(*Log*)



$PackageIndexLogFile:=
	LocalObject[PackageIndexURI["Root","Log"]];


PackageIndexLogGet[]:=
	Replace[
		Quiet[Get@$PackageIndexLogFile,LocalObject::nso],
		$Failed->{}
		];


PackageIndexLogEvent[
	eventType_,
	args_,
	dateStamp_:Automatic,
	result_
	]:=
	(
		Put[
			Append[
				PackageIndexLogGet[],
				{Replace[dateStamp,Automatic->Now],eventType,args}->result
				],
			$PackageIndexLogFile
			];
		result
		);
PackageIndexPurgeEvent[
	timeStampPattern_:_,
	eventType_,
	args_
	]:=
	Put[
		DeleteCases[
			PackageIndexLogGet[],
			{timeStampPattern,eventType,args}->_
			],
		$PackageIndexLogFile
		];
PackageIndexGetEvents[
	eventType_,
	args_,
	timeStampPattern_:_
	]:=
	Reverse@
		SortBy[
			Select[
				PackageIndexLogGet[],
				MatchQ[First@#,{timeStampPattern,eventType,args}]&
				],
			#[[1,1]]&
			];


PackageIndexClearLog[]:=
	Put[{},$PackageIndexLogFile];


(* ::Subsection:: *)
(*PackageIndexUninstall*)



Options[PackageIndexUninstall]=
	{
		"UninstallDependencies"->
			False
		};
PackageIndexUninstall[
	loc:(_String|_File)?FileExistsQ
	]:=
	PacletManager`PacletUninstall@loc;
PackageIndexUninstall::noinst=
	"Couldn't find installation for location ``";
PackageIndexUninstall[
	loc:(_String?(URLParse[#,"Scheme"]=!=None&)|_URL)
	]:=
	Replace[
		PackageIndexGetEvents[
			"Install",
			loc,
			_
			],{
		{l1_->pacs_,___}:>
			If[OptionValue["UninstallDependencies"]//TrueQ,
				PacletManager`PacletUninstall/@Flatten@{pacs};
				PackageIndexPurgeEvent@@l1;,
				PacletManager`PacletUninstall@First@Flatten@{pacs};
				PackageIndexPurgeEvent@@l1;
				If[Length@Flatten@{pacs}>1,
					PackageIndexLogEvent@@
						Append[l1,Rest@Flatten@{pacs}]
					];
				],
		{}:>
			Message[PackageIndexUninstall::noinst,loc]
		}];


(* ::Subsubsection::Closed:: *)
(*Entity*)



PackageIndexUninstall[e:Entity["Package",_],
	ops:OptionsPattern[]
	]:=
	PackageIndexUninstall[e["Location"]];


(* ::Subsubsection::Closed:: *)
(*Name*)



PackageIndexUninstall::dunno=
	"Multiple matches for name ``. Select one and uninstall with PackageIndexUninstall.";
PackageIndexUninstall::noent=
	"No matches for name ``. Find one with PackageIndexData.";
PackageIndexUninstall[
	name_String,
	ops:OptionsPattern[]
	]:=
	Replace[PackageIndexData[name],{
		{e:Entity["Package",_]}|e:Entity["Package",_]:>
			PackageIndexUninstall@e,
		e:{Entity["Package",_],___}:>(
			Message[PackageIndexUninstall::dunno,name];
			e
			),
		{}:>
			(
				Message[PackageIndexUninstall::noent,name];
				$Failed
				)
		}];


(* ::Subsection:: *)
(*PackageIndexInstall*)



$PackageDependenciesFile=
	"DependencyInfo.m";


(* ::Subsubsection::Closed:: *)
(*installPacletGenerate*)



PackageIndexInstall::howdo="Unsure how to pack a paclet from file type ``";


Options[installPacletGenerate]={
	"Verbose"->False
	};
installPacletGenerate[dir:(_String|_File)?DirectoryQ,ops:OptionsPattern[]]:=
	(
		If[OptionValue@"Verbose",
			DisplayTemporary@
				Internal`LoadingPanel[
					TemplateApply["Bundling paclet for ``",dir]
					]
				];
		If[FileExistsQ@#,Quiet@ExtractArchive[#,dir]]&/@
			Map[
				FileNameJoin@{dir,FileBaseName@dir<>#}&,
				{".zip",".gz"}
				];
		If[FileExistsQ@FileNameJoin@{dir,FileBaseName@dir,"PacletInfo.m"},
			PacletBundle@FileNameJoin@{dir,FileBaseName@dir},
			If[!FileExistsQ@FileNameJoin@{dir,"PacletInfo.m"},
				PacletExpressionBundle[dir]
				];
			PacletBundle[dir]
			]
		);
installPacletGenerate[file:(_String|_File)?FileExistsQ,ops:OptionsPattern[]]:=
	Switch[FileExtension[file],
		"m"|"wl",
			If[OptionValue@"Verbose",
				DisplayTemporary@
					Internal`LoadingPanel[
						TemplateApply["Bundling paclet for ``",file]
						]
					];
			With[{dir=
				FileNameJoin@{
					$TemporaryDirectory,
					FileBaseName@file
					}
				},
				Quiet@CreateDirectory[dir];
				If[FileExistsQ@
					FileNameJoin@{
						DirectoryName@file,
						$PackageDependenciesFile
						},
					CopyFile[
						FileNameJoin@{
							DirectoryName@file,
							$PackageDependenciesFile
							},
						FileNameJoin@{
							dir,
							$PackageDependenciesFile
							}	
						]
					];
				If[FileExistsQ@
					FileNameJoin@{
						DirectoryName@file,
						"PacletInfo.m"
						},
					CopyFile[
						FileNameJoin@{
							DirectoryName@file,
							"PacletInfo.m"
							},
						FileNameJoin@{
							dir,
							"PacletInfo.m"
							}	
						]
					];(*
				Quiet@CreateDirectory[
					FileNameJoin@{
						dir,
						"Kernel"
						}];
				With[{bn=FileBaseName@file<>"`"<>FileBaseName@file<>"`"},
					Put[
						Unevaluated[Get@bn],
						FileNameJoin@{
							dir,
							"Kernel",
							"init.m"
							}]
					];*)
				CopyFile[file,
					FileNameJoin@{
						dir,
						FileNameTake@file
						},
					OverwriteTarget->True
					];
				PacletExpressionBundle[dir,
					"Name"->
						StringReplace[FileBaseName[dir],
							Except[WordCharacter|"$"]->""]
							];
				PacletBundle[dir,
					"BuildRoot"->$TemporaryDirectory
					]
				],
		"paclet",
			file,
		_,
			Message[PackageIndexInstall::howdo,
				FileExtension@file
				]
		];


(* ::Subsubsection::Closed:: *)
(*gitPacletPull*)



gitPacletPull//Clear


gitPacletPull[loc:(_String|_File|_URL)?GitHubPathQ]:=
	GitHub["Pull",loc];
gitPacletPull[loc:(_String|_File|_URL)?(Not@*GitHubPathQ)]:=
	GitClone[loc];


(* ::Subsubsection::Closed:: *)
(*wolframLibraryPull*)



wolframLibraryPull[loc:_String|_URL]:=
	With[{fileURLs=
		URLBuild@
			Merge[{
					URLParse[loc],
					URLParse[#]
					},
				Replace[DeleteCases[#,None],{
						{s_}:>s,
						{___,l_}:>l,
						{}->None
						}]&
				]&/@
			Cases[
				Import[loc,{"HTML","XMLObject"}],
				XMLElement["a",
					{
						___,
						"href"->link_,
						___},
					{___,
						XMLElement["img",
							{___,"src"->"/images/database/download-icon.gif",___},
							_],
						___}
					]:>link,
				\[Infinity]
				]
		},
		With[{name=
			FileBaseName@
				First@
					SortBy[
						Switch[FileExtension[#],
							"paclet",
								0,
							"zip"|"gz",
								1,
							"wl"|"m",
								2,
							_,
								3
							]&
						][URLParse[#,"Path"][[-1]]&/@fileURLs]
				},
			Quiet@
				DeleteDirectory[
					FileNameJoin@{$TemporaryDirectory,name},
					DeleteContents->True
					];
			CreateDirectory@FileNameJoin@{$TemporaryDirectory,name};
			MapThread[
				RenameFile[
					#,
					FileNameJoin@{$TemporaryDirectory,name,URLParse[#2,"Path"][[-1]]}
					]&,{
				URLDownload[fileURLs,
					FileNameJoin@{$TemporaryDirectory,name}],
				fileURLs
				}];
			FileNameJoin@{$TemporaryDirectory,name}
			]
		]


(* ::Subsubsection::Closed:: *)
(*downloadURLIfExists*)



downloadURLIfExists[urlBase_,{files__},dir_]:=
	If[
		MatchQ[0|200]@
			URLSave[
				URLBuild@{urlBase,#},
				FileNameJoin@{
					dir,
					#
					},
				"StatusCode"
				],
		FileNameJoin@{
			dir,
			#
			},
		Quiet@
			DeleteFile@
				FileNameJoin@{
					dir,
					#
					};
		Nothing
		]&/@{files}


(* ::Subsubsection::Closed:: *)
(*PackageIndexInstall*)



PackageIndexInstall::nopac=
	"No paclets found at location ``";


(* ::Subsubsubsection::Closed:: *)
(*Site*)



Options[PackageIndexInstall]=
	{
		"Verbose"->True,
		"InstallSite"->True,
		"InstallDependencies"->
			Automatic,
		"Log"->True
		};
PackageIndexInstall[
	loc:(_String|_File)?FileExistsQ,
	ops:OptionsPattern[]
	]:=
	Replace[
		installPacletGenerate[loc,ops],{
			File[f_]|(f_String?FileExistsQ):>
				Replace[PacletManager`PacletInstall@f,
					p_PacletManager`Paclet:>
						With[{deps=
							Replace[OptionValue["InstallDependencies"],{
								Automatic->{"Standard"},
								True->All
								}]
							},
						If[MatchQ[deps,_List|All],
							Flatten@{
								p,
								With[{l=PacletLookup[p,"Location"]},
									If[FileExistsQ@FileNameJoin@{l,$PackageDependenciesFile},
										Replace[Import[$PackageDependenciesFile],{
											a_Association:>
												Switch[deps,
													All,
														Flatten@
															Map[Map[PackageIndexInstall,#]&,a],
													_,
														Flatten@
															Map[PackageIndexInstall,
																Flatten@Lookup[a,deps,{}]
																]
													],
											l_List:>
												Map[PackageIndexInstall,l]
											}],
										{}
										]
									]
								},
							p
							]
						]
					]
			}];
PackageIndexInstall[loc:(_String?(URLParse[#,"Scheme"]=!=None&)|_URL),
	ops:OptionsPattern[]
	]:=
	Replace[{
		p:_PacletManager`Paclet|{_PacletManager`Paclet,($Failed|PacletManager`Paclet)...}:>
			If[OptionValue["Log"],
				PackageIndexLogEvent[
					"Install",
					loc,
					Flatten@{p}
					];
				First@Flatten@{p},
				First@p
				]
		}]@
		Which[
			URLParse[loc,"Domain"]==="github.com",
				With[{dir=
					If[OptionValue@"Verbose"//TrueQ,
						Monitor[
							gitPacletPull[loc],
							Which[GitHubRepoQ@loc,
								Internal`LoadingPanel[
									TemplateApply["Cloning repository at ``",loc]
									],
								GitHubReleaseQ@loc,
									Internal`LoadingPanel[
										TemplateApply["Pulling release at ``",loc]
										],
								True,
									Internal`LoadingPanel[
										TemplateApply["Downloading from ``",loc]
										]
								]
							],
						gitPacletPull[loc]
						]
					},
					PackageIndexInstall@dir
					],
			URLParse[loc,"Domain"]==="library.wolfram.com",
				With[{dir=
					If[OptionValue@"Verbose"//TrueQ,
						Monitor[
							wolframLibraryPull[loc],
							Internal`LoadingPanel[
								TemplateApply["Downloading from library.wolfram.com ``",loc]
								]
							],
						gitPacletPull[loc]
						]
					},
					PackageIndexInstall@dir
					],
			True,
				If[
					And[
						OptionValue["InstallSite"]//TrueQ,
						MatchQ[
							Quiet@PacletSiteInfo[loc],
							PacletManager`PacletSite[__PacletManager`Paclet]
							]
						],
					PacletSiteInstall[loc],
					Switch[URLParse[loc,"Path"][[-1]],
						_?(FileExtension[#]=="paclet"&),
							PackageIndexInstall@URLDownload[loc],
						_?(MatchQ[FileExtension[#],"m"|"wl"]&),
							PackageIndexInstall@
								downloadURLIfExists[
									URLBuild[
										ReplacePart[#,
											"Path"->
												Drop[#Path,-1]
											]&@URLParse[loc]
										],{
									URLParse[loc,"Path"][[-1]],
									$PackageDependenciesFile,
									"PacletInfo.m"
									}],
						_,
							Replace[
								Quiet@Normal@PacletSiteInfoDataset[loc],{
									Except[{__Association}]:>
										(
											Message[PackageIndexInstall::nopac,loc];
											$Failed
											),
									a:{__Association}:>
										PackageIndexInstall[
											URLBuild@
												Flatten@{
													loc,
													StringJoin@{
														Lookup[Last@SortBy[a,#Version&],{
															"Name",
															"Version"
															}],
														".paclet"
														}
													},
											ops
											]
								}]
						]
					]
			];


(* ::Subsubsubsection::Closed:: *)
(*Entity*)



PackageIndexInstall::hiauth=
	"Couldn't install package `` from ``. Try contacting `` for more info";
PackageIndexInstall::noinst=
	"Couldn't install package `` from ``";
PackageIndexInstall[e:Entity["Package",_],
	ops:OptionsPattern[]
	]:=
	Replace[
		PackageIndexInstall[e["Location"]],{
		h:Except[
			_PacletManager`Paclet|
			{_PacletManager`Paclet,($Failed|PacletManager`Paclet)...}
			]:>
			If[MissingQ@e["Author"],
				Message[PackageIndexInstall::noinst,
					e["Name"],
					e["Location"]
					];
				$Failed,
				Message[PackageIndexInstall::hiauth,
					e["Name"],
					e["Location"],
					e["Author"]
					];
				$Failed
				]
		}];


(* ::Subsubsubsection::Closed:: *)
(*Name*)



PackageIndexInstall::dunno=
	"Multiple matches for name ``. Select one and install with PackageIndexInstall.";
PackageIndexInstall::noent=
	"No matches for name ``. Find one with PackageIndexData.";
PackageIndexInstall[name_String,
	ops:OptionsPattern[]
	]:=
	Replace[PackageIndexData[name],{
		{e:Entity["Package",_]}|e:Entity["Package",_]:>
			PackageIndexInstall@e,
		e:{Entity["Package",_],___}:>(
			Message[PackageIndexInstall::dunno,name];
			e
			),
		{}:>
			(
				Message[PackageIndexInstall::noent,name];
				$Failed
				)
		}];


End[];



