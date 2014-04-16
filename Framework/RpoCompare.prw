#Include "Totvs.ch"
#Include "parmtype.ch"

#Define RPO_A	1
#Define RPO_B	2


#Define RPO_ID				1
#Define RPO_FILE			2
#Define RPO_LANGUAGE		3
#Define RPO_BUILD			4
#Define RPO_DATA			5
#Define RPO_TIME			6

#Define RPO_LEN				7


#Define COMPARSION_RESULT_STATUS	{{0, "Igual Nos Dois RPO's"}, {1,"Mais Atual no RPO A"}, {2, "Mais Atual No RPO B"}, {3, "Não existe no RPO A"}, {4, "Não Existe no RPO B"} }


Class RpoCompare	From	LongClassName
	
	Data	oRpo_A
	Data	oRpo_B
	Data	nFilter
	Data	cClassName
	Data	aResult

	Method New(cPath_A, cPath_B) Constructor
	Method GetObjById(nRpo,nId)
	Method GetObjByFile(nRpo,cFile)
	Method Compare()

	Method	ClassName()

EndClass





Method New(cPath_A,cPath_B,nFilter) Class RpoCompare
	
	PARAMTYPE 0 Var cPath_A As CHARACTER
	PARAMTYPE 1 Var cPath_B As CHARACTER
	PARAMTYPE 2 Var nFilter As NUMERIC	OPTIONAL Default 0

	::cClassName	:=	"RpoCompare"
	::oRpo_A		:=	RpoObjects():New(cPath_A,nFilter)
	::oRpo_B		:=	RpoObjects():New(cPath_B,nFilter)

Return



Method	GetObjById(nRpo, nId)	Class RpoCompare

	
	Local nResult
	Local uResult

	PARAMTYPE 0 Var nRpo As NUMERIC
	PARAMTYPE 1 Var nId  As NUMERIC	

	Do Case 
		Case nRpo == RPO_A
			
			If !( nResult :=	aScan( ::oRpo_A:aObjects, {|x| x[1] == nId} ) ) > 0
				ConOut("The filter ID "+cValToChar(nId)+" does not exists.")
				Return
			Else
				uResult	:=	aClone(::oRpo_A:aObjects[nResult])
			EndIf

		Case nRpo == RPO_B
			
			If !( nResult :=	aScan( ::oRpo_B:aObjects, {|x| x[1] == nId} ) ) > 0
				ConOut("The filter ID "+cValToChar(nId)+" does not exists.")
				Return
			Else
				uResult	:=	aClone(::oRpo_B:aObjects[nResult])
			EndIf

		OtherWise
			UserException("The RPO ID "+cValToChar(nRpo)+" does not exists.")
	EndCase

Return(uResult)





Method	GetObjByFile(nRpo, cFile)	Class RpoCompare
	
	Local nResult
	Local uResult

	PARAMTYPE 0 Var nRpo 	As NUMERIC
	PARAMTYPE 1 Var cFile  	As CHARACTER	

	Do Case 
		Case nRpo == RPO_A
			
			If !( nResult :=	aScan( ::oRpo_A:aObjects, {|x| x[2] == cFile} ) ) > 0
				ConOut("The filter ID "+cValToChar(nId)+" does not exists.")
				Return
			Else
				uResult	:=	aClone(::oRpo_A:aObjects[nResult])
			EndIf

		Case nRpo == RPO_B
			
			If !( nResult :=	aScan( ::oRpo_B:aObjects, {|x| x[2] == cFile} ) ) > 0
				ConOut("The filter ID "+cValToChar(nId)+" does not exists.")
				Return
			Else
				uResult	:=	aClone(::oRpo_B:aObjects[nResult])
			EndIf

		OtherWise
			UserException("The RPO ID "+cValToChar(nRpo)+" does not exists.")
	EndCase

Return(uResult)

Method	ClassName() Class RpoObjects
Return(::ClassName)


Method Compare() Class RpoObjects
	Local aAux_A
	Local aAux_B
	Local cFile
	Local nX
	Local bValid :=	{|cFile|  aScan(::aResult, {|x| x[1] == cFile .Or. x[6] == cFile }) > 0  }

	::aResult	:=	{}

	aEval(oRpo_A:aObjects, {|x| aAux_A := x ,Iif( Eval(bValid,aAux_A[RPO_FILE]),, ( aAux_B := GetObjByFile(RPO_B,cFile),  aAdd( ::aResult, GetResultComp(aAux_A, aAux_B) ) ) ) })
	aEval(oRpo_A:aObjects, {|x| aAux_B := x ,Iif( Eval(bValid,aAux_B[RPO_FILE]),, ( aAux_A := GetObjByFile(RPO_A,cFile),  aAdd( ::aResult, GetResultComp(aAux_A, aAux_B) ) ) ) })

Return


Static Function GetResultComp(aInfo_A, aInfo_B)
	Local aReturn
	Local nResult
	Local nPos	

		Do Case
			Case ! ( ArrayDiif(aInfo_A, aInfo_B) )
				nResult	:=	0
			Case aInfo_A[RPO_DATA] > aInfo_B[RPO_DATA]
				nResult	:=	1
			Case aInfo_A[RPO_TIME] > aInfo_B[RPO_TIME]
				nResult	:=	1
				Case aInfo_B[RPO_DATA] > aInfo_A[RPO_DATA]
				nResult	:=	2
			Case aInfo_B[RPO_TIME] > aInfo_A[RPO_TIME]
				nResult	:=	2	
			Case Empty(aInfo_A)
				nResult	:=	3
				aInfo_A	:=	Array( (RPO_LEN - 1) )
			Case Empty(aInfo_B)
				nResult	:=	4
				aInfo_B	:=	Array( (RPO_LEN - 1) )
		EndCase

		nPos	:=	aScan(COMPARSION_RESULT_STATUS, {|x| x[1] == nResult})

		aReturn :=	{	aInfo_A[RPO_FILE],; 
						aInfo_A[RPO_LANGUAGE],; 
						aInfo_A[RPO_BUILD],; 
						aInfo_A[RPO_DATA],; 
						aInfo_A[RPO_TIME],;
						aInfo_B[RPO_FILE],; 
						aInfo_B[RPO_LANGUAGE],; 
						aInfo_B[RPO_BUILD],; 
						aInfo_B[RPO_DATA],; 
						aInfo_B[RPO_TIME],
						COMPARSION_RESULT_STATUS[nPos][2] }

Return(aClone(aReturn))