#ifndef _STRUCTOBJ_CH
#define _STRUCTOBJ_CH


Static 	__cStructName	:=	""
Static	__aDataMembers	:=	{}

#Command	Define Structure <cStructure>	=> Begin Sequence ;; 
													__cStructName := <(cStructure)>
													
#Command		Member <cData>			=>	aAdd(__aDataMembers, <(cData)> ) 


#Command	End Structure  =>;
					NewClassIntf(__cStructName,'') ;;
					aEval(__aDataMembers, {|x,y| NewClassData(__cStructName, x, y) } ) ;;
					NewClassMethod(__cStructName, 'New' ) ;;
					__cStructName	:=	"" ;;
					__aDataMembers	:=	{};;
			End Sequence


Static Function New() 
Return


#endif