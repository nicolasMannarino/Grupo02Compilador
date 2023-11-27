#include <stdio.h>
#include <stdlib.h>


int vectorSaltos[MAX_TERCETOS];
char saltoActual[80];
int nroSalto = 0;
void generarAssembler();
void escribirInicio(FILE* arch);
void escribirInicioCodigo(FILE* arch);
void escribirFinal(FILE *arch);
void generarTabla(FILE* arch);

void finIfOWhile(FILE* arch, char* etiqueta, int i);
void escribirEtiqueta(FILE* arch, char* etiqueta, int n);
void escribirSalto(FILE* arch, char* salto, int tercetoDestino);
void asignacion(FILE* arch, int terceto);
void comparacion(FILE* arch, int terceto);
void suma(FILE* arch, int terceto);
void resta(FILE* arch, int terceto);
void multiplicacion(FILE* arch, int terceto);
void division(FILE* arch, int terceto);
void levantarEnPila(FILE* arch, const int ind);
void write(FILE* arch, int ind);
void read(FILE* arch, int ind);

typedef struct{
  int indice;
  int operador;
  int op1;
  int op2;
} tercetoConIndice;

//Variables externas
extern simbolo ts[TAM_TS];
extern int ultimo;
extern terceto lista_terceto[MAX_TERCETOS];
extern int ultimo_terceto;

tercetoConIndice lista_terceto_con_indice[MAX_TERCETOS];

int encontrarValor(int vector[], int valor) {
	int i;
    for ( i = 0; i < MAX_TERCETOS; i++) {
        if (vector[i] == valor) {
            return 1; // Devuelve 1 si se encuentra
        }
    }
    return -1; // Devuelve -1 si el valor no se encuentra en el vector
}


int encontrarYEscribirEnPosicionLibre(int vector[], int tamano, int valor) {
    int primeraPosicionLibre = -1;
	int i;
    for (i = 0; i < tamano; i++) {
        if (vector[i] == 0) {
            primeraPosicionLibre = i;
            break;
        }
    }

    if (primeraPosicionLibre != -1) {
        vector[primeraPosicionLibre] = valor;
        return primeraPosicionLibre;
    } else {
        return -1;
    }
}

void generarAssembler(){
  FILE* arch = fopen("Final.asm", "w");
  if(!arch){
		printf("No pude crear el archivo final.txt\n");
		return;
	}
  int i;
  for ( i = 0; i < MAX_TERCETOS; i++) {
        vectorSaltos[i] = 0;
    }

  escribirInicio(arch);
  generarTabla(arch);
  escribirInicioCodigo(arch);
	
    for (i = 0; i < 175; i++) {
		if(lista_terceto[i].operador != 0 || lista_terceto[i].op1 != 0 || lista_terceto[i].op2 != 0)
		{
			lista_terceto_con_indice[i].operador = lista_terceto[i].operador;
			lista_terceto_con_indice[i].op1 = lista_terceto[i].op1;
			lista_terceto_con_indice[i].op2 = lista_terceto[i].op2;
			lista_terceto_con_indice[i].indice = i+1000;
		}

    }

  for( i=0; i <= ultimo_terceto; i++){
	//printf("%d\n",lista_terceto[i].operador);
    switch(lista_terceto_con_indice[i].operador){
      case OP_ASIG:
	  	asignacion(arch, i);
        break;
      case CMP:
		comparacion(arch, i);
        break;
      case BGT:
        escribirSalto(arch, "JA", lista_terceto_con_indice[i].op1);
        break;
      case BGE:
        escribirSalto(arch, "JAE", lista_terceto_con_indice[i].op1);
        break;
      case BLT:
        escribirSalto(arch, "JB", lista_terceto_con_indice[i].op1);
        break;
      case BLE:
        escribirSalto(arch, "JBE", lista_terceto_con_indice[i].op1);
        break;
      case BNE:
        escribirSalto(arch, "JNE", lista_terceto_con_indice[i].op1);
        break;
      case BEQ:
        escribirSalto(arch, "JE", lista_terceto_con_indice[i].op1);
        break;
      case BI:
        escribirSalto(arch, "JMP", lista_terceto_con_indice[i].op1);
        break;
	  case END_IF:
        finIfOWhile(arch, "END_IF", i);
        break;
      case ELSE:
        finIfOWhile(arch, "ELSE", i);
        break;
      case CICLO:
        escribirEtiqueta(arch, "CICLO", i);
        break;
      case ESTACONTENIDO:
		escribirEtiqueta(arch, "ESTACONTENIDO", i);
		break;
	  case TIMER:
		escribirEtiqueta(arch, "TIMER", i);
		break;
      case OP_SUM:
		suma(arch,i);
        break;
      case OP_RES:
		resta(arch,i);
        break;
      case OP_MUL:
		multiplicacion(arch,i);
        break;
      case OP_DIV:
		division(arch,i);
        break;
      case READ: 
        read (arch,i);
        break;
      case WRITE:
	  	write(arch, i);
        break;
	  case NOOP:
	  	levantarEnPila(arch, i);
        break;
    }
  }

  escribirFinal(arch);

  /*for(i = 0; i < 50; i++)
		{
			if(vectorSaltos[i] != 0)
			printf("VECTOR %d -- %d\n",i,vectorSaltos[i]);
		}*/
  fclose(arch);

}

