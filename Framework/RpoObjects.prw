#Include "Totvs.ch"
#Include "parmtype.ch"

#Define RPO_ID				1
#Define RPO_FILE			2
#Define RPO_LANGUAGE		3
#Define RPO_BUILD			4
#Define RPO_DATA			5
#Define RPO_TIME			6

#Define RPO_LEN				7


#Define FILTER_ID_MAX		3	

#Define FILTER_LEN_STRUCT			2

#Define FILTER_STRUCT_POS_ID		1
#Define FILTER_STRUCT_POS_DESC		2

Static __aFilters	:=	MakeFilterArr()
Static __aBuildType	:=	{ 	{0, "BUILD_FULL"}	, {1, "BUILD_USER"}						, {2, "BUILD_PARTNER"}				, {3, "BUILD_PATCH"		}  } 
Static __aLanguage	:=	{	{0, "ADVPL" } 		, {1, "4GL"} } 

Class	RpoObjects	From LongClassName
	
	Data	cRpoPath
	Data	aObjects
	Data	nFilter
	Data	cClassName

	Method	New(cPath,nFilter) Constructor
	
	Method	SetObjects()
	Method	GetObjects()
	
	Method	SetFilter()
	Method	GetFilter()
	
	Method	SetRpo()
	Method	GetRpo()
	
	Method	ClassName()
	
EndClass




Method	New(cPath,nFilter) Class RpoObjects
	
	Default	cPath 		:=	""
	Default	nFilter 	:=	0

	If ( !Empty(cPath) )
		Self:SetRpo(cPath)
		Self:SetFilter(nFilter)
		Self:SetObjects()
		::cClassName	:=	"RpoObjects"
	EndIf

Return


Method	SetObjects() Class 	RpoObjects
	
	Local oRpo
	Private	nId 	:=	0

	If !Empty(::cRpoPath)
		oRpo		:=	Rpo():New(.T.)		
		
		oRpo:Open(::cRpoPath)		
		
		aRpoInfo	:=	oRpo:GetRpoInfo()
		
		oRpo:Close()

		If nFilter	> 0
			aEval(aRpoInfo,	{|x| Iif( Upper(Replace(x[1],FileNoExt(x[1]),"")) $ __aFilters[::nFilter][2],	aAdd(::aObjects,	GetInfo(x,++nID) ),  )	} )
		Else
			aEval(aRpoInfo,	{|x| aAdd(::aObjects,	GetInfo(x) )	} )
		EndIf

	Else
		UserException("Error in property value ::cRpoPath. This property is empty!")
	EndIf


Return

Method	GetObjects(nId)	Class 	RpoObjects
Return(::GetObjects)


Method	SetFilter(nFilter)	Class RpoObjects
	
	PARAMTYPE	0	Var	nFilter	As	NUMERIC

	If !( aScan(__aFilters, {|x| x[1] == nFilter } ) > 0 )
		PARAMEXCEPTION	PARAM 0 	Var	nFilter 	TEXT "NUMERIC" MESSAGE "The filter ID "+cValToChar(nFilter)+" does not exists."
	Else
		::nFilter := nFilter
	EndIf
	

Return


Method	GetFilter(lDesc)	Class RpoObjects
	Local uRet

	PARAMTYPE	0 Var 	lDesc 	As 	LOGICAL OPTIONAL DEFAULT .F.

	If ( ValType(::nFilter) == "N"	.And. ::nFilter <= FILTER_ID_MAX )
		If ( lDesc )
			uRet 	:=	__aFilters[::nFilter][2]
		Else
			uRet 	:=	::nFilter
		EndIf
	Else
		PARAMEXCEPTION	PARAM 0 	Var	::nFilter 	TEXT "NUMERIC" MESSAGE "The filter ID "+cValToChar(nFilter)+" does not exists."
	EndIf


Return(uRet)

Method	SetRpo(cRpoPath)	Class RpoObjects
	
	PARAMTYPE	0	Var	cRpoPath	As	CHARACTER


	If !(File(cPath))		
		PARAMEXCEPTION	PARAM 0 	Var	cPath 	TEXT "CHARACTER" MESSAGE "The file "+AllTrim(cPath)+" does not exists."
	EndIf


	::cRpoPath	:=	cRpoPath

Return


Method	GetRpo()	Class RpoObjects
Return(::cRpoPath)


Method ClassName()	Class RpoObjects
Return(::cClassName)


Static Function GetInfo(aInfo, nID)
	Local cFile		:=	aInfo[1]
	Local cLanguage :=	__aLanguage[ 	aScan( __aLanguage	,{|x| x[1] ==  aInfo[3]}	) 	][2]
	Local cBuildType:=	__aBuildType[	aScan( __aBuildType	,{|x| x[1] ==  aInfo[2]}	)	][2]
	Local dDate		:=	aInfo[4]
	Local nNsDtH 	:=	__fNsToH( __fDHtoNs(aInfo[4]) )
	Local nHour		:=	Int(nNsDtH)
	Local nMin		:=	(nNsDtH - nHour) * 100 
	Local cHour		:=	StrZero(nHour,2)+":"+StrZero(nMin,2) 

Return({nID,cFile, cLanguage, cBuildType, dDate, cHour})




Static Function MakeFilterArr()
	Local aRet		:=	{ 	{0, "NO FILTER"}	, {1, ".PRW|.PRX|.PRG|.APH|.APW|.APL"}	, {2, ".BMP|.JPG|.JPEG|.PNG|.ICO"}	}
	Local aAux
	Local bValidID		:=	{|Id| 	( ValType(Id) 	== "N" .And. Id > FILTER_ID_MAX ) 	}
	Local bValidDesc	:=	{|Desc| ( ValType(Desc) == "N" .And. !Empty(Desc) 			}
	Local bValid		:=	{|Info|	Len(Info) == FILTER_LEN_STRUCT .And. Eval(bValidID,Info[FILTER_STRUCT_POS_ID]) .And. Eval(bValidDesc,Info[FILTER_STRUCT_POS_DESC]) }

	If ExistBlock("RPOOBJF")
		aAux := 	ExecBlock('RPOOBJF', .F., .F.)

		If ( ValType(aAux) == "A"	.And. !Empty(aAux) )

			Begin Sequence
			
				aEval(aAux, {|x| Iif( Eval(bValid,x) ,, Break ) })
				aEval(aAux, {|x| aAdd(aRet,aClone(x) )	})

			End Sequence

		EndIf

	EndIf

Return(aClone(aRet))