%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"
#include "TablaSimbolos.h"
#include "tercetos.h"
#include "Pila.h"
#include "Assembler.h"


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

t_pila pilaCondicionVerTipo;
t_pila pilaCond;
t_pila pilaCondDer;
t_pila pilaTimer;
t_pila pilaCondSalto;
t_pila pilaCondSaltoDer;
t_pila pilaAsign;
char idAsignar[TAM_LEXEMA];
char id2Asignar[TAM_LEXEMA];

/* Cosas para comparadores booleanos */
char resultadoEstaContenido[30];
char cadena1[30];
char cadena2[30];

int tercetoDesencolado;
int posCadena1;
int posCadena2;
int ind_estaContenido;
int ind_i_timer;
int ind_SaltoTimer;
int ind_condicionTimer;
int ind_timer;
int ind_lectura;
int ind_escritura;
int comp_bool_actual;
int comp_bool_actual_der;
int ind_condicionElse;
int ind_saltoFalsoDer;
int ind_condicionDer;
int tercetoDesapilado;
int tercetoDesapiladoSalto;
int tercetoDesapiladoDer;
int ind_saltoFalso;
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
%token RESULTADO
%token END_IF
%token END_WHILE


%%
compOK:	
			programa																{	
																						guardarTercetos();
																						generarAssembler();	
																						printf("Regla 0 - Compilacion OK\n");
																						
																						
																					}
			;
programa: 
            sentencia																{	
																						printf("Regla 1 - Programa\n");
																						ind_programa = ind_sentencia;	
																					}
            |programa sentencia														{	
																						printf("Regla 1 - Programa\n");	
																						ind_programa = ind_sentencia;	
																					}
			;			
