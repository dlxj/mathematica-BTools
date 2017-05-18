(* ::Package:: *)


(* ::Title:: *)
(*PackageIndex Package*)

(* ::Text::GrayLevel[.5]:: *)
(*Autogenerated BTools package*)

EncodedCache::usage=
	"An object representing an encoded Association";
EncodedCacheLoad::usage=
	"Loads an EncodedCache from a directory";


$EncodedCache::usage=
	"An interface object for the default cache";
$EncodedCacheSettings::usage=
	"An interface object for the options of the default cache";
$EncodedCachePassword::usage=
	"An interface object for the password of the default cache";
$EncodedCacheDirectory::usage=
	"A settable directory to change where the $EncodedCache loads from";


KeyChainAdd::usage=
	"Adds auth data to the KeyChain";
KeyChainGet::usage=
	"Gets auth data from the KeyChain";


$KeyChain::usage=
	"An interface object to a password keychain";
$KeyChainSettings::usage=
	"An interface object for the options of the keychain";
$KeyChainPassword::usage=
	"An interface object for the password of the keychain";
$KeyChainDirectory::usage=
	"A settable directory to change where the $KeyChain loads from";


Begin["`Private`"];


$EncodedCacheDefaultOptions=
	<|
		"SaveOptionsToDisk"->
			True,
		"UsePassword"->
			True,
		"StorePasswordInMemory"->
			True,
		"SavePasswordToDisk"->
			False,
		"StoreInMemory"->
			True,
		"SaveToDisk"->
			True,
		"Persistent"->
			True,
		"PersistenceBase"->
			FileName[{
				$UserBaseDirectory,
				"ApplicationData",
				"EncodedCache"
				}],
		"TemporaryBase"->
			FileName[{
				$TemporaryDirectory,
				"EncodedCache"
				}],
		"CacheName"->
			"Cache"
		|>;


If[!AssociationQ@$EncodedCacheOptions,
	$EncodedCacheOptions=<||>
	];


EncodedCacheOption[spec_?StringQ,option_]:=
	Lookup[
		Lookup[$EncodedCacheOptions,
			spec,
			Lookup[$EncodedCacheOptions,
				"Default",
				$EncodedCacheOptions["Default"]=$EncodedCacheDefaultOptions
				]
			],
		option,
		Lookup[$EncodedCacheOptions["Default"],option]
		];


EncodedCacheOption/:
	Set[EncodedCacheOption[spec_?StringQ,option_],value_]:=
		(
			If[!KeyMemberQ[$EncodedCacheOptions,spec],
				$EncodedCacheOptions[spec]=<||>
				];
			If[value===Inherited,
				$EncodedCacheOptions[spec,option]=.,
				$EncodedCacheOptions[spec,option]=value
				];
			If[EncodedCacheOption[spec,"SaveOptionsToDisk"],
				EncodedCacheOptionsExport[spec]
				];
			value
			);
EncodedCacheOption/:
	Unset[EncodedCacheOption[spec_?StringQ]]:=(
		$EncodedCacheOptions[spec]=.;
		If[EncodedCacheOption[spec,"SaveOptionsToDisk"],
			EncodedCacheOptionsExport[spec]
			];
		);


EncodedCacheOptionsFile[spec_?StringQ]:=
	FileNameJoin@Flatten@
		Replace[
			{
				If[EncodedCacheOption[spec,"Persistent"],
					EncodedCacheOption[spec,"PersistenceBase"],
					EncodedCacheOption[spec,"TemporaryBase"]
					],
				spec,
				spec<>".m"
				},
			FileName[f_]:>f,
			1
			];
EncodedCacheOptionsLoad[file_?FileExistsQ]:=
	Replace[
		Quiet@
			Import@
				If[DirectoryQ@file,
					FileNameJoin@{file,FileBaseName[file]<>".m"},
					file
					],
		a_Association:>
			(
				$EncodedCacheOptions[FileBaseName@file]=a
				)
		];
EncodedCacheOptionsLoad[spec_?StringQ]:=
	Replace[
		Import@EncodedCacheOptionsFile[spec],
		a_Association:>
			(
				$EncodedCacheOptions[spec]=
					Join[
						Lookup[$EncodedCacheOptions,spec,<||>],
						a
						]
				)
		];