void escribirInicio(FILE *arch){
  fprintf(arch, "include macros2.asm\ninclude number.asm\n\n.MODEL SMALL\n.386\n.STACK 200h\n\n");
}

void escribirInicioCodigo(FILE* arch){
	fprintf(arch, ".CODE\n\nMOV AX, @DATA\nMOV DS, AX\nFINIT\n\n");
}

void escribirFinal(FILE *arch){
    fprintf(arch, "\nMOV AH, 1\nINT 21h\nMOV AX, 4C00h\nINT 21h\n\nEND\n");
	// TODO: Preguntar por flags y escribir subrutinas
}

void generarTabla(FILE *arch){
    fprintf(arch, ".DATA\n");
    fprintf(arch, "NEW_LINE DB 0AH,0DH,'$'\n");
	fprintf(arch, "CWprevio DW ?\n");
    int i;
    for( i=0; i<=ultimo; i++){
        fprintf(arch, "%s ", ts[i].nombre);
		if (strcmp(ts[i].tipoDato, "CTE_INT") == 0) {
				fprintf(arch, "dd %s\n", ts[i].valor);
			} else if (strcmp(ts[i].tipoDato, "CTE_FLOAT") == 0) {
				fprintf(arch, "dd %s\n", ts[i].valor);
			} else if (strcmp(ts[i].tipoDato, "CTE_STRING") == 0) {
				fprintf(arch, "db %s\n", ts[i].valor);
			} else {
		// Es una variable int, float o puntero a string
		fprintf(arch, "dd ?\n");
		} 
    }

    fprintf(arch, "\n");
}

void escribirEtiqueta(FILE* arch, char* etiqueta, int n){
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[n].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[n].indice);	
		fprintf(arch, str);
	}
    fprintf(arch, "%s%d:\n", etiqueta, n+OFFSET);
}

void escribirSalto(FILE* arch, char* salto, int tercetoDestino){
	char str[80];
    fprintf(arch, "%s ", salto);

    //Por si nos olvidamos de rellenar un salto
    /*if(tercetoDestino == NOOP){
        printf("Falta salto.\n");
        system("Pause");
        exit(10);
    }*/

	sprintf(str, "SALTO%d\n", tercetoDestino);
	encontrarYEscribirEnPosicionLibre(vectorSaltos, MAX_TERCETOS, tercetoDestino);
	int i;
			
	fprintf(arch, str);
	strcpy(saltoActual,str);
		
}
void asignacion(FILE* arch, int ind){
	int destino = lista_terceto_con_indice[ind].op1;
	int origen = lista_terceto_con_indice[ind].op2;
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}

	//Ver tipo de dato
	if (strcmp(ts[destino].tipoDato, "INT") == 0) {
		//fprintf(arch, "FLD %s\n", ts[origen].nombre);
		fprintf(arch, "FSTP %s", ts[destino].nombre);
	} else if (strcmp(ts[destino].tipoDato, "FLOAT") == 0) {
		//fprintf(arch, "FLD %s\n", ts[origen].nombre);
		fprintf(arch, "FSTP %s", ts[destino].nombre);
	} else if (strcmp(ts[destino].tipoDato, "STRING") == 0) {
		fprintf(arch, "LEA EAX, %s\nMOV %s, EAX", ts[origen].nombre, ts[destino].nombre);
	}

	fprintf(arch, "\n");
}

void finIfOWhile(FILE* arch, char* ind, int indice){
	char saltoAssembler[50];

	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[indice].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[indice].indice);	
		fprintf(arch, str);
	}

	if (strcmp(ind, "END_IF") == 0) {
			//desapilar(&pilaSalto,saltoAssembler);
			fprintf(arch, "END_IF:\n");
			//fprintf(arch, saltoAssembler);
	}
		if (strcmp(ind, "ELSE") == 0) {
			//desapilar(&pilaSalto,saltoAssembler);
			fprintf(arch, "ELSE:\n");
			//fprintf(arch, saltoAssembler);
	}
}


