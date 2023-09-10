%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <float.h>
#include <limits.h>

#include "y.tab.h"
#include "TablaSimbolos.h"


int yystopparser=0;
FILE  *yyin;

int yyerror();
int yylex();

char tipoDato[31];
int ult;

typedef struct Declaracion {
	char nombreDato[31];
} Declaracion;
Declaracion pilaDeclaracion[200];


%}

%token CTE_STRING
%token CTE_FLOAT
%token CTE_INT
%token ID
%token OP_ASIG
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token P_ABRE
%token P_CIERRA
%token LL_ABRE
%token LL_CIERRA
%token C_ABRE
%token C_CIERRA
%token COMA
%token PUNTO
%token P_Y_COMA
%token DOS_PUNTOS
%token MAYOR
%token MENOR
%token MAY_O_IG
%token MEN_O_IG
%token DISTINTO
%token IGUAL
%token NEGADO
%token AND
%token OR
%token RESTO
%token DECVAR
%token ENDDEC
%token INT
%token FLOAT
%token STRING
%token IF
%token ELSE
%token ENDIF
%token WHILE
%token ENDWHILE
%token WRITE
%token READ
%token TIMER
%token ESTACONTENIDO

%%
compOK:	
			programa																{	
																						printf("Regla 0 - Compilacion OK\n");	
																					}
			;
programa: 
            sentencia																{	
																						printf("Regla 1 - Programa\n");	
																					}
            |programa sentencia														{	
																						printf("Regla 1 - Programa\n");	
																					}
			;			
sentencia:			
            DECVAR {printf ("Inicia declaracion \n");} declaracion_variables ENDDEC {printf("Fin declaracion \n");}			
			
			|decision 																{ 	
																						printf("Regla 2 - Sentencia decision \n"); 
																					}																		
			|iterador																{
																						printf("Regla 3 - Sentencia iteracion\n");
																					}
			|asignacion  															{
																						printf("Regla 4 - Sentencia asignacion\n");
																					}
			|s_write	  															{
																						printf("Regla 5 - Sentencia WRITE\n");
																					}
			|s_read		  															{
																						printf("Regla 6 - Sentencia READ\n");
																					}
			|timer		  															{
																						printf("Regla 7 - Sentencia TIMER\n");
																					}
			|esta_contenido		  															{
																						printf("Regla 8 - Sentencia ESTACONTENIDO\n");
																					}																																				
			;			
			
declaracion_variables:			
						identificadores DOS_PUNTOS tipo_dato						{ 
																						printf("Regla 9 - Declaracion de variables \n");
																						insertarVariables(pilaDeclaracion, ult);
																					}
																		
						|declaracion_variables identificadores DOS_PUNTOS tipo_dato {   
																						printf("Regla 9 - Declaracion de variables \n");
																						insertarVariables(pilaDeclaracion, ult);
																					}
						;                 

tipo_dato: 
		INT																			{	
																						printf("Regla 10 - Tipo dato int\n"); 
																					}
		|STRING																		{	
																						printf("Regla 11 - Tipo dato cadena\n");
																					}
		|FLOAT																		{	
																						printf("Regla 12 - Tipo dato float\n"); 
																					}
		;			
					
identificadores:			
			ID						 												{ 	
																						ult = 0;	
																						strncpy(pilaDeclaracion[ult++].nombreDato, (char*)yylval, 31);																
																						printf("Regla 13 - Identificador\n"); 
																						
																					}
			|identificadores COMA ID 												{ 
																						strncpy(pilaDeclaracion[ult++].nombreDato,(char*) yylval, 31);
																						printf("Regla 13 - Identificadores\n"); 
																					}
			;			

decision:			
			IF P_ABRE condicion AND condicion P_CIERRA programa ENDIF		{ 	
																								printf("Regla 14 - IF con AND \n");
																							}
			|IF P_ABRE condicion AND condicion P_CIERRA programa ELSE programa ENDIF		{ 	
																								printf("Regla 15 - IF con AND y ELSE \n");
																							}																				
			|IF P_ABRE condicion OR condicion P_CIERRA programa ENDIF		{ 	
																								printf("Regla 16 - IF con OR \n");
																							}
			|IF P_ABRE condicion OR condicion P_CIERRA programa ELSE programa ENDIF		{ 	
																								printf("Regla 17 - IF con OR y ELSE \n");
																							}																				
			|IF P_ABRE condicion P_CIERRA programa ENDIF					{ 	
																						printf("Regla 18 - IF \n");
																					}
			|IF P_ABRE condicion P_CIERRA programa ELSE programa ENDIF	{ 
																						printf("Regla 19 - IF con ELSE \n");
																					}	
			|IF P_ABRE NEGADO condicion P_CIERRA programa ENDIF		{ 	
																						printf("Regla 20 - IF negado \n");
																					}																			
			|IF P_ABRE NEGADO condicion P_CIERRA programa ELSE programa ENDIF		{ 	
																						printf("Regla 21 - IF negado con ELSE\n");
																					}																																	
			;	

