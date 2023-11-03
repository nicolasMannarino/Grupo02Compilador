#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#include <float.h>
#include <limits.h>

#ifndef TablaSimbolos_h_
#define TablaSimbolos_h_

#define TAM_MATRIZ 2000
#ifndef TAM_TS
#define TAM_TS 1000
#endif
#ifndef TAM_LEXEMA
#define TAM_LEXEMA 100
#endif

char* getTipo(char*);

typedef struct simbolo {
	char nombre[TAM_LEXEMA + 1];
 	char tipoDato[31];
 	char valor[40];
 	int longitud;
} simbolo;


simbolo ts[TAM_TS];
int ultimo=0;

int insertarEnTabla(char *nombre, char *tipo, char *valor, int longitud){
	if(ultimo == TAM_TS)
		return -1;
	
	strncpy(ts[ultimo].nombre, nombre, TAM_LEXEMA + 1);
	strncpy(ts[ultimo].tipoDato, tipo, 31);
	strncpy(ts[ultimo].valor, valor, 40);
  //strncpy(ts[ultimo].longitud, longitud, 31);
  ts[ultimo].longitud = longitud;

	return ultimo++;
};

void eliminarGuionBajo(char *palabra) {
    if (palabra != NULL && palabra[0] == '_') {
        memmove(palabra, palabra + 1, strlen(palabra));
    }
}

int buscarEnTabla(char* nombre){
	int pos = 0;
  //eliminarGuionBajo(nombre);
	while(pos != ultimo){
		if(strcmp(nombre, ts[pos].nombre) == 0)
			return pos;
		pos++;
	}
	return -1;
};

void borrarTiposDato(){
	ultimo = ultimo - 5;
};

int getCountTS(){
	return ultimo;
};

void imprimirTabla()
{

  printf("\n\n");
  printf("Cantidad de elementos: %d\n", getCountTS());
  
  printf("------------------------------------------TABLA DE SIMBOLOS------------------------------------|\n");
  printf("       NOMBRE             |        TIPO        |              VALOR              |  LONGITUD   |\n");
  printf("-----------------------------------------------------------------------------------------------|\n");

  size_t i;
  for(i = 0; i < getCountTS(); i++)
  {
    simbolo *sim = &ts[i];

    char linea[ 1024 ];
    memset( linea, 0, sizeof( linea ) );

    sprintf(linea, " %-*s | %-*s | %*s | %*d |\n", 24, sim->nombre,
                                                 18, sim->tipoDato,
                                                 31, sim->valor,
                                                 11, sim->longitud);
    printf("%s", linea );

  }
  printf("\n\n");
}

void generarArchivo()
{
  FILE *fp;
  
  fp = fopen ( "symbol-table.txt", "w+" );
  
  fprintf(fp,"----------------------------------------TABLA DE SIMBOLOS------------------------------------|\n");
  fprintf(fp,"       NOMBRE           |        TIPO        |              VALOR              |  LONGITUD   |\n");
  fprintf(fp,"---------------------------------------------------------------------------------------------|\n");

  size_t i;
  for(i = 0; i < getCountTS(); i++)
  {
    simbolo *sim = &ts[i];

    fprintf(fp, " %-*s | %-*s | %*s | %*d |\n", 22, sim->nombre,
                                                 18, sim->tipoDato,
                                                 31, sim->valor,
                                                 11, sim->longitud);
  }
  fclose ( fp );
}

char* getTipo(char* id){
    int aux=0;
    while( ultimo > aux ){
        if(strcmp(id,ts[aux].nombre) == 0){
            return ts[aux].tipoDato;
        }
        aux++;
    }
    return "NULL";
};

#endif