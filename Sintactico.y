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
#include "tercetos.h"

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

t_pila pilaCond;
char idAsignar[TAM_LEXEMA];

/* Cosas para comparadores booleanos */
	int comp_bool_actual;

int ind_programa;
int ind_sentencia;
int ind_decvar;
int ind_tipo_dato;
int ind_id;
int ind_decision;
int ind_interador;
int ind_condicion;
int ind_asignacion;
int ind_listaexp;
int ind_listaconst;
int ind_read;
int ind_write;
int ind_expresion;
int ind_termino;
int ind_factor;
int ind_factorDer;
int ind_factorIzq;


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
%token INIT
%token AND
%token OR
%token RESTO
%token INT
%token FLOAT
%token STRING
%token IF
%token ELSE
%token CICLO
%token WRITE
%token READ
%token TIMER
%token ESTACONTENIDO

%%
compOK:	
			programa																{	
																						printf("Regla 0 - Compilacion OK\n");	
																						guardarTercetos();
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
            INIT LL_ABRE {printf ("Inicia declaracion \n");} declaracion_variables LL_CIERRA {printf("Fin declaracion \n");}			
			
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
																						insertarVariables(pilaDeclaracion, tipoDato, ult);
																					}
																		
						|declaracion_variables identificadores DOS_PUNTOS tipo_dato {   
																						printf("Regla 9 - Declaracion de variables \n");
																						insertarVariables(pilaDeclaracion, tipoDato, ult);
																					}
						;                 

tipo_dato: 
		INT																			{	
																						printf("Regla 10 - Tipo dato int\n"); 
																						strncpy(tipoDato, "INT", 31);
																					}
		|STRING																		{	
																						printf("Regla 11 - Tipo dato cadena\n");
																						strncpy(tipoDato, "STRING", 31);
																					}
		|FLOAT																		{	
																						printf("Regla 12 - Tipo dato float\n"); 
																						strncpy(tipoDato, "FLOAT", 31);
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
			IF P_ABRE condicion AND condicion P_CIERRA LL_ABRE programa LL_CIERRA 		{ 	
																								printf("Regla 14 - IF con AND \n");
																							}
			|IF P_ABRE condicion AND condicion P_CIERRA LL_ABRE programa LL_CIERRA ELSE LL_ABRE programa LL_CIERRA 		{ 	
																								printf("Regla 15 - IF con AND y ELSE \n");
																							}																				
			|IF P_ABRE condicion OR condicion P_CIERRA LL_ABRE programa LL_CIERRA 		{ 	
																								printf("Regla 16 - IF con OR \n");
																							}
			|IF P_ABRE condicion OR condicion P_CIERRA LL_ABRE programa LL_CIERRA ELSE LL_ABRE programa LL_CIERRA 		{ 	
																								printf("Regla 17 - IF con OR y ELSE \n");
																							}																				
			|IF P_ABRE condicion P_CIERRA LL_ABRE programa LL_CIERRA 					{ 	
																						printf("Regla 18 - IF \n");
																					}
			|IF P_ABRE condicion P_CIERRA LL_ABRE programa LL_CIERRA ELSE LL_ABRE programa LL_CIERRA 	{ 
																						printf("Regla 19 - IF con ELSE \n");
																					}	
			|IF P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa  LL_CIERRA		{ 	
																						printf("Regla 20 - IF negado \n");
																					}																			
			|IF P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa LL_CIERRA ELSE LL_ABRE programa LL_CIERRA 		{ 	
																						printf("Regla 21 - IF negado con ELSE\n");
																					}																																	
			;	

iterador:
			CICLO P_ABRE condicion P_CIERRA LL_ABRE programa {int X = desapilarEntero(&pilaCond); crear_terceto(BI,X,NOOP);} LL_CIERRA					{printf("Regla 22 - CICLO\n");}
			|CICLO P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa LL_CIERRA			{printf("Regla 23 - CICLO NEGADO\n");}																		
			;
			

condicion:			
			factorIzq comp_bool factorDer													{printf("Regla 24 - Comparacion menor \n");
																							ind_condicion = crear_terceto(CMP,ind_factorIzq,ind_factorDer);
																							crear_terceto(saltarFalse(comp_bool_actual),NOOP,NOOP);
																							apilarEntero(&pilaCond,ind_condicion);}

factorIzq:
		factor 																		{printf("Regla 25- Factor Izq \n");
																					ind_factorIzq = ind_factor;}

factorDer:
		factor																		{printf("Regla 26 - Factor Der \n");
																					ind_factorDer = ind_factor;}

comp_bool:
    MENOR                                               {printf("Regla 27: comp_bool es MENOR\n");
														comp_bool_actual = MENOR;}
    |MAYOR                                              {printf("Regla 28: comp_bool es MAYOR\n");
														comp_bool_actual = MAYOR;}
    |MEN_O_IG                                       	{printf("Regla 29: comp_bool es MEN_O_IG\n");
														comp_bool_actual = MEN_O_IG;}
    |MAY_O_IG                                           {printf("Regla 30: comp_bool es MAY_O_IG\n");
														comp_bool_actual = MAY_O_IG;}
    |IGUAL                                              {printf("Regla 31: comp_bool es IGUAL\n");
														comp_bool_actual = IGUAL;}
    |DISTINTO                                           {printf("Regla 32: comp_bool es DISTINTO\n");
														comp_bool_actual = DISTINTO;};

asignacion:
            ID {strcpy(idAsignar, $1);} OP_ASIG expresion				{printf("\nRegla 33 - Asignacion\n");	
																		int pos = buscarEnTabla(idAsignar);
																		ind_asignacion = crear_terceto(OP_ASIG,pos,ind_expresion);
																		}	
			;

s_read:
		READ P_ABRE ID	P_CIERRA					{printf("\nRegla 34 - READ\n");};
			
s_write:
		WRITE P_ABRE ID	P_CIERRA					        {printf("\nRegla 35 - WRITE\n");}	
		|WRITE P_ABRE CTE_STRING P_CIERRA					{printf("\nRegla 35 - WRITE\n");};

timer:
    TIMER P_ABRE CTE_INT COMA sentencia P_CIERRA {printf("\nRegla 36 - Funcion Timer\n");}

esta_contenido:
    ESTACONTENIDO P_ABRE CTE_STRING COMA CTE_STRING P_CIERRA {printf("\nRegla 37 - Funcion ESTACONTENIDO\n");}


expresion:
         termino							{printf("\nRegla 38 - Expresion\n");
		 									 ind_expresion = ind_termino;}
	     |expresion OP_SUM termino			{printf("\nRegla 39 - Expresion suma\n");
		 									 ind_expresion = crear_terceto(OP_SUM,ind_expresion,ind_termino);
											 }
         |expresion OP_RES termino			{printf("\nRegla 40 - Expresion resta\n");
		 									ind_expresion = crear_terceto(OP_RES,ind_expresion,ind_termino);
											 }
		 |expresion RESTO termino			{printf("\nRegla 41 - Expresion resto\n");
		 									ind_expresion = crear_terceto(RESTO,ind_expresion,ind_termino);
											 }				
		 ;

termino: 
       factor								{printf("\nRegla 42 - Termino \n");
	   										 ind_termino = ind_factor;
											}
       |termino OP_DIV factor				{printf("\nRegla 43 - Termino division\n");
	   										 ind_termino = crear_terceto(OP_DIV,ind_termino,ind_factor);
											   }
       |termino OP_MUL factor				{printf("\nRegla 44 - termino multiplicacion\n");
	   										 ind_termino = crear_terceto(OP_MUL,ind_termino,ind_factor);
											}
       ;	

factor: 
      ID 									{printf("\nRegla 45 - Factor ID \n");
	  										printf("\nnombre ID %s\n", $1);
	  										int pos = buscarEnTabla($1);
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);}
      | CTE_INT 							{printf("\nRegla 46 - Factor CTE_INT \n");
	  										char nombre[31];
											sprintf(nombre, "_%s", $1);  
	  										int pos = buscarEnTabla(nombre);
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);}
      | CTE_FLOAT 							{printf("\nRegla 47 - Factor CTE_FLOAT \n");
	  										char nombre[31];
											sprintf(nombre, "_%f", $1);  
											printf("\nnombre cte float %f\n", $1);
	  										int pos = buscarEnTabla(nombre);
											ind_factor = crear_terceto(NOOP,pos,NOOP);}
	  | CTE_STRING							{printf("\nRegla 48 - Factor CTE_STRING \n");
	  										char nombre[31];
											sprintf(nombre, "_%s", $1);
	  										int pos = buscarEnTabla(nombre);
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);}
      ;

%%


int insertarVariables(Declaracion *pilaDeclaracion, char *tipoD, int cantidad) {
	int i = 0;

	strncpy(tipoDato, tipoD, 31);
	
	for(i = 0; i < cantidad; i++) {
		//printf("%s ", pilaDeclaracion[i].nombreDato);
		if(buscarEnTabla(pilaDeclaracion[i].nombreDato) == -1)
			insertarEnTabla(pilaDeclaracion[i].nombreDato, tipoDato, "", 0);
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
	crear_pila(&pilaCond);
	fclose(yyin);
	generarArchivo();
	return 0;
}