sentencia:			
            INIT LL_ABRE {printf ("Inicia declaracion \n");} declaracion_variables LL_CIERRA {printf("Fin declaracion \n");}			
			
			|decision 																{ 	
																						printf("Regla 2 - Sentencia decision \n"); 
																						ind_sentencia = ind_decision;
																					}																		
			|iterador																{
																						printf("Regla 3 - Sentencia iteracion\n");
																						ind_sentencia = ind_interador;
																					}
			|asignacion  															{
																						printf("Regla 4 - Sentencia asignacion\n");
																						ind_sentencia = ind_asignacion;
																					}
			|s_write	  															{
																						printf("Regla 5 - Sentencia WRITE\n");
																						ind_sentencia = ind_write;
																					}
			|s_read		  															{
																						printf("Regla 6 - Sentencia READ\n");
																						ind_sentencia = ind_read;
																					}
			|timer		  															{
																						printf("Regla 7 - Sentencia TIMER\n");
																						ind_sentencia = ind_timer;
																					}
			|esta_contenido		  													{
																						printf("Regla 8 - Sentencia ESTACONTENIDO\n");
																						ind_sentencia = ind_estaContenido;
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
			IF  P_ABRE condicion P_CIERRA LL_ABRE programa LL_CIERRA 	{tercetoDesapilado = desapilarEntero(&pilaCondSalto); modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+1));}				{ 	printf("Regla 18 - IF \n"); } {ind_decision=crear_terceto(END_IF,NOOP,NOOP);}		
			|IF P_ABRE condicion P_CIERRA LL_ABRE programa LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCondSalto);modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+2));ind_condicionElse = crear_terceto(BI,NOOP,NOOP);}	 ELSE {crear_terceto(ELSE,NOOP,NOOP);}  LL_ABRE programa LL_CIERRA {modificarTerceto(ind_condicionElse,OP1,(ind_programa+1));} 	{ printf("Regla 19 - IF con ELSE \n");ind_decision=crear_terceto(END_IF,NOOP,NOOP);}		

			|IF P_ABRE condicion AND  condicionDer P_CIERRA LL_ABRE programa LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCondSalto);modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+1));  tercetoDesapilado = desapilarEntero(&pilaCondDer);modificarTerceto( tercetoDesapilado+1,  OP1,  (ind_programa+1));}		{ printf("Regla 14 - IF con AND \n");} {ind_decision=crear_terceto(END_IF,NOOP,NOOP);}		
			|IF P_ABRE condicion AND condicionDer P_CIERRA LL_ABRE programa LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCondSalto);modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+2));  tercetoDesapilado = desapilarEntero(&pilaCondDer);modificarTerceto( tercetoDesapilado+1,  OP1,  (ind_programa+2));ind_condicionElse = crear_terceto(BI,NOOP,NOOP);} ELSE {crear_terceto(ELSE,NOOP,NOOP);}  LL_ABRE programa LL_CIERRA {modificarTerceto(ind_condicionElse,OP1,(ind_programa+1));}		{ 	printf("Regla 15 - IF con AND y ELSE \n");ind_decision=crear_terceto(END_IF,NOOP,NOOP);}																				
			
			
			|IF P_ABRE condicion OR condicionDer P_CIERRA LL_ABRE programa LL_CIERRA  {tercetoDesapilado = desapilarEntero(&pilaCondSalto);tercetoDesapiladoDer = desapilarEntero(&pilaCondSaltoDer);modificarTerceto( tercetoDesapilado,  OP1,  tercetoDesapiladoDer+1);invertirSaltoTerceto(tercetoDesapilado);modificarTerceto( tercetoDesapiladoDer,  OP1,  (ind_programa+1));}{printf("Regla 16 - IF con OR \n"); ind_decision=crear_terceto(END_IF,NOOP,NOOP);}	
			|IF P_ABRE condicion OR condicionDer P_CIERRA LL_ABRE programa LL_CIERRA  {tercetoDesapilado = desapilarEntero(&pilaCondSalto);tercetoDesapiladoDer = desapilarEntero(&pilaCondSaltoDer);modificarTerceto( tercetoDesapilado,  OP1,  tercetoDesapiladoDer+1);invertirSaltoTerceto(tercetoDesapilado);modificarTerceto( tercetoDesapiladoDer,  OP1,  (ind_programa+1));ind_condicionElse = crear_terceto(BI,NOOP,NOOP);}	 ELSE {crear_terceto(ELSE,NOOP,NOOP);}  LL_ABRE programa LL_CIERRA  {modificarTerceto(ind_condicionElse,OP1,(ind_programa+1));}		{ 	printf("Regla 17 - IF con OR y ELSE \n");ind_decision=crear_terceto(END_IF,NOOP,NOOP);}				 																	
						
			|IF P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa  LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCondSalto);  modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+1)); invertirSaltoTerceto(tercetoDesapilado+1);}			{ 	printf("Regla 20 - IF negado \n");}	 {ind_decision=crear_terceto(END_IF,NOOP,NOOP);}																				
			|IF P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCondSalto); modificarTerceto( tercetoDesapilado,  OP1,  (ind_programa+1)); invertirSaltoTerceto(tercetoDesapilado+1); ind_condicionElse = crear_terceto(BI,NOOP,NOOP);} ELSE {crear_terceto(ELSE,NOOP,NOOP);}  LL_ABRE programa LL_CIERRA {modificarTerceto(ind_condicionElse,OP1,(ind_programa+1));}		{ 	printf("Regla 21 - IF negado con ELSE\n");ind_decision=crear_terceto(END_IF,NOOP,NOOP);}																																
			;	

iterador:
			CICLO P_ABRE condicion P_CIERRA LL_ABRE programa LL_CIERRA 
			{tercetoDesapilado = desapilarEntero(&pilaCond);
			ind_interador = crear_terceto(BI,tercetoDesapilado,NOOP);
			tercetoDesapiladoSalto = desapilarEntero(&pilaCondSalto);
			modificarTerceto( tercetoDesapiladoSalto,  OP1,  (ind_interador+1));}
			{printf("Regla 22 - CICLO\n");} {crear_terceto(END_WHILE,NOOP,NOOP);}
			|CICLO P_ABRE NEGADO condicion P_CIERRA LL_ABRE programa LL_CIERRA {tercetoDesapilado = desapilarEntero(&pilaCond); ind_interador = crear_terceto(BI,tercetoDesapilado,NOOP); tercetoDesapilado = desapilarEntero(&pilaCond);modificarTerceto( tercetoDesapilado,  OP1,  (ind_interador+1));}			{printf("Regla 23 - CICLO NEGADO\n");}		{crear_terceto(END_WHILE,NOOP,NOOP);}																
			;
			

