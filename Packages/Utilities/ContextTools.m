(* ::Package:: *)



ContextScopeBlock::usage=
	"";


ContextRemove::usage=
	"Removes a package entirely from the current working state";


Begin["`Private`"];


(* ::Subsubsection::Closed:: *)
(*ContextRemove*)



ContextRemove[pkgContext_String]:=
	With[{cont=StringTrim[pkgContext, ("*"|"`")..]<>"`"},
		With[{cps=NestList[#<>"`*"&, cont<>"*", 3]},
			Quiet[
				Unprotect@@cps;
				ClearAll@@cps;
				Remove@@cps;
				$ContextPath=
					Select[$ContextPath, Not@*StringStartsQ[cont]];
				Unprotect[$Packages];
				$Packages=Select[$Packages, Not@*StringStartsQ[cont]];
				Protect[$Packages];,
				{
					General::readp,
					Protect::locked,
					Attributes::locked,
					Remove::rmnsm
					}
				]
			]
		]


(* ::Subsubsection::Closed:: *)
(*ContextScopeBlock*)



ContextScopeBlock[
	e_,
	baseContext_String?(StringEndsQ["`"]),
	contextPath:{__String?StringEndsQ["`"]}|Automatic:Automatic,
	scope:_String?(StringFreeQ["`"]):"Package",
	context:_String?(StringEndsQ["`"]):"`PackageScope`"
	]:=
	With[{
		newcont=
			If[StringStartsQ[context, "`"],
				baseContext<>context<>scope<>"`",
				context<>scope<>"`"
				],
		res=e,
		cp=Replace[contextPath, Automatic:>$ContextPath]
		},
		Replace[
			Thread[
				Cases[
					HoldComplete[e],
					sym_Symbol?(
						Function[Null,
							MemberQ[cp, Quiet[Context[#]]],
							HoldAllComplete
							]
						):>
						HoldComplete[sym],
					\[Infinity]
					],
				HoldComplete
				],
			HoldComplete[{s__}]:>
					Map[
						Function[Null,
							Quiet[
								Check[
									Set[Context[#], newcont],
									Remove[#],
									Context::cxdup
									],
								Context::cxdup
								],
							HoldAllComplete
							],
						HoldComplete[s]
						]//ReleaseHold;
			];
		res
		];
ContextScopeBlock~SetAttributes~HoldFirst;


End[];



