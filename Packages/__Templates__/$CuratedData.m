(* ::Package:: *)

$packageHeader

BeginPackage["$CuratedData`"];


$CuratedData::usage=
	"An interface to the DataPaclets interface, akin to $CuratedData";


Begin["DataPaclets`$CuratedDataDump`"];


If[!TrueQ@$pacletUpdated,
	PacletUpdate["$CuratedDataType_Index"];
	$pacletUpdated=True
	];


(* ::Subsection:: *)
(*Initialize*)



(* ::Subsubsection::Closed:: *)
(*$Groups / $GroupHash / $PrivateGroups*)



Initialize[
	sym:
		$Groups|
		$GroupHash|
		$PrivateGroups
	]:=
	DataPaclets`ProtectInitialization[
		Module[{nb,temp,wdx},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Groups.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]
				];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			temp=
				Uncompress[
					DataPaclets`ImportData[
						"$CuratedData_Index",
						wdx,
						{"WDX","Expression"}
						]
					];
			AbortProtect[
				Clear[$Groups,$GroupHash,$PrivateGroups];
				Scan[($GroupHash[First[#1]]=Last[#1])&,temp];
				$Groups=temp[[All,1]];
				wdx=
					DataPaclets`GetDataPacletResource[
						"$CuratedData_Index",
						"PrivateGroups.wdx"
						];
				If[wdx===$Failed,
					Throw[$Failed,"DataPacletException"]
					];
				temp=
					Uncompress[
						DataPaclets`ImportData[
							"$CuratedData_Index",
							wdx,
							{"WDX","Expression"}
							]
						];
				Scan[($GroupHash[First[#1]]=Last[#1])&,temp];
				$PrivateGroups=temp[[All,1]];
				DataPaclets`DeleteInitializationStatus[nb];
				sym
				]
			],
		Clear[$Groups,$PrivateGroups,$GroupHash];
		$Groups:=
			Initialize[$Groups];
		$PrivateGroups:=
			Initialize[$PrivateGroups];
		$GroupHash:=
			Initialize[$GroupHash];
		DataPaclets`ClearInitializationStatus[];
		]


(* ::Subsubsection::Closed:: *)
(*Sources*)



Initialize[
	sym:
		$KeySource|
		$Keys|
		$SubgroupToGroup|
		$PropertyHash|
		$CompiledProperties|
		$SourceGroups
	]:=
	DataPaclets`ProtectInitialization[
		Module[{
			nb,srcs,
			props,bag,
			sbag=Internal`Bag[],
			gbag=Internal`Bag[],
			wdx
			},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Index.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			{srcs,props}=
				{"Sources","Properties"}/. 
					DataPaclets`ImportData[
						"$CuratedData_Index",
						wdx,
						{"WDX","DataIndex"}
						];
			AbortProtect[
				Clear[
					$SourceGroups,
					$Keys,
					$PropertyHash,
					$CompiledProperties,
					$KeySource,
					$SubgroupToGroup
					];
			(Module[{srcgroup=First[#1],subgroups=Last[#1]},
				bag=Internal`Bag[];
				(
					Module[{srcsubgroup=First[#1],keys=Last[#1]},
						Internal`StuffBag[bag,keys,1];
						Scan[($KeySource[#1]=srcsubgroup)&,keys];
						Internal`StuffBag[gbag,srcsubgroup->srcgroup];
						]&
					)/@subgroups;
					$Keys[srcgroup]=
						Internal`BagPart[bag,All];
					Clear[bag];
					]&
				)/@srcs;
			$KeySource[___]=$Failed;
			Internal`StuffBag[gbag,_->$Failed];
			$SubgroupToGroup=
				Dispatch[Internal`BagPart[gbag,All]];
			Clear[sbag,gbag];
			($PropertyHash[First[#1]]=
				Dispatch[Thread[Last[#1]->Range@Length@Last@#1]]
				)&/@props;
			($CompiledProperties[First[#1]]=Last[#1])&/@props;
			$SourceGroups=
				srcs[[All,1]];
			DataPaclets`DeleteInitializationStatus[nb];
			sym
			]
		],
		Clear[
			$SourceGroups,
			$Keys,
			$PropertyHash,
			$CompiledProperties,
			$KeySource,
			$SubgroupToGroup
			];
		$SourceGroups:=
			Initialize[$SourceGroups];
		$Keys:=
			Initialize[$Keys];
		$PropertyHash:=
			Initialize[$PropertyHash];
		$CompiledProperties:=
			Initialize[$CompiledProperties];
		$KeySource:=
			Initialize[$KeySource];
		$SubgroupToGroup:=
			Initialize[$SubgroupToGroup];
		DataPaclets`ClearInitializationStatus[];
		]


(* ::Subsubsection::Closed:: *)
(*$StandardName*)



Initialize[sym:$StandardName]:=
	DataPaclets`ProtectInitialization[
		Module[{nb,snames,wdx},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Names.wdx"];
			If[wdx===$Failed,Throw[$Failed,"DataPacletException"]];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			snames=
				DataPaclets`ImportData["$CuratedData_Index",wdx,"Expression"];
			AbortProtect[
				Clear[$StandardName];
				(Module[{key=First[#1],names=Last[#1]},
						Scan[($StandardName[#1]=key)&,names];
						]&)/@
					snames;
					$StandardName[___]=$Failed;
					DataPaclets`DeleteInitializationStatus[nb];
					sym]
			],
		Clear[$StandardName];
		$StandardName:=Initialize[$StandardName];
		DataPaclets`ClearInitializationStatus[];
		];


(* ::Subsubsection::Closed:: *)
(*$Entities / $EntityHash*)



Initialize[sym:$Entities|$EntityHash]:=
	DataPaclets`ProtectInitialization[
		Module[{nb,temp,wdx},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Entities.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]
				];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			temp=
				Uncompress[
					DataPaclets`ImportData["$CuratedData_Index",wdx,"Expression"]
					];
			AbortProtect[
				Clear[$Entities,$EntityHash];
				Scan[($EntityHash[First[#1]]=Last[#1])&,temp];
				$Entities=temp[[All,2]];
				DataPaclets`DeleteInitializationStatus[nb];
				sym
				]
			],
		Clear[$Entities,$EntityHash];
		$Entities:=
			Initialize[$Entities];
		$EntityHash:=
			Initialize[$EntityHash];
		DataPaclets`ClearInitializationStatus[];
		]


(* ::Subsubsection::Closed:: *)
(*$Properties*)



Initialize[sym:$Properties]:=
	DataPaclets`ProtectInitialization[
		Module[{
			nb,
			temp,
			wdx
			},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Properties.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]
				];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			temp=
			Uncompress[
				DataPaclets`ImportData[
					"$CuratedData_Index",
					wdx,
					{"WDX","Expression"}]
				];
			AbortProtect[	
				Clear[$Properties];
				Scan[($Properties[First[#1]]=Last[#1])&,
					temp];
				DataPaclets`DeleteInitializationStatus[nb];
				sym
				]
			],
		Clear[$Properties];
		$Properties:=
			Initialize[$Properties];
		DataPaclets`ClearInitializationStatus[];
		]


(* ::Subsubsection::Closed:: *)
(*ComputeFunction*)



Initialize[sym:ComputeFunction]:=
	DataPaclets`ProtectInitialization[
		Module[{nb,wdx,funcs,helpers},
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Properties.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]
				];
			nb=
				DataPaclets`PrintInitializationStatus["$CuratedData"];
			wdx=
				DataPaclets`GetDataPacletResource["$CuratedData_Index","Functions.wdx"];
			If[wdx===$Failed,
				Throw[$Failed,"DataPacletException"]
				];
			{funcs,helpers}=
				{"Primary","Helpers"}/. 
					Uncompress[
						DataPaclets`ImportData[
							"$CuratedData_Index",
							wdx
							]
						];
			AbortProtect[Clear[ComputeFunction];
				DownValues[ComputeFunction]=
					funcs;
				Apply[
					(DownValues[#1]=#2)&,
					"DownValues"/. helpers,
					{1}];
				Apply[
					(OwnValues[#1]=#2)&,
					"OwnValues"/. helpers,
					{1}];
				DataPaclets`DeleteInitializationStatus[nb];
				sym]
			],
			Clear[ComputeFunction];
			ComputeFunction:=
				Initialize[
					ComputeFunction
					];
			DataPaclets`ClearInitializationStatus[];
		]


(* ::Subsubsection::Closed:: *)
(*Attributes*)



Initialize~SetAttributes~HoldFirst;


(* ::Subsection:: *)
(*$CuratedData*)



(* ::Subsubsection::Closed:: *)
(*Install*)



$CuratedData[__,"Install"]:=
	Module[
		{
				wdx,
				srcs
			},
		wdx=
			DataPaclets`GetDataPacletResource["$CuratedData_Index","Index.wdx"];
		If[wdx===$Failed,
			Return[$Failed]
			];
		srcs=
			"Sources"/.
			 	DataPaclets`ImportData[
					"$CuratedData_Index",
					wdx,
					{"WDX","DataIndex"}
					];
		(
			Module[{subgroups=Last[#1]},(
				Module[{srcsubgroup=First[#1]},
					DataPaclets`GetDataPacletResource[
						"$CuratedData_"<>srcsubgroup,
						srcsubgroup<>".wdx"
						];
					]&)/@
					subgroups;
					]&
			)/@
			srcs;
			True]


(* ::Subsubsection::Closed:: *)
(*Preload*)



$CuratedData[__,"Preload"]:=
	Catch[
		$KeySource;
		$Groups;
		$Entities;
		$StandardName;
		$Properties;
		ComputeFunction;
		Scan[
			With[{group=#1},
				Scan[
					With[{subgroup=#1},
						$Index[subgroup]
						]&,
					Cases[$SubgroupToGroup,
						HoldPattern[
							s_String->
								group
							]:>
								s,
						\[Infinity]]
					];
				]&,
			$SourceGroups];
			True,
	"DataPacletException"
	]


(* ::Subsubsection::Closed:: *)
(*Get*)



$CuratedData[]:=$CuratedData[All]


$CuratedData["DefaultProperty"]=
	"$CuratedDataDefaultProperty";


$CuratedData["Properties"]:=
	Catch[
		Sort[
			DeleteCases[
				Union[
					First/@
						Flatten[
							$Properties/@
								$SourceGroups,
							1]
					],
				_Blank|_BlankSequence|_BlankNullSequence
				]
			],
		"DataPacletException"
		]


$CuratedData[All,"Properties"]:=
	$CuratedData["Properties"]


($CuratedData[All]/;DataPaclets`$WrapperFlag=!=True):=
	Block[{DataPaclets`$WrapperFlag=True},
		DataPaclets`WrapperizePacletRequest[$CuratedData,All,None]
		]


$CuratedData[all:All]:=
	Catch[$Entities,"DataPacletException"]


HoldPattern[$CuratedData["Classes"|"Groups"]]:=
	If[DataPaclets`$WrapperFlag=!=True,
		Block[{DataPaclets`$WrapperFlag=True},
			DataPaclets`WrapperizePacletRequest[$CuratedData,"Groups","HandleGroupRequest"]
			],
		Catch[$Groups,"DataPacletException"]
		]


(* ::Subsubsection::Closed:: *)
(*Entities*)



$CuratedData[
	Entity["$CuratedDataType",obj_],
	args___]:=
	$CuratedData[
		obj,
		args
		];


$CuratedData[
	EntityClass["$CuratedDataType",obj_],
	args___]:=
	$CuratedData[
		obj,
		args
		];


$CuratedData[
	arg_,
	EntityProperty["$CuratedDataType",prop_String],
	args___]:=
	$CuratedData[
		arg,
		prop,
		args
		];


(* ::Subsubsection::Closed:: *)
(*Lookup*)



$CuratedData[obj_]/;(DataPaclets`$WrapperFlag=!=True):=
	Block[{DataPaclets`$WrapperFlag=True},
		DataPaclets`WrapperizePacletRequest[
			$CuratedData,
			obj,
			None]
		];


$CuratedData[obj_List]:=
	$CuratedData[#]&/@obj;
$CuratedData[obj:Except[_List]]:=
	Module[{
		allowOutput=True,
		output,
		val},
		output=
			Catch[
				Which[
					StandardNameQ[obj],
						$CuratedData[obj,$CuratedData["DefaultProperty"]],
					GroupQ[obj],
						$EntityHash/@$GroupHash[obj],
					MatchQ[obj,
						_StringExpression|_RegularExpression|
						_String?(StringMatchQ[#1,___~~"\\*"~~___]&)
						],
						Module[{res,strs},
							strs=
								Cases[
									$EntityHash/@
										Flatten[($Keys[#1]&)/@$SourceGroups,1],
									_String];
							res=StringMatchQ[strs,obj];
							allowOutput=ListQ[res];
							If[ListQ[res],Pick[strs,res]]
							],
					Head[val=ComputeFunction[obj]]=!=ComputeFunction,
						val,
					True,
						Message[$CuratedData::notent,
							ToString[obj,InputForm],
							$CuratedData];
						allowOutput=False
					],
				"DataPacletException"
				];
		output/;allowOutput
		]


(* ::Subsubsection::Closed:: *)
(*Property*)



$CuratedData[obj_,prop_]/;(DataPaclets`$WrapperFlag=!=True):=
	Block[{DataPaclets`$WrapperFlag=True},
		DataPaclets`WrapperizePacletRequest[$CuratedData,obj,prop]
		]


$CuratedData[obj_List,prop__]:=
	$CuratedData[#,prop]&/@obj;
$CuratedData[obj_,prop_List]:=
	$CuratedData[obj,#]&/@prop;
$CuratedData[
	obj:Except[_List],
	prop__
	]:=
Module[
	{
		allowOutput=True,
		output,sn,
		val,subgroup,
		keys
		},
	output=
		Catch[
			Which[
				StandardNameQ[obj],
					sn=$StandardName[obj];
					Which[
						CompiledPropertyQ[sn,{prop}],
							subgroup=$KeySource[sn];
							If[(val=Internal`CheckCache[{"$CuratedData",sn,prop}])===$Failed,
								SetStreamPosition[
									$StreamCache[subgroup],
									$Index[subgroup][[
										$KeyHash[subgroup][sn]+
										({prop}/. 
											$PropertyHash[
												subgroup/. 
												$SubgroupToGroup])
										]]
									];
								val=
									System`Convert`WDXDump`readWDXObject[
										$StreamCache[subgroup]
										];
								Internal`SetCache[{"$CuratedData",sn,prop},val]
								];
							val,
						GroupQ[prop],
							MemberQ[$GroupHash[prop],Verbatim[sn],1],
						Head[val=
							internal$CuratedData[sn,prop]
							]=!=internal$CuratedData,
							val,
						Head[val=
							ComputeFunction[
								obj,
								prop
								]
							]=!=
							ComputeFunction,val,
						AnyPropertyQ[{prop}],
							Missing["NotApplicable"],
						FreeQ[
							val=
								DataPaclets`TryEntityValue["$CuratedDataType",obj,prop],
							$Failed
							],
							val,
						True,
							handlePropertyError[obj,prop];
							allowOutput=False
						],
				ValueQ[$EntityHash[obj]],
					sn=obj;
					Which[
						CompiledPropertyQ[sn,{prop}],
							subgroup=
								$KeySource[sn];
							If[
								(val=
									Internal`CheckCache[{"$CuratedData",sn,prop}])===$Failed,
								SetStreamPosition[
									$StreamCache[subgroup],
									$Index[subgroup][[$KeyHash[subgroup][sn]+
										ReplaceAll[
											{prop}/. 
												$PropertyHash[
													subgroup/. 
													$SubgroupToGroup
													]
											]
										]]
									];
								val=
									System`Convert`WDXDump`readWDXObject[$StreamCache[subgroup]];
									Internal`SetCache[{"$CuratedData",sn,prop},val]
								];
							val,
						Head[val=ComputeFunction[obj,prop]]=!=ComputeFunction,
							val,
						Head[val=
							ComputeFunction[
								$EntityHash[obj],
								prop]]=!=ComputeFunction,
							val],
				GroupQ[obj],
					Which[
						GroupQ[prop],
							keys=
								$EntityHash/@
									$GroupHash[obj];
							($CuratedData[#1,prop]&)/@keys,
						AnyPropertyQ[{prop}],
							keys=
								$EntityHash/@$GroupHash[obj];
						Quiet[
							($CuratedData[#1,prop]&)/@
								keys/. 
								$CuratedData[___]->Missing["NotApplicable"]
							],
							{prop}==={"Properties"},
							keys=
								$EntityHash/@
									$GroupHash[obj];
						Sort[
							Quiet[
								Union@@($CuratedData[#1,"Properties"]&)/@keys
								]
							],
							Last[{prop}]==="Properties"&&
						AnyPropertyQ[Most[{prop}]],
							keys=
								$EntityHash/@
									$GroupHash[obj];
							Sort@
								Quiet[
									Union@@
										(
											$CuratedData[#1,
												Sequence@@Most[{prop}],
												"Properties"]&
											)/@keys
									],
						FreeQ[
							val=
								DataPaclets`TryEntityValue["$CuratedDataType",obj,prop],
							$Failed],
							val,
						True,
							handlePropertyError[obj,prop];
							allowOutput=False
						],
				Head[val=ComputeFunction[obj,prop]]=!=ComputeFunction,
					val,
				FreeQ[val=DataPaclets`TryEntityValue["$CuratedDataType",obj,prop],$Failed],
					val,
				True,
					Message[
						$CuratedData::notent,ToString[obj,InputForm],
						$CuratedData
						];
				allowOutput=False
				],
		"DataPacletException"
		];
	output/;allowOutput]


(* ::Subsection:: *)
(*Helper Definitions*)



(* ::Text:: *)
(*A collection of helper definitions that are used in the primary code*)



(* ::Subsubsection::Closed:: *)
(*handlePropertyError*)



handlePropertyError[
	obj_,
	prop__,
	subprop_
	]:=
Message[
	$CuratedData::notsubprop,
	ToString[subprop,InputForm],
	$CuratedData
	]/;
		AnyPropertyQ[{prop}]&&
		!AnyPropertyQ[{
				prop,
				subprop
				}]


handlePropertyError[
	obj_,
	prop_,
	___
	]:=
	Message[
		$CuratedData::notprop,
		ToString[prop,InputForm],
		$CuratedData
		]/;
		!AnyPropertyQ[{prop}]


AnyPropertyQ[prop_]:=
	MemberQ[
		Union[
			Join@@
				$Properties/@
					$SourceGroups
			],
		Verbatim[prop],
		1]


(* ::Subsubsection::Closed:: *)
(**Q*)



StandardNameQ[name_]:=
	($StandardName[name]=!=$Failed)


GroupQ[grp__]:=
	(ListQ[$GroupHash[grp]])


FileQ[file_String]:=
	(FileType/. FileInformation[file])===File


KeyQ[key_]:=
	($KeySource[key]=!=$Failed)


PropertyQ[key_,prop_]:=(
	MemberQ[
		$Properties[$KeySource[key]/. $SubgroupToGroup],
		Verbatim[prop],
		1]
	)


CompiledPropertyQ[key_,prop_]:=(
	IntegerQ[prop/. $PropertyHash[$KeySource[key]/. $SubgroupToGroup]]/;
		KeyQ[key]
	)


(* ::Subsubsection::Closed:: *)
(*internal*)



internal$CuratedData[key_,"Properties"]:=
	Sort[
		Union[
			First/@
			$Properties[
				$KeySource[key]/. 
				$SubgroupToGroup
				]
			]
		]


internal$CuratedData[
	key_,
	prop__,
	"Properties"]:=
	Sort[
		Union[
			Cases[$Properties[$KeySource[key]/. $SubgroupToGroup],{
					prop,
					subprop_,
					___
					}:>subprop]
			]
		]/;
		PropertyQ[
			key,
			{prop}
			];


internal$CuratedData[key_,prop__,"Value"]:=
	$CuratedData[key,prop]/;PropertyQ[key,{prop}];
internal$CuratedData[entprop__,what:"UnitsName"|"UnitsNotation"]:=
	Module[{unit},
		unit=$CuratedData[entprop,"Units"];
		DataPaclets`UnitData[unit,what]/;StringQ[unit]
		];


internal$CuratedData[entprop__,"UnitsStandardName"]:=
	Module[{unit},
		unit=$CuratedData[entprop,"Units"];
		unit/;StringQ[unit]
		]


(* ::Subsubsection::Closed:: *)
(*$StreamCache*)



$StreamCache[f_]:=
	Module[{wdx},
		wdx=
			DataPaclets`GetDataPacletResource[
				"$CuratedData_"<>f,
				f<>".wdx"
				];
		If[wdx===$Failed,
			Throw[$Failed,"DataPacletException"]
			];
		$StreamCache[f]=
			OpenRead[wdx,BinaryFormat->True]
		];


(* ::Subsubsection::Closed:: *)
(*$Index*)



$Index[subgroup_]:=(
	$Index[subgroup]=
		Module[{idx,keys,temp},
			{idx,keys}=
				DataPaclets`ImportData[
					"PackageData_"<>subgroup,
					$StreamCache[subgroup],
					{"WDX","DataTable",{"Index","Keys"}}
					];
			{idx,keys};
			temp=
				Length@
					$CompiledProperties[subgroup/. $SubgroupToGroup];
			MapIndexed[
				($KeyHash[subgroup][#1]=(First[#2]-1) temp)&,
				keys
				];
			idx
			]
	)


(* ::Subsection:: *)
(*Loading*)



(* ::Subsubsection::Closed:: *)
(*DataPaclets Register*)



DataPaclets`CommonDump`PacletDispatchFunction[$CuratedData]=
	<|
		None->
			Function[
				data,
				DataPaclets`CommonDump`makeEntityorListOfEntitiesAsAppropriate[
					"$CuratedDataType",
					 data
					 ]
				]
		|>;


(* ::Subsubsection::Closed:: *)
(*Initialize*)



Map[
	Replace[Extract[#,1,Hold],
		Hold[s_]:>
			If[Length@OwnValues[s]===0,
				(s:=
					Initialize[s])
				]
		]&,
	Thread@
		Hold[{
				$Groups,
				$GroupHash,
				$PrivateGroups,
				$KeySource,
				$Keys,
				$SubgroupToGroup,
				$PropertyHash,
				$CompiledProperties,
				$SourceGroups,
				$StandardName,
				$Entities,
				$EntityHash,
				$Properties,
				ComputeFunction
			}]
	]


(* ::Subsubsection::Closed:: *)
(*EntityStore Register*)



If[$VersionNumber>=11,
	If[MissingQ@EntityFramework`FindEntityStore["$CuratedDataType"],
		Unprotect@Internal`$DefaultEntityStores;
		AppendTo[
			Internal`$DefaultEntityStores,
			With[{
				props=
					Join[
						<|
							"Label"-><|
								"DefaultFunction"->
									($CuratedDataLabelFunction)
								|>
							|>,
						AssociationMap[
							<|
								"DefaultFunction"->
									EntityFramework`BatchApplied[
										Function[ents,
											$CuratedData[ents,#]
											]
										]
								|>&,
							$CuratedDataProperties
							]
						]
				},
				EntityStore[
					"$CuratedDataType"->
						<|
							"EntityValidationFunction"->(True&),
							"Properties"->props
							|>
					]
				]
			];
		Protect@Internal`$DefaultEntityStores
		],
	EntityFramework`EntityValueCacheAdd[
		EntityClass["EntityType",All], 
		"Entities",
		EntityFramework`EntityValueCache[
			EntityClass["EntityType",All],
			Entity["EntityType",""]
			]
		]
	]


End[];


EndPackage[];



