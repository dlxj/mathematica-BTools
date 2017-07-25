(* ::Package:: *)

$packageHeader

CuratedDataExport::usage=
	"Exports an EntityStore as a CuratedData function backed by DataPaclets";


Begin["`Private`"];


(* ::Subsection:: *)
(*Constants*)



dataPacletIndexNumber[padLength_,num_Integer]:=
	StringPadLeft[ToString@num,padLength,"0"];
dataPacletIndexNumber[padLength_,{num_Integer}]:=
	dataPacletIndexNumber[padLength,num];
dataPacletIndexNumber[num_]:=
	dataPacletIndexNumber[$dataPacletPartitionNumber,num];


$dataPacletVersionNumber="1.0.0";


(* ::Subsection:: *)
(*IndexPaclet*)



(* ::Subsubsection::Closed:: *)
(*Primary Index*)



dataPacletIndexFile[
	dir:_String?DirectoryQ|Automatic:Automatic,
	dataType_String,
	entityStore:_Association|{__Association}
	]:=
	With[{
		index=
			{
				"Sources"->
					{
						"Data"->
							If[AssociationQ@entityStore,
								{
								"Part01"->
									Keys@
										entityStore["Entities"]
										},
								MapIndexed[
									"Part"<>dataPacletIndexNumber[#2]->
										Keys@#["Entities"]&,
									entityStore
									]
								]
						},
				"Properties"->
					{
						"Data"->
							Thread@List@
								DeleteCases["Label"]@
									Keys@
										If[AssociationQ@entityStore,
											entityStore,
											First@entityStore
											]["Properties"]
						}
				}
		},
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Index",
				"Data",
				"Index.wdx"
				},
			index,
			"DataIndex"
			]
		];


(* ::Subsubsection::Closed:: *)
(*Names Index*)



dataPacletNamesIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	With[{
		names=
			Normal@
				AssociationMap[
					{#,First@StringSplit[#,"::"]}&,
					Flatten@{
						Keys@entityStore["Entities"],
						Lookup[
							Values@entityStore["Entities"],
							"AlternateNames",
							{}
							]
						}
					]
		},
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Index",
				"Data",
				"Names.wdx"
				},
			names
			]
		];


(* ::Subsubsection::Closed:: *)
(*Entities Index*)



dataPacletEntitiesIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	Export[
		FileNameJoin@{
			Replace[dir,
				Automatic:>
					$TemporaryDirectory
				],
			StringTrim[dataType,"Data"]<>"Data_Index",
			"Data",
			"Entities.wdx"
			},
		Compress@
			Map[
				Hash[#,"Adler32"]->#&,
				Keys@entityStore["Entities"]
				]
		];


(* ::Subsubsection::Closed:: *)
(*Properties Index*)



dataPacletPropertiesIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	With[{
		properties=
			Thread@List@
				DeleteCases["Label"]@
					Keys@entityStore["Properties"]
		},
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Index",
				"Data",
				"Properties.wdx"
				},
			Compress@{"Data"->properties}
			];
		]


(* ::Subsubsection::Closed:: *)
(*Functions Index*)



dataPacletFunctionsIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	With[{
		functions=
			With[{computeFunction=
				Symbol@Evaluate["DataPaclets`"<>StringTrim[dataType,"Data"]<>"DataDump`ComputeFunction"]
				},
			Normal@
				ReplacePart[#,
					"Helpers":>
						(
							Normal@GroupBy[First->Last]@Flatten@#["Helpers"]
							)
					]&@
			Join[
				<|
					"Primary"->{},
					"Helpers"->{}
					|>,
				GroupBy[First->Last]@
					Replace[
						Lookup[entityStore,"Functions",{}],{
							(Verbatim[HoldPattern][p___]:>f_):>
								"Primary"->
									(
										HoldPattern[computeFunction[p]]:>f
											),
							s_Symbol:>
								With[{key=
									SymbolName@Unevaluated@s
									},
									"Helpers"->
										{
											"OwnValues"->
												(key->OwnValues[s]),
											"DownValues"->
												(key->DownValues[s]),
											"UpValues"->
												(key->UpValues[s]),
											"SubValues"->
												(key->SubValues[s])
											}
									]
						}]
				]
			]
		},
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Index",
				"Data",
				"Functions.wdx"
				},
			Compress@functions
			];
		]


(* ::Subsubsection::Closed:: *)
(*Groups Index*)



dataPacletGroupsIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	With[{
		groups=
			Replace[entityStore["EntityClasses"],{
				l_List:>
					Normal[Keys/@l],
				_->{}
				}]
		},
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Index",
				"Data",
				"Groups.wdx"
				},
			Compress@groups
			];
		]


(* ::Subsubsection::Closed:: *)
(*PrivateGroups Index*)



dataPacletPrivateGroupsIndexFile[
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	Export[
		FileNameJoin@{
			Replace[dir,
				Automatic:>
					$TemporaryDirectory
				],
			StringTrim[dataType,"Data"]<>"Data_Index",
			"Data",
			"PrivateGroups.wdx"
			},
		Compress@{}
		];


(* ::Subsubsection::Closed:: *)
(*Data File*)



dataPacletDataFile[
	n:_Integer:1,
	dir_,
	dataType_String,
	entityStore_Association
	]:=
	With[{
		ents=
			{
				"Keys"->
					Keys@entityStore["Entities"],
				"Properties"->
					Thread@List@
						DeleteCases["Label"]@
							Keys@entityStore["Properties"],
				"Data"->
					Map[
						Replace[
							Lookup[
								Replace[#,f_File?FileExistsQ:>Import[f]],
								DeleteCases["Label"]@
									Keys@entityStore["Properties"]
								],
							_Missing->Missing["NotAvailable"],
							1]&,
						entityStore["Entities"]
						],
				"Attributes"->
					{
						"CreationDate"->DateList[],
						"Signature"->228610809693471781814095222429607185306
						}
				}
		},
		Quiet@
			CreateDirectory@
				FileNameJoin@{
					Replace[dir,
						Automatic:>
							$TemporaryDirectory
						],
					StringTrim[dataType,"Data"]<>"Data_Part"<>	
						StringPadLeft[ToString@n,2,"0"],
					"Data"
					};
		Export[
			FileNameJoin@{
				Replace[dir,
					Automatic:>
						$TemporaryDirectory
					],
				StringTrim[dataType,"Data"]<>"Data_Part"<>StringPadLeft[ToString@n,2,"0"],
				"Data",
				"Part"<>dataPacletIndexNumber[n]<>".wdx"
				},
			ents,
			"DataTable"
			];
		];


(* ::Subsubsection::Closed:: *)
(*Data Partitioning*)



dataPartition[data_,max_]:=
	Block[{
		d=data
		},
		Part[d,#]&/@
			basicPartition[ByteCount/@data,max]
		]


basicPartition[byteCounts_,max_]:=
	Block[{
			(*
			Basic chunking sysetm that tries to get part sizes as close to max 
				while maximizing the number of chunks in a given grouping
			*)
			counts=byteCounts,total,
			rightIndex,leftIndex,
			indexMoverLeft,indexMoverRight,
			ordering,chunks(*,
			step=1*)
			},
		ordering=Ordering@counts;
		counts=counts[[ordering]];
		rightIndex=
			First@
				FirstPosition[counts,
					Integer?(GreaterThan[max]),
					{Length@counts},
					{1}];
		leftIndex=1;
		If[rightIndex<Length@counts,
			chunks=Thread[{Take[ordering,{rightIndex+1,-1}]}],
			chunks={}
			];
		While[leftIndex<rightIndex(*&&step<2*Length@counts*),
			(*step++;*)
			total=counts[[rightIndex]];
			indexMoverRight=rightIndex;
			While[total<=max&&indexMoverRight>=leftIndex,
				indexMoverRight--;
				total+=counts[[indexMoverRight]]
				];
			indexMoverRight++;
			total-=counts[[indexMoverRight]];
			
			If[leftIndex==indexMoverRight,
				AppendTo[chunks,{{leftIndex,rightIndex}}];
				leftIndex=rightIndex,
				
				If[total+counts[[leftIndex]]>max,
					AppendTo[chunks,
						{
							{indexMoverRight,rightIndex}
							}
						];
					rightIndex=indexMoverRight-1,
					
					indexMoverLeft=leftIndex;
					While[total<=max&&indexMoverLeft<=indexMoverRight,
						indexMoverLeft++;
						total+=counts[[indexMoverLeft]]
						];
					indexMoverLeft--;
					AppendTo[chunks,
						{
							{leftIndex,indexMoverLeft},
							{indexMoverRight,rightIndex}
							}
						];
					rightIndex=indexMoverRight-1;
					leftIndex=indexMoverLeft+1;
					];
				If[rightIndex==leftIndex,AppendTo[chunks,{{leftIndex,leftIndex}}]]
				]
			];
		Apply[Join]@*Map[Take[ordering,#]&]/@chunks
		]


(* ::Subsubsection::Closed:: *)
(*Main*)



CuratedDataIndexPaclet[
	dir:_String?DirectoryQ|Automatic:Automatic,
	dataType_String,
	entityStore_Association,
	pack:True|False:True
	]:=
	CompoundExpression[
		Begin["DataPaclets`CuratedDataFormattingDump`"],
		(End[];#)&@
		CheckAbort[
			Block[{
				partitions=
					Map[
						ReplacePart[entityStore,
							"Entities"->
								Association@#
							]&
						]@
						dataPartition[
							Normal@entityStore["Entities"],
							5*10^7
							],
				$dataPacletPartitionNumber
				},
				$dataPacletPartitionNumber=
					Max@{
						Length@IntegerDigits@Length@partitions,
						2
						};
				(* ------- Prep Directories  ------- *)
				Quiet@
					CreateDirectory[
						FileNameJoin@{
							Replace[dir,	
								Automatic:>
									$TemporaryDirectory
								],
							StringTrim[dataType,"Data"]<>"Data_Index",
							"Data"
							},
						CreateIntermediateDirectories->True
						];
				(* ------- Indices -------*)
				dataPacletIndexFile[
					dir,
					dataType,
					partitions
					];
				dataPacletNamesIndexFile[dir,dataType,entityStore];
				dataPacletEntitiesIndexFile[dir,dataType,entityStore];
				dataPacletPropertiesIndexFile[dir,dataType,entityStore];
				dataPacletFunctionsIndexFile[dir,dataType,entityStore];
				dataPacletGroupsIndexFile[dir,dataType,entityStore];
				dataPacletPrivateGroupsIndexFile[dir,dataType,entityStore];
				(* ------- Data ------- *)
				MapIndexed[
					Function[
						Quiet@
							CreateDirectory[
								FileNameJoin@{
									Replace[dir,	
										Automatic:>
											$TemporaryDirectory
										],
									StringTrim[dataType,"Data"]<>
										"Data_Part"<>
											dataPacletIndexNumber[#2],
									"Data"
									},
								CreateIntermediateDirectories->True
								];
						dataPacletDataFile[First@#2,
							dir,
							StringTrim[dataType,"Data"],
							#
							]
						],
					partitions
					];
				(* ------- Paclets  ------- *)
				If[pack,
					Quiet@
						PacletExpressionBundle[
							FileNameJoin@{
								Replace[dir,
									Automatic:>
										$TemporaryDirectory
									],
								StringTrim[dataType,"Data"]<>"Data_Index"
								},
							"Version"->$dataPacletVersionNumber
							];
					Map[
						Quiet@
							PacletExpressionBundle[
								FileNameJoin@{
									Replace[dir,
										Automatic:>
											$TemporaryDirectory
										],
									StringTrim[dataType,"Data"]<>"Data_Part"<>
										dataPacletIndexNumber[#]
									},
								"Version"->
									$dataPacletVersionNumber
								]&,
						Range[Length@partitions]
						];
					AssociationMap[
						PacletBundle@
							FileNameJoin@{
								Replace[dir,
									Automatic:>
										$TemporaryDirectory
									],
								StringTrim[dataType,"Data"]<>"Data_"<>#
								}&,
						Flatten@{
							"Index",
							Map[
								"Part"<>dataPacletIndexNumber[#]&,
								Range[Length@partitions]
								]
							}],
					<|
						"Index"->
							FileNameJoin@{
								Replace[dir,
									Automatic:>
										$TemporaryDirectory
									],
								StringTrim[dataType,"Data"]<>"Data_Index"
								},
						"Data"->
							Map[
								FileNameJoin@{
									Replace[dir,
										Automatic:>
											$TemporaryDirectory
										],
									StringTrim[dataType,"Data"]<>"Data_Part"<>dataPacletIndexNumber[#]
									}&,
								Range[Length@partitions]
								]
						|>
					]
				],
			End[]
			]
		];


(* ::Subsubsection::Closed:: *)
(*Package*)



$CuratedDataPackageTemplate:=
	Import[
		PackageFilePath[
			"Templates",
			"CuratedData",
			"$CuratedData.m"
			],
		"Text"
		];


CuratedDataPaclet[
	dir:_String?DirectoryQ|Automatic:Automatic,
	dataType_String,
	entityStore_Association,
	pack:True|False:True,
	ops:(_String->_String)...,
	pacletInfo:_List?OptionQ:{}
	]:=
	With[{
		file=
			With[{d=
				FileNameJoin@{
					Replace[dir,
						Automatic:>
							$TemporaryDirectory
						],
					StringTrim[dataType,"Data"]<>"Data"
					}
				},
				Quiet@
					CreateDirectory[
						FileNameJoin@{d,"AutoCompletionData"},
						CreateIntermediateDirectories->True
						];
				FileNameJoin@{
					d,
					StringTrim[dataType,"Data"]<>"Data.m"
					}
				]
		},
			(* --------- Package --------- *)
			With[{fob=OpenWrite@file},
				(WriteString[fob,#];Close@fob)&@
					StringReplace[$CuratedDataPackageTemplate,{
						ops,
						"$CuratedDataProperties"->
							ToString[
								DeleteCases["Label"]@
									Keys@entityStore["Properties"],
								InputForm
								],
						"$CuratedDataLabelFunction"->
							ToString[
								Replace[
									Lookup[
										Lookup[
											entityStore["Properties"],
											"Label",
											<||>
											],
										"DefaultFunction"
										],{
									_Missing|CommonName->CanonicalName
									}],
								InputForm
								],
						"$CuratedDataDefaultProperty"->
							ToString[
								Lookup[
									entityStore,
									"DefaultProperty",
									"Entity"
									],
								InputForm
								],
						"$CuratedDataType"->dataType,
						"$CuratedData"->StringTrim[dataType,"Data"]<>"Data"
						}
					]
				];
				
			(* --------- Autocompletions --------- *)
			Export[
				FileNameJoin@{
					Replace[dir,
						Automatic:>
							$TemporaryDirectory
						],
					StringTrim[dataType,"Data"]<>"Data",
					"AutoCompletionData",
					"specialArgFunctions.tr"
					},
				StringReplace[
					Import[
						PackageFilePath[
							"Templates",
							"CuratedData",
							"$CuratedDataCompletions.tr"
							],
						"Text"
						],
					{
						"$CuratedDataEntities"->
							ToString[
								Function[
									DeleteDuplicates@
										Join[
											Map[First@StringSplit[#,"::"]&,#],
											#]
									]@
									SortBy[
										Keys@entityStore["Entities"],
										StringLength
										],
								InputForm
								],
						"$CuratedDataProperties"->
							ToString[
								SortBy[
									DeleteCases["Label"]@
										Keys@entityStore["Properties"],
									StringLength
									],
								InputForm
								],
						"$CuratedData"->StringTrim[dataType,"Data"]<>"Data"
						}],
				"Text"
				];
			If[pack,
				(
					PacletExpressionBundle[#,
						Flatten@{
							pacletInfo,
							"Version"->$dataPacletVersionNumber
							}
						];
					PacletBundle[#]
					)&@
					FileNameJoin@{
						Replace[dir,
							Automatic:>
								$TemporaryDirectory
							],
						StringTrim[dataType,"Data"]<>"Data"
						},
				FileNameJoin@{
						Replace[dir,
							Automatic:>
								$TemporaryDirectory
							],
						StringTrim[dataType,"Data"]<>"Data"
						}
				]
		]


(* ::Subsubsection::Closed:: *)
(*Wrapper*)



$CuratedDataWrapperPackageTemplate:=
	Import[
		PackageFilePath[
			"Templates",
			"CuratedData",
			"$CuratedDataWrapper.m"],
		"Text"
		];


CuratedDataWrapperPaclet[
	dir:_String?DirectoryQ|Automatic:Automatic,
	dataType_String,
	dataFunctions_Association,
	pack:True|False:True,
	ops:(_String->_String)...,
	pacletInfo:_List?OptionQ:{}
	]:=
	With[{
		file=
			With[{d=
				FileNameJoin@{
					Replace[dir,
						Automatic:>
							$TemporaryDirectory
						],
					StringTrim[dataType,"Data"]<>"Data"
					}
				},
				Quiet@
					CreateDirectory[
						FileNameJoin@{d,"AutoCompletionData"},
						CreateIntermediateDirectories->True
						];
				FileNameJoin@{
					d,
					StringTrim[dataType,"Data"]<>"Data.m"
					}
				]
		},
			(* --------- Package --------- *)
			With[{fob=OpenWrite@file},
				(WriteString[fob,#];Close@fob)&@
					StringReplace[$CuratedDataWrapperPackageTemplate,{
						ops,
						"$CuratedDataFunctions"->
							Block[{$Context="System`",$ContextPath={"System`"}},
								ToString[
									dataFunctions,
									InputForm
									]
								],
						"$CuratedDataType"->dataType,
						"$CuratedData"->StringTrim[dataType,"Data"]<>"Data"
						}
					]
				];
				
			(* --------- Autocompletions --------- *)
			Export[
				FileNameJoin@{
					Replace[dir,
						Automatic:>
							$TemporaryDirectory
						],
					StringTrim[dataType,"Data"]<>"Data",
					"AutoCompletionData",
					"specialArgFunctions.tr"
					},
				StringReplace[
					Import[
						PackageFilePath[
							"Templates",
							"CuratedData",
							"$CuratedDataCompletions.tr"
							],
						"Text"
						],
					{
						"$CuratedDataEntities"->
							ToString[
								Keys@dataFunctions,
								InputForm
								],
						"$CuratedData"->StringTrim[dataType,"Data"]<>"Data"
						}],
				"Text"
				];
			If[pack,
				(
					PacletExpressionBundle[#,
						Flatten@{
							pacletInfo,
							"Version"->$dataPacletVersionNumber
							}];
					PacletBundle[#]
					)&@
					FileNameJoin@{
						Replace[dir,
							Automatic:>
								$TemporaryDirectory
							],
						StringTrim[dataType,"Data"]<>"Data"
						},
				FileNameJoin@{
						Replace[dir,
							Automatic:>
								$TemporaryDirectory
							],
						StringTrim[dataType,"Data"]<>"Data"
						}
				]
		]


(* ::Subsubsection::Closed:: *)
(*Export*)



Options[CuratedDataExport]=
	Options@PacletExpressionBundle;
CuratedDataExport[
	dir:_String?DirectoryQ|Automatic:Automatic,
	dataType_String,
	entityStore:_Association?(
		Function[a,AllTrue[{"Entities","Properties"},KeyMemberQ[a,#]&]]
		),
	pack:True|False:True,
	ops:OptionsPattern[]
	]:=
	Block[{
		$dataPacletVersionNumber=
			Replace[OptionValue["Version"],Except[_String]->$dataPacletVersionNumber]
			},
	 Prepend[
	 	"Package"->
	 		CuratedDataPaclet[dir,
	 			dataType,
	 			entityStore,
	 			pack,
	 			"$CuratedDataDefaultProperty"->
	 				Lookup[entityStore,
	 					"DefaultProperty",
	 					(*First@DeleteCases["Label"]@
	 						Keys@entityStore["Properties"]*)
	 					"Entity"
	 					],
	 			{ops}
	 			]
	 		]@
		 	CuratedDataIndexPaclet[dir,
		 		dataType,
		 		entityStore,
		 		pack
		 		]
		];
CuratedDataExport[
	dir:_String?DirectoryQ|Automatic:Automatic,
	name:_String|None:None,
	datasets_Association?(
		AllTrue[Values@#,
			With[{a=#},
				AllTrue[{"Entities","Properties"},
					KeyMemberQ[a,#]&
					]
				]&
			]&),
	pack:True|False:True,
	ops:OptionsPattern[]
	]:=
	Block[{
		$dataPacletVersionNumber=
			Replace[OptionValue["Version"],Except[_String]->$dataPacletVersionNumber]
			},
		If[name===None,
			Identity,
			Prepend[
				name->
					CuratedDataWrapperPaclet[dir,
						name,
						AssociationThread[
							StringTrim[
								Replace[Keys@datasets,
									s_Symbol:>SymbolName[s],
									1
									],
								name
								],
							Replace[Keys@datasets,
								s_String:>
									ToExpression[
										StringTrim[s,"Data"]<>"Data"<>"`"<>
											StringTrim[s,"Data"]<>"Data"],
								1
								]
							],
						pack,
						{ops}
						]
				]
			]@
			Association@
				KeyValueMap[
					#->
						CuratedDataExport[dir,#,#2,pack]&,
					datasets
					]
		];
CuratedDataExport[
	dir:_String?DirectoryQ|Automatic:Automatic,
	name:_String|None:None,
	entityStore_EntityStore,
	pack:True|False:True,
	ops:OptionsPattern[]
	]:=
	CuratedDataExport[
		dir,
		name,
		entityStore[[1,"Types"]],
		pack,
		ops
		];


End[];