EncodedCacheOptionsExport[spec_?StringQ]:=
	(
		Quiet@
			CreateDirectory@
				DirectoryName@
					EncodedCacheOptionsFile[spec];
		Export[
			EncodedCacheOptionsFile[spec],
			$EncodedCacheOptions[spec]
			]
		)


If[!AssociationQ@$EncodedCachePasswords,
	$EncodedCachePasswords=
		<|
			|>
	];


EncodedCachePasswordDialog[spec_]:=
	(Clear@$encodedCacheTemporary;#)&@
		PasswordDialog[
			Dynamic[$encodedCacheTemporary],
			"Encoded Cache",
			spec
			];


EncodedCachePassword[spec_?StringQ]:=
	If[EncodedCacheOption[spec,"StorePasswordInMemory"]//TrueQ,
		Replace[$EncodedCachePasswords[spec],{
			e:Except[_String?(StringLength@#>0&)]:>
				If[EncodedCacheOption[spec,"UsePassword"],
					Replace[
						If[FileExistsQ@EncodedCachePasswordFile[spec],
							EncodedCachePasswordLoad[spec],
							None
							],
						Except[_String?(StringLength@#>0&)]:>
							Replace[EncodedCachePasswordDialog[spec],{
								s_String?(StringLength@#>0&):>
									(EncodedCachePassword[spec]=s),
								_->None
								}]
						],
					None
					]
			}],
		$EncodedCachePasswords[spec]=.;
		Replace[
			If[FileExistsQ@EncodedCachePasswordFile[spec],
				EncodedCachePasswordLoad[spec],
				None
				],
			Except[_String?(StringLength@#>0&)]:>
				Replace[EncodedCachePasswordDialog[spec],{
					s_String?(StringLength@#>0&):>
						s,
					_->None
					}]
			]
		];


EncodedCachePassword/:
	Set[EncodedCachePassword[spec_?StringQ],pwd_]:=(
		$EncodedCachePasswords[spec]=pwd;
		If[EncodedCacheOption[spec,"SavePasswordToDisk"],
			EncodedCachePasswordExport[spec]
			];
		If[!EncodedCacheOption[spec,"StorePasswordInMemory"],
			EncodedCachePassword[spec]=.
			];
		pwd
		);


EncodedCachePassword/:
	Unset[EncodedCachePassword[spec_?StringQ]]:=(
		If[
			EncodedCacheOption[spec,"StorePasswordInMemory"]&&
				EncodedCacheOption[spec,"SavePasswordToDisk"],
			DeleteFile@EncodedCachePasswordFile[spec];
			];
		$EncodedCachePasswords[spec]=.;
		);


EncodedCachePasswordFile[spec_?StringQ]:=
	FileNameJoin@Flatten@
		Replace[
			{
				If[EncodedCacheOption[spec,"Persistent"],
					EncodedCacheOption[spec,"PersistenceBase"],
					EncodedCacheOption[spec,"TemporaryBase"]
					],
				spec,
				"Password"<>".mx"
				},
			FileName[d_]:>d,
			1];
EncodedCachePasswordLoad[spec_?StringQ]:=
	If[FileExistsQ@EncodedCachePasswordFile[spec],
		With[{pwd=
			Replace[Get@EncodedCachePasswordFile[spec],
				Except[_String]->None
				]
			},
			If[StringQ@pwd&&StringLength@pwd>0,
				If[EncodedCacheOption[spec,"StorePasswordInMemory"],
					$EncodedCachePasswords[spec]=pwd
					];
				pwd,
				None
				]
			],
		None
		];
EncodedCachePasswordExport[spec_?StringQ]:=
	With[{
		file=EncodedCachePasswordFile[spec],
		temp=FileNameJoin@{$TemporaryDirectory,RandomSample[Alphabet[],10]<>".m"}
		},
		Export[
			temp,
			EncodedCachePassword[spec]
			];
		Encode[temp,file];
		DeleteFile@temp;
		file
		]


If[!AssociationQ@$EncodedCaches,
	$EncodedCaches=
		<|
			|>
	];


EncodedCacheFile[spec_?StringQ]:=
	FileNameJoin@Flatten@
		Replace[
			{
				If[EncodedCacheOption[spec,"Persistent"],
					EncodedCacheOption[spec,"PersistenceBase"],
					EncodedCacheOption[spec,"TemporaryBase"]
					],
				spec,
				EncodedCacheOption[spec,"CacheName"]<>".mx"
				},
			FileName[d_]:>d,
			1];


EncodedCacheExport[(spec_?StringQ)?(KeyMemberQ[$EncodedCaches,#]&)]:=
	With[{
		file=EncodedCacheFile[spec],
		temp=FileNameJoin@{$TemporaryDirectory,RandomSample[Alphabet[],10]<>".m"}
		},
		Export[
			temp,
			$EncodedCaches[spec]
			];
		If[TrueQ@EncodedCacheOption[spec,"UsePassword"],
			Encode[temp,
				file,
				EncodedCachePassword[spec]
				],
			Encode[temp,file]
			];
		DeleteFile@temp;
		file
		];


EncodedCacheLoad[(spec_?StringQ)?(KeyMemberQ[$EncodedCacheOptions,#]&)]:=
	With[{a=
		With[{file=EncodedCacheFile[spec]},
			If[FileExistsQ@file,
				If[EncodedCacheOption[spec,"UsePassword"]//TrueQ,
					Replace[
						Check[
							Get[file,EncodedCachePassword[spec]],
							EncodedCachePassword[spec]=.,
							Get::enkey
							],
						$Failed:>
							<||>
						],
					Get[file]
					],
				<||>
				]
			]
		},
		If[AssociationQ@a,
			If[TrueQ@$EncodedCacheOptions["StoreInMemory"],
				$EncodedCaches[spec]=a,
				a
				],
			a
			]
		];
EncodedCacheLoad[d_String?(Not@*DirectoryQ)]:=
	With[{f=
		FileNameJoin@Flatten@
			Replace[
				{
					If[EncodedCacheOption[d,"Persistent"],
						EncodedCacheOption[d,"PersistenceBase"],
						EncodedCacheOption[d,"TemporaryBase"]
						],
					d
					},
				FileName[s_]:>s,
				1]
		},
		If[FileExistsQ@f,
			EncodedCacheLoad[f],
			<||>
			]
		];
EncodedCacheLoad[d_String?DirectoryQ]:=
	(
		If[FileExistsQ@FileNameJoin@{d,FileBaseName@d<>".m"},
			EncodedCacheOptionsLoad[FileNameJoin@{d,FileBaseName@d<>".m"}],
			$EncodedCacheOptions[FileBaseName@d]=
				<|
					"Persistent"->True,
					"PersistenceBase"->DirectoryName@d
					|>
			];
		Replace[EncodedCacheLoad[FileBaseName@d],
			e:Except[_Association]:>
				($EncodedCacheOptions[FileBaseName@d]=.;e)
			]
		);


EncodedCache[spec_?StringQ][keys__]:=
	If[TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
		Lookup[
			Lookup[
				$EncodedCaches,
				spec,
				<||>],
			keys
			],
		EncodedCacheLoad[spec][keys]
		];
EncodedCache[spec_?StringQ,"Options"][op_]:=
	EncodedCacheOption[spec,op];
EncodedCache[spec_?StringQ,"Password"]:=
	EncodedCachePassword[spec];


EncodedCache/:
	Set[EncodedCache[spec_?StringQ,"Options"][op_],value_]:=
		EncodedCacheOption[spec,op]=value;
EncodedCache/:
	Unset[EncodedCache[spec_?StringQ,"Options"][op_]]:=
		EncodedCacheOption[spec,op]=.;


EncodedCache/:
	Set[EncodedCache[spec_?StringQ,"Password"],value_]:=
		EncodedCachePassword[spec]=value;
EncodedCache/:
	Unset[EncodedCache[spec_?StringQ,"Password"]]:=
		EncodedCachePassword[spec]=.;


EncodedCache/:
	Set[EncodedCache[spec_?StringQ],a_Association]:=
	(
		If[TrueQ@EncodedCacheOption[spec,"SaveToDisk"],
			$EncodedCaches[spec]=a;
			EncodedCacheExport[spec];
			If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				$EncodedCaches[spec]=.
				],
			If[TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				$EncodedCaches[spec]=a
				]
			];
		a
		);
EncodedCache/:
	Unset[EncodedCache[spec_?StringQ]]:=
	(
		If[TrueQ@EncodedCacheOption[spec,"SaveToDisk"],
			$EncodedCaches[spec]=.;
			$EncodedCacheOptions[spec]=.;
			$EncodedCachePasswords[spec]=.;
			Quiet@
				DeleteDirectory[DirectoryName@EncodedCacheFile[spec],
					DeleteContents->True
					];,
			$EncodedCaches[spec]=.;
			$EncodedCacheOptions[spec]=.;
			$EncodedCachePasswords[spec]=.;
			];
		);


EncodedCache/:
	Set[EncodedCache[spec_?StringQ][keys__],value_]:=
	(
		If[TrueQ@EncodedCacheOption[spec,"SaveToDisk"],
			If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"]||
					!KeyMemberQ[$EncodedCaches,spec],
				Replace[EncodedCacheLoad[spec],
					a_Association:>
						($EncodedCaches[spec]=a)
					]
				];
			$EncodedCaches[spec,keys]=value;
			EncodedCacheExport[spec];
			If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				$EncodedCaches[spec]=.
				],
			If[TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				$EncodedCaches[spec,keys]=value
				]
			];
		value
		);


EncodedCache/:
	SetDelayed[EncodedCache[spec_?StringQ][keys__],value_]:=
	If[TrueQ@EncodedCacheOption[spec,"SaveToDisk"],
		If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				Replace[EncodedCacheLoad[spec],
					a_Association:>
						($EncodedCaches[spec]=a)
					]
			];
		$EncodedCaches[spec][keys]:=value;
		EncodedCacheExport[spec];
		If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
			$EncodedCaches[spec]=.
			];,
		If[TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
			$EncodedCaches[spec][keys]:=value
			];
		];


EncodedCache/:
	Unset[EncodedCache[spec_?StringQ][keys__]]:=
	If[TrueQ@EncodedCacheOption[spec,"SaveToDisk"],
		If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
				Replace[EncodedCacheLoad[spec],
					a_Association:>
						($EncodedCaches[spec]=a)
					]
			];
		$EncodedCaches[spec][keys]=.;
		EncodedCacheExport[spec];
		If[!TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
			$EncodedCaches[spec]=.
			];,
		If[TrueQ@EncodedCacheOption[spec,"StoreInMemory"],
			$EncodedCaches[spec][keys]=.
			];
		];


EncodedCache/:
	File[EncodedCache[spec_?StringQ]]:=
		EncodedCacheFile[spec];
EncodedCache/:
	DeleteFile[EncodedCache[spec_?StringQ]]:=
		DeleteFile@EncodedCacheFile[spec];


If[!ValueQ@$EncodedCacheDefaultKey,
	$EncodedCacheDefaultKey:=
		(
			$EncodedCacheDirectory=Automatic;
			$EncodedCacheDefaultKey="Default"
			)
	];
If[!ValueQ@$EncodedCacheDirectory,
	$EncodedCacheDirectory:=
		(
			$EncodedCacheDefaultKey="Default";
			$EncodedCacheDirectory=Automatic
			)
	];


HoldPattern[$EncodedCache[k__]]:=
	EncodedCache[$EncodedCacheDefaultKey][k];
$EncodedCache/:
	Set[$EncodedCache[k__],v_]:=
		Set[EncodedCache[$EncodedCacheDefaultKey][k],v];
$EncodedCache/:
	SetDelayed[$EncodedCache[k__],v_]:=
		SetDelayed[EncodedCache[$EncodedCacheDefaultKey][k],v];
$EncodedCache/:
	Unset[$EncodedCache[k__]]:=
		Unset[EncodedCache[$EncodedCacheDefaultKey][k]];


$EncodedCache/:
	File@$EncodedCache:=
		EncodedCacheFile[$EncodedCacheDefaultKey];
$EncodedCache/:
	DeleteFile[$EncodedCache]:=
		DeleteFile@File@$EncodedCache;


$EncodedCache/:
	Set[$EncodedCache,a_Association]:=
		Set[EncodedCache[$EncodedCacheDefaultKey],a];
$EncodedCache/:
	Unset[$EncodedCache,a_Association]:=
		Unset[EncodedCache[$EncodedCacheDefaultKey]];


$EncodedCacheSettings[k__]:=
	EncodedCache[$EncodedCacheDefaultKey,"Options"][k];
$EncodedCacheSettings/:
	Set[$EncodedCacheSettings[k__],v_]:=
		Set[EncodedCache[$EncodedCacheDefaultKey,"Options"][k],v];
$EncodedCacheSettings/:
	Unset[$EncodedCacheSettings[k__]]:=
		Unset[EncodedCache[$EncodedCacheDefaultKey,"Options"][k]];


$EncodedCacheSettings/:
	File@$EncodedCacheSettings:=
		EncodedCacheOptionsFile[$EncodedCacheDefaultKey];
$EncodedCacheSettings/:
	DeleteFile@$EncodedCacheSettings:=
		DeleteFile@File@$EncodedCacheSettings;


$EncodedCachePassword[]:=
	EncodedCache[$EncodedCacheDefaultKey,"Password"];
$EncodedCachePassword/:
	Set[$EncodedCachePassword[],v_]:=
		Set[
			EncodedCache[$EncodedCacheDefaultKey,"Password"],
			v
			];
$EncodedCachePassword/:
	Unset[$EncodedCachePassword[]]:=
		Unset[EncodedCache[$EncodedCacheDefaultKey,"Password"]];


$EncodedCachePassword/:
	File@$EncodedCachePassword:=
		EncodedCachePasswordFile[$EncodedCacheDefaultKey];
$EncodedCachePassword/:
	DeleteFile@$EncodedCachePassword:=
		DeleteFile@File@$EncodedCachePassword;


$EncodedCacheDirectory/:
	Set[$EncodedCacheDirectory,dir_]/;(!TrueQ@$inEncodedCacheDirectoryOverload):=
		Block[{$inEncodedCacheDirectoryOverload=True},
			If[dir=!=$EncodedCacheDirectory,
				Replace[dir,{
					Automatic:>
						(
							$EncodedCacheDefaultKey="Default";
							EncodedCacheOptionsLoad[$EncodedCacheDefaultKey];
							EncodedCacheLoad[$EncodedCacheDefaultKey];
							$EncodedCacheDirectory=Automatic
							),
					f:FileName[{p___,n_}]:>
						(
							EncodedCacheLoad[FileNameJoin[{p,n}]];
							$EncodedCacheDefaultKey=FileBaseName@n;
							$EncodedCacheDirectory=f;
							),
					d:(_String|_File)?DirectoryQ:>
						Replace[EncodedCacheLoad[d],
							a_Association:>
								(
									EncodedCacheLoad[d];
									$EncodedCacheDefaultKey=FileBaseName@d;
									$EncodedCacheDirectory=d;
									)
							]
					}],
				dir
				]
			];


If[!ValueQ@$KeyChainKey,
	$KeyChainKey:=
		(
			$KeyChainDirectory=Automatic;
			$KeyChainKey="KeyChain"
			)
	];
If[!ValueQ@$KeyChainDirectory,
	$KeyChainDirectory:=
		(
			$KeyChainKey="KeyChain";
			$KeyChainDirectory=Automatic
			)
	];


HoldPattern[$KeyChain[k__]]:=
	EncodedCache[$KeyChainKey][k];
$KeyChain/:
	Set[$KeyChain[k__],v_]:=
		Set[EncodedCache[$KeyChainKey][k],v];
$KeyChain/:
	SetDelayed[$KeyChain[k__],v_]:=
		SetDelayed[EncodedCache[$KeyChainKey][k],v];
$KeyChain/:
	Unset[$KeyChain[k__]]:=
		Unset[EncodedCache[$KeyChainKey][k]];


$KeyChain/:
	File@$KeyChain:=
		EncodedCacheFile[$KeyChainKey];
$KeyChain/:
	DeleteFile[$KeyChain]:=
		DeleteFile@File@$KeyChain;


$KeyChain/:
	Set[$KeyChain,a_Association]:=
		Set[EncodedCache[$KeyChainKey],a];
$KeyChain/:
	Unset[$KeyChain]:=
		Unset[EncodedCache[$KeyChainKey]];


$KeyChainSettings[k__]:=
	EncodedCache[$KeyChainKey,"Options"][k];
$KeyChainSettings/:
	Set[$KeyChainSettings[k__],v_]:=
		Set[EncodedCache[$KeyChainKey,"Options"][k],v];
$KeyChainSettings/:
	Unset[$KeyChainSettings[k__]]:=
		Unset[EncodedCache[$KeyChainKey,"Options"][k]];


$KeyChainSettings/:
	File@$KeyChainSettings:=
		EncodedCacheOptionsFile[$KeyChainKey];
$KeyChainSettings/:
	DeleteFile@$KeyChainSettings:=
		DeleteFile@File@$KeyChainSettings;


$KeyChainPassword[]:=
	EncodedCache[$KeyChainKey,"Password"];
$KeyChainPassword/:
	Set[$KeyChainPassword[],v_]:=
		Set[
			EncodedCache[$KeyChainKey,"Password"],
			v
			];
$KeyChainPassword/:
	Unset[$KeyChainPassword[]]:=
		Unset[EncodedCache[$KeyChainKey,"Password"]];


$KeyChainPassword/:
	File@$KeyChainPassword:=
		EncodedCachePasswordFile[$KeyChainKey];
$KeyChainPassword/:
	DeleteFile@$KeyChainPassword:=
		DeleteFile@File@$KeyChainPassword;


$KeyChainDirectory/:
	Set[$KeyChainDirectory,dir_]/;(!TrueQ@$inEncodedCacheDirectoryOverload):=
		Block[{$inEncodedCacheDirectoryOverload=True},
			If[dir=!=$KeyChainDirectory,
				Replace[dir,{
					Automatic:>
						(
							$KeyChainKey="KeyChain";
							EncodedCacheOptionsLoad[$KeyChainKey];
							EncodedCacheLoad[$KeyChainKey];
							$KeyChainDirectory=Automatic
							),
					f:FileName[{p___,n_}]:>
						(
							EncodedCacheLoad[FileNameJoin[{p,n}]];
							$KeyChainKey=FileBaseName@n;
							$KeyChainDirectory=f;
							),
					d:(_String|_File)?DirectoryQ:>
						Replace[EncodedCacheLoad[d],
							a_Association:>
								(
									EncodedCacheLoad[d];
									$KeyChainKey=FileBaseName@d;
									$KeyChainDirectory=d;
									)
							]
					}],
				dir
				]
			];


KeyChainAdd[site_->{username_,password_}]:=
	$KeyChain[{site,username}]=password;
KeyChainAdd[{site_->{username_,password_}}]:=
	$KeyChain[{site,username}]=password;
KeyChainAdd[sites:{(_->{_,_}),(_->{_,_})..}]:=
	With[{
		saveOps=$KeyChainSettings["SaveOptionsToDisk"],
		saveDisk=$KeyChainSettings["SaveToDisk"],
		storeLocal=$KeyChainSettings["StoreInMemory"]
		},
		$KeyChainSettings["SaveOptionsToDisk"]=False;
		If[storeLocal,
			$KeyChainSettings["SaveToDisk"]=False
			];
		With[{s=KeyChainAdd/@Most@sites},
			If[storeLocal,
				$KeyChainSettings["SaveToDisk"]=saveDisk
				];
			$KeyChainSettings["SaveOptionsToDisk"]=saveOps;
			Append[s,
				KeyChainAdd@Last@sites
				]
			]
		];
KeyChainAdd[
	sites:(
		_String|(_String->_String)|
			{(_String|(_String->_String))..}
		)
	]:=
	(Clear@$keyChainAuth;Replace[#,_KeyChainAdd->$Failed])&@
		KeyChainAdd@
			Normal@
				AuthenticationDialog[
					Dynamic@$keyChainAuth,
					"",
					None,
					Sequence@@
						Replace[Flatten@{sites},
							(s_->u_):>
								{{s,Automatic},u},
							1
							]
					]


KeyChainGet[site_String,lookup:True|False:False]:=
	If[lookup,
		FirstCase[#,_String?(StringLength@#>0&),
			KeyChainAdd[site]
			],
		FirstCase[#,_String?(StringLength@#>0&)]
		]&@
		$KeyChain[{site,Key@{site,""}}];
KeyChainGet[
	{site_String,username_String},
	lookup:True|False:False]:=
	If[lookup,
		FirstCase[#,_String?(StringLength@#>0&),
			KeyChainAdd[site->username]
			],
		FirstCase[#,_String?(StringLength@#>0&)]
		]&@$KeyChain[{Key@{site,username}}];


End[];