condicionDer:
		factorIzq comp_bool factorDer													{printf("Regla 24 - Comparacion \n");
																							char tipoFactorDer[100]; desapilar(&pilaCondicionVerTipo,tipoFactorDer);
																							char tipoFactorIzq[100]; desapilar(&pilaCondicionVerTipo,tipoFactorIzq);
																																														
																							if(strcmp(tipoFactorDer,tipoFactorIzq) == 1)
																							{
																								informarError("Validacion invalida");
																							}
																							else
																							{
																								ind_condicionDer = crear_terceto(CMP,ind_factorIzq,ind_factorDer);
																								ind_saltoFalsoDer = crear_terceto(saltarFalse(comp_bool_actual),NOOP,NOOP);
																								apilarEntero(&pilaCondSaltoDer,ind_saltoFalsoDer);
																								apilarEntero(&pilaCondDer,ind_condicionDer);
																								
																							}
																							
																							}
		|esta_contenido																		{
																								if(strcmp(resultadoEstaContenido,"VERDADERO") == 0)
																									ind_condicionDer=crear_terceto(CMP,VERDADERO,VERDADERO);
																								else
																									ind_condicionDer=crear_terceto(CMP,FALSO,VERDADERO);
																								ind_saltoFalsoDer=crear_terceto(BNE,NOOP,NOOP);
																								
																								apilarEntero(&pilaCondSaltoDer,ind_saltoFalsoDer);
																								apilarEntero(&pilaCondDer,ind_condicionDer);
																							}																					

condicion:			
			factorIzq comp_bool factorDer													{printf("Regla 24 - Comparacion \n");
																							char tipoFactorDer[100]; desapilar(&pilaCondicionVerTipo,tipoFactorDer);
																							char tipoFactorIzq[100]; desapilar(&pilaCondicionVerTipo,tipoFactorIzq);
																							
																							
																							if(strcmp(tipoFactorDer,tipoFactorIzq) == 1)
																							{
																								informarError("Validacion invalida");
																							}
																							else
																							{
																								ind_condicion = crear_terceto(CMP,ind_factorIzq,ind_factorDer);
																								ind_saltoFalso = crear_terceto(saltarFalse(comp_bool_actual),NOOP,NOOP);
																								apilarEntero(&pilaCondSalto,ind_saltoFalso);
																								apilarEntero(&pilaCond,ind_condicion);
																								
																							}																						
																							
																							}
		|esta_contenido																		{
																							if(strcmp(resultadoEstaContenido,"VERDADERO") == 0)
																								ind_condicion=crear_terceto(CMP,VERDADERO,VERDADERO);
																							else
																								ind_condicion=crear_terceto(CMP,FALSO,VERDADERO);
																								ind_saltoFalso=crear_terceto(BNE,NOOP,NOOP);
																								apilarEntero(&pilaCondSalto,ind_saltoFalso);
																								apilarEntero(&pilaCond,ind_condicion);
																								
																							}																					

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
            ID {strcpy(idAsignar,(char*)$1);apilar(&pilaAsign,idAsignar);} OP_ASIG expresion	{	printf("\nRegla 33 - Asignacion\n");
																		if(buscarEnTabla(idAsignar) == -1)
																			informarError("Variable no declarada");
																		else
																		{
																			int pos = buscarEnTabla(idAsignar);
																			ind_asignacion = crear_terceto(OP_ASIG,pos,ind_expresion);
																			char id[100];desapilar(&pilaAsign,id);
																			vaciar_pila(&pilaAsign);
																		}
																		
																	}

			
																																		


s_read:
		READ P_ABRE ID	{printf("\nRegla 34 - lectura es READ ID %s\n", (char*) $3);int pos = buscarEnTabla((char*) $3); ind_read = crear_terceto(READ, pos, NOOP);} P_CIERRA
			