iterador:
			WHILE P_ABRE condicion P_CIERRA programa ENDWHILE					{
																						printf("Regla 22 - WHILE\n");
																					}
			|WHILE P_ABRE NEGADO condicion P_CIERRA programa ENDWHILE			{
																						printf("Regla 23 - WHILE NEGADO\n");
																					}																		
			;
			

condicion:			
			factor MENOR factor															{ 	
																						printf("Regla 24 - Comparacion menor \n");
																					}
			|factor MAYOR factor															{ 
																						printf("Regla 25 - Comparacion mayor \n");
																					}
			|factor MAY_O_IG factor														{ 
																						printf("Regla 26 - Comparacion mayor o igual \n");
																					}
			|factor MEN_O_IG factor														{ 
																						printf("Regla 27 - Comparacion menor o igual \n");
																					}
			|factor DISTINTO factor													{ 
																						printf("Regla 28 - Comparacion distinto \n");
																					}
			|factor IGUAL factor													{ 
																						printf("Regla 29 - Comparacion igual \n");
																					}
			;			
			
asignacion:
            ID OP_ASIG expresion				{printf("\nRegla 30 - Asignacion\n");}	
			;

s_read:
		READ P_ABRE ID	P_CIERRA					{printf("\nRegla 31 - READ\n");}
			;
			
s_write:
		WRITE P_ABRE ID	P_CIERRA					        {printf("\nRegla 32 - WRITE\n");}	
		|WRITE P_ABRE CTE_STRING P_CIERRA					{printf("\nRegla 32 - WRITE\n");}	
		;

timer:
    TIMER P_ABRE CTE_INT COMA sentencia P_CIERRA {printf("\nRegla 33 - Funcion Timer\n");}

esta_contenido:
    ESTACONTENIDO P_ABRE CTE_STRING COMA CTE_STRING P_CIERRA


expresion:
         termino							{printf("\nRegla 34 - Expresion\n");}
	     |expresion OP_SUM termino			{printf("\nRegla 35 - Expresion suma\n");}
         |expresion OP_RES termino			{printf("\nRegla 36 - Expresion resta\n");}
		 |expresion RESTO termino			{printf("\nRegla 37 - Expresion resto\n");}					
		 ;

termino: 
       factor								{printf("\nRegla 38 - Termino \n");}
       |termino OP_DIV factor				{printf("\nRegla 39 - Termino division\n");}
       |termino OP_MUL factor				{printf("\nRegla 40 - termino multiplicacion\n");}
       ;	

factor: 
      ID 									{printf("\nRegla 41 - Factor ID \n");}
      | CTE_INT 							{printf("\nRegla 42 - Factor CTE_INT \n");}
      | CTE_FLOAT 							{printf("\nRegla 43 - Factor CTE_FLOAT \n");}
	  | CTE_STRING							{printf("\nRegla 44 - Factor CTE_STRING \n");}
      ;

%%


int insertarVariables(Declaracion *pilaDeclaracion, int cantidad) {
	int i = 0;
	
	for(i = 0; i < cantidad; i++) {
		//printf("%s ", pilaDeclaracion[i].nombreDato);
		insertarEnTabla(pilaDeclaracion[i].nombreDato, "");
	}
	return i;
}

int validarEntero(char *txt) {
	long int numero = strtol(txt, NULL, 10);
	//COTA MAXIMA: 32767 || COTA MINIMA: -32767  
	if( numero > SHRT_MAX -1 || numero < SHRT_MIN +1 ) {
		return 1;
	}
	return 0;
}

int validarFlotante(char *txt) {
	float numero = strtof(txt, NULL);
	//COTA MINIMA: 1.175494E-038; COTA MAXIMA: 3.402823E+038
	if( numero < FLT_MIN || numero > FLT_MAX) {
		return 1;
	}
	return 0;
}


int errorLexico(char * msgErr) {
	printf("%s\n",msgErr);
	system("Pause");
	exit(1);
}

int main(int argc,char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	 else
	 {
		yyparse();
	 }
	fclose(yyin);
	generarArchivo();
	return 0;
}