/** Levanta, da vuelta los elementos y compara */
void comparacion(FILE* arch, int ind){
	char str[80];
	
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}

	nroSalto++;
	levantarEnPila(arch, ind);	
	fprintf(arch, "FXCH\nFCOMP\nFSTSW AX\nSAHF\n");

}
/** Levanta, suma, y deja en pila */
void suma(FILE* arch, int ind){
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}
	levantarEnPila(arch, ind);
	fprintf(arch, "FADD\n");
}
/** Levanta, revisa si hay dos operadores: Si hay uno, calcula el negativo. Si hay dos, resta y deja en pila*/
void resta(FILE* arch, int ind){
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}

	if(lista_terceto_con_indice[ind].op2==NOOP){
		int aux;
		if((aux = lista_terceto_con_indice[ind].op1) < OFFSET){ //Es decir si está en la tabla
			if (strcmp(ts[aux].tipoDato, "INT") == 0) {
				fprintf(arch, "FLD %s\n", ts[aux].nombre);
			} else if (strcmp(ts[aux].tipoDato, "FLOAT") == 0) {
				fprintf(arch, "FLD %s\n", ts[aux].nombre);
			} else if (strcmp(ts[aux].tipoDato, "CTE_INT") == 0) {
				fprintf(arch, "FLD %s\n", ts[aux].nombre);
			} else if (strcmp(ts[aux].tipoDato, "CTE_FLOAT") == 0) {
				fprintf(arch, "FLD %s\n", ts[aux].nombre);
			}

		}
		fprintf(arch, "FCHS\n");
	}
	else{
		levantarEnPila(arch, ind);
		fprintf(arch, "FSUB\n");
	}
}
/** Levanta, multiplica, y deja en pila */
void multiplicacion(FILE* arch, int ind){
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}
	levantarEnPila(arch, ind);
	fprintf(arch, "FMUL\n");
}
/** Levanta, divide, si la cuenta era de enteros se asegura de truncar y deja en pila */
void division(FILE* arch, int ind){ 
	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}
	levantarEnPila(arch, ind);
	fprintf(arch, "FDIV\n");
}

/** Asegura que el elemento de la izquierda esté en st1, y el de la derecha en st0 */
void levantarEnPila(FILE* arch, const int ind){
	int elemIzq = lista_terceto_con_indice[ind].op1;
	int elemDer = lista_terceto_con_indice[ind].op2;
	int izqLevantado = 0;

	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[ind].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[ind].indice);	
		fprintf(arch, str);
	}
	/* Si el elemento no está en pila lo levanta */
	if(elemIzq < OFFSET){
			if (strcmp(ts[elemIzq].tipoDato, "INT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
		} else if (strcmp(ts[elemIzq].tipoDato, "FLOAT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
		} else if (strcmp(ts[elemIzq].tipoDato, "CTE_INT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
		} else if (strcmp(ts[elemIzq].tipoDato, "CTE_FLOAT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
		}
		izqLevantado=1;
	}
	if(elemDer < OFFSET){
		if (strcmp(ts[elemDer].tipoDato, "INT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
		} else if (strcmp(ts[elemDer].tipoDato, "FLOAT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
		} else if (strcmp(ts[elemDer].tipoDato, "CTE_INT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
		} else if (strcmp(ts[elemDer].tipoDato, "CTE_FLOAT") == 0) {
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
		}

		izqLevantado=0;
	}
	if(izqLevantado){
		fprintf(arch, "FXCH\n");
	}
}

void write(FILE* arch, int terceto){

	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[terceto].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[terceto].indice);	
		fprintf(arch, str);
	}

	int ind = lista_terceto_con_indice[terceto].op1; //Indice de entrada a tabla de simbolos del mensaje a mostrar
		if (strcmp(ts[ind].tipoDato, "INT") == 0) {
			fprintf(arch, "displayInteger %s", ts[ind].nombre);
		} else if (strcmp(ts[ind].tipoDato, "FLOAT") == 0) {
			fprintf(arch, "displayFloat %s,2\n", ts[ind].nombre);
		} else if (strcmp(ts[ind].tipoDato, "STRING") == 0) {
			fprintf(arch, "displayString %s", ts[ind].nombre);
		} else if (strcmp(ts[ind].tipoDato, "CTE_STRING") == 0) {
			fprintf(arch, "displayString %s", ts[ind].nombre);
		}

	fprintf(arch, "\n");
}

void read(FILE* arch, int terceto){

	char str[80];
	if(encontrarValor(vectorSaltos, lista_terceto_con_indice[terceto].indice ) == 1)
	{
		sprintf(str, "SALTO%d:\n", lista_terceto_con_indice[terceto].indice);	
		fprintf(arch, str);
	}
	int ind = lista_terceto_con_indice[terceto].op1;
	if (strcmp(ts[ind].tipoDato, "INT") == 0) {
		fprintf(arch, "getInteger %s", ts[ind].nombre);
	} else if (strcmp(ts[ind].tipoDato, "FLOAT") == 0) {
		fprintf(arch, "getFloat %s", ts[ind].nombre);
	} else if (strcmp(ts[ind].tipoDato, "STRING") == 0) {
		fprintf(arch, "getString %s", ts[ind].nombre);
	}
	fprintf(arch, "\n");
}