s_write:
		WRITE P_ABRE ID {printf("\nRegla 35 - WRITE %s\n", $3);
		int pos = buscarEnTabla($3);
		ind_write = crear_terceto(WRITE, pos, NOOP); }		P_CIERRA					        
		|WRITE P_ABRE CTE_STRING {printf("\nRegla 35 - WRITE %s\n",$3);
		 char resultado[10];sprintf(resultado, "%c%s", '_', $3); 
		 int pos = buscarEnTabla(resultado);
		 ind_write = crear_terceto(WRITE,  pos, NOOP);} P_CIERRA

timer:
	TIMER P_ABRE CTE_INT {insertarEnTabla("@i", "INT", "0", 0);
	
	int posI = buscarEnTabla("@i");
	crear_terceto(OP_ASIG,posI,0);

	char resultado[10];sprintf(resultado, "%c%s", '_', $3); 
	int pos = buscarEnTabla(resultado);
	crear_terceto(TIMER,NOOP,NOOP);
	
	ind_timer=crear_terceto(CMP,posI,pos);
	ind_SaltoTimer=crear_terceto(BGT,NOOP,NOOP);
	apilarEntero(&pilaTimer,ind_timer);
	}
	COMA sentencia P_CIERRA 
	{
	int posI = buscarEnTabla("@i");
	ind_i_timer = crear_terceto(OP_SUM,posI,1);
	crear_terceto(OP_ASIG,posI,ind_i_timer);
	crear_terceto(BI,desapilarEntero(&pilaTimer),NOOP);printf("\nRegla 36 - Funcion Timer\n");}

esta_contenido:
    ESTACONTENIDO P_ABRE CTE_STRING
	{
		char resultado[30];sprintf(resultado, "%c%s", '_', $3); 
		strcpy(cadena1,(char*)$3);
		posCadena1 = buscarEnTabla(resultado);

	} 
	COMA CTE_STRING 
	{
		strcpy(cadena2,(char*)$6);
		char resultado[30];sprintf(resultado, "%c%s", '_', $6); 
		posCadena2 = buscarEnTabla(resultado);
		crear_terceto(ESTACONTENIDO,posCadena1,posCadena2);	 
		
		int resul = EstaContenidoFuncion(cadena1,cadena2);

		if(EstaContenidoFuncion(cadena1,cadena2) == 1)
		{
			ind_estaContenido = crear_terceto(RESULTADO,VERDADERO,NOOP);
			strcpy(resultadoEstaContenido,"VERDADERO");
		}		
		else
		{
			ind_estaContenido = crear_terceto(RESULTADO,FALSO,NOOP);
			strcpy(resultadoEstaContenido,"FALSO");
		}
			
		printf("\nRegla 37 - Funcion ESTACONTENIDO\n"); 
	} P_CIERRA  


expresion:
         termino							{printf("\nRegla 38 - Expresion\n");ind_expresion = ind_termino;}
	     |expresion OP_SUM termino			{printf("\nRegla 39 - Expresion suma\n");ind_expresion = crear_terceto(OP_SUM,ind_expresion,ind_termino);}
         |expresion OP_RES termino			{printf("\nRegla 40 - Expresion resta\n");ind_expresion = crear_terceto(OP_RES,ind_expresion,ind_termino);}
		 |expresion RESTO termino			{printf("\nRegla 41 - Expresion resto\n");ind_expresion = crear_terceto(RESTO,ind_expresion,ind_termino);};

termino: 
       factor								{printf("\nRegla 42 - Termino \n");ind_termino = ind_factor;}
       |termino OP_DIV factor				{printf("\nRegla 43 - Termino division\n");ind_termino = crear_terceto(OP_DIV,ind_termino,ind_factor);}
       |termino OP_MUL factor				{printf("\nRegla 44 - termino multiplicacion\n");ind_termino = crear_terceto(OP_MUL,ind_termino,ind_factor);};	

factor: 
      ID  									{
											apilar(&pilaCondicionVerTipo,(char*)(getTipo((int)$1)));
											strcpy(idAsignar,(char*)$1);
											printf("\nRegla 45 - Factor ID \n");
	  										int pos = buscarEnTabla((char *)$1);
											char id[100];
											if(!pila_vacia(&pilaAsign))
											{
                                                desapilar(&pilaAsign,id);
                                                if(strcmp(getTipo(id),getTipo(idAsignar)) == 1)
												{
                                                	if(strcmp(getTipo(id),"NULL") == 1)
														informarError("Asignacion invalida");
													else                                                		
														informarError("Variable no declarada");
			                                    }
                                                apilar(&pilaAsign,id);
											}    
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);}
      | CTE_INT 							{						
											printf("\nRegla 46 - Factor CTE_INT \n");
	  										char nombre[31];
											sprintf(nombre, "_%s", $1);  
	  										int pos = buscarEnTabla(nombre);
											char id[100];
											if(!pila_vacia(&pilaAsign))
											{
                                                desapilar(&pilaAsign,id);
                                                if(strcmp(getTipo(id),"INT") == 1)
												{
													if(strcmp(getTipo(id),"NULL") == 1)
														informarError("Asignacion invalida");
													else                                                		
														informarError("Variable no declarada");
			                                    }
                                                apilar(&pilaAsign,id);
											}    
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);
											apilar(&pilaCondicionVerTipo,"INT");
											}

      | CTE_FLOAT 							{
											apilar(&pilaCondicionVerTipo,"FLOAT");
											printf("\nRegla 47 - Factor CTE_FLOAT \n");
	  										char nombre[31];
											double numero1 = strtod($1, NULL);
											sprintf(nombre, "_%.2f", numero1);
											
	  										int pos = buscarEnTabla(nombre);
											char id[100];
                                            if(!pila_vacia(&pilaAsign))
											{
                                                desapilar(&pilaAsign,id);
                                                if(strcmp(getTipo(id),"FLOAT") == 1)
												{
                                                	if(strcmp(getTipo(id),"NULL") == 1)
														informarError("Asignacion invalida");
													else                                                		
														informarError("Variable no declarada");
			                                    }
                                                apilar(&pilaAsign,id);
											}                                  
											ind_factor = crear_terceto(NOOP,pos,NOOP);
											}
	  | CTE_STRING							{
											apilar(&pilaCondicionVerTipo,"STRING");
											printf("\nRegla 48 - Factor CTE_STRING \n");

	  										char nombre[31];
											sprintf(nombre, "_%s", $1);
	  										int pos = buscarEnTabla(nombre);
											char id[100];
											if(!pila_vacia(&pilaAsign))
											{
                                                desapilar(&pilaAsign,id);
                                                if(strcmp(getTipo(id),"STRING") == 1)
												{
                                                	informarError("Asignacion invalida");
			                                    }
                                                apilar(&pilaAsign,id);
											}    
	  										ind_factor = crear_terceto(NOOP,pos,NOOP);}
      ;

%%
void limpiarCadenas(char *cadena) {
    int longitud = strlen(cadena);

    if (longitud >= 2 && cadena[0] == '"' && cadena[longitud - 1] == '"') {
        int i;

        // Mover los caracteres internos hacia la izquierda
        for (i = 0; i < longitud - 1; ++i) {
            cadena[i] = cadena[i + 1];
        }

        // Colocar el carácter nulo al final para truncar la cadena
        cadena[longitud - 2] = '\0';
    }
}

int EstaContenidoFuncion(char *cadena1,char *cadena2) {
	limpiarCadenas(cadena1);
	limpiarCadenas(cadena2);
    if (cadena1 == NULL || cadena2 == NULL) {
        return 0; // Si alguna de las cadenas es nula, no están contenidas.
    }

    // Usamos la función strstr para buscar cadena2 en cadena1.
    // Si la función encuentra cadena1 en cadena2, devuelve un puntero a la primera ocurrencia,
    // lo que significa que está contenida. Si no se encuentra, devuelve NULL.
 	if(strstr(cadena1, cadena2) != NULL)
		return 1;
	
	return 0;
}


void Timer(int condicion, void (*operacion)()) {
    int contador = 0;
    while (contador < condicion) {
        operacion();
        contador++;
    }
}

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
	crear_pila(&pilaCondicionVerTipo);
	crear_pila(&pilaTimer);
	crear_pila(&pilaCondDer);
	crear_pila(&pilaCond);
	crear_pila(&pilaAsign);
	crear_pila(&pilaCondSaltoDer);	
	crear_pila(&pilaCondSalto);
		

	fclose(yyin);
	generarArchivo();
	return 0;
}