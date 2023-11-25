#include "TablaSimbolos.h"

#define OFFSET TAM_TS
#define MAX_TERCETOS 200
#define MAX_TAMANO_PILA 100


/* Operadores extra para usar con los tokens */
#define NOOP -1 /* Sin operador */
#define VERDADERO 2222
#define FALSO 1111
#define BLOQ 7  /* Operador que indica el orden de las sentencias */
#define CMP 21  /* Comparador de assembler */
#define BNE 2   /* = */
#define BGE 4   /* < */
#define BLT 6   /* >= */
#define BLE 10  /* > */
#define BEQ 14  /* != */
#define BGT 8   /* <= */
#define BI 16  /* Branch Always o Salto Incondicional*/


/* Posiciones dentro de un terceto */
#define OP1 2
#define OP2 3
#define OPERADOR 1


/* Funciones */

int saltarTrue(int comp);
int crear_terceto(int operador, int op1, int op2);
void guardarTercetos();
void modificarTerceto(int indice, int posicion, int valor);
void invertirSaltoTerceto(int indice);
/* Funciones */

typedef struct{
  int operador;
  int op1;
  int op2;
} terceto;

terceto lista_terceto[MAX_TERCETOS];
int ultimo_terceto; /* Apunta al ultimo terceto escrito. Incrementarlo para guardar el siguiente. */




//int crear_terceto(int operador, int op1, int op2);
int crear_terceto(int operador, int op1, int op2){
	ultimo_terceto++;
	if(ultimo_terceto >= MAX_TERCETOS){
		printf("Error: me quede sin espacio en para los tercetos. Optimiza tu codigo.\n");
		system("Pause");
		exit(3);
	}

	lista_terceto[ultimo_terceto].operador = operador;
	lista_terceto[ultimo_terceto].op1 = op1;
	lista_terceto[ultimo_terceto].op2 = op2;
	return ultimo_terceto + OFFSET;
}


//void modificarTerceto(int indice, int posicion, int valor);
void modificarTerceto(int indice, int posicion, int valor){
	if(indice > ultimo_terceto + OFFSET){
		printf("Ups, algo fallo. Intente modificar un terceto que no existe.");
		system ("Pause");
		exit (4);
	}
	switch(posicion){
	case OPERADOR:
		lista_terceto[indice - OFFSET].operador = valor;
		break;
	case OP1:
		lista_terceto[indice - OFFSET].op1 = valor;
		break;
	case OP2:
		lista_terceto[indice - OFFSET].op2 = valor;
		break;	
	}
}

//void invertirSaltoTerceto(int indice);
void invertirSaltoTerceto(int indice){
	if(indice > ultimo_terceto + OFFSET){
		printf("Ups, algo fallo. Intente modificar un terceto que no existe.");
		system ("Pause");
		exit (4);
	}
	
	int operadorAModificar = lista_terceto[indice - OFFSET].operador;
	printf("Indice: %d  Operador: %d\n",indice, operadorAModificar);
	switch(operadorAModificar){
	case BGT:
		lista_terceto[indice - OFFSET].operador = BLE;
		break;
	case BGE:
		lista_terceto[indice - OFFSET].operador = BLT;
		break;
	case BLT:
		lista_terceto[indice - OFFSET].operador = BGE;
		break;
	case BLE:
		lista_terceto[indice - OFFSET].operador = BGT;
		break;
	case BEQ:
		lista_terceto[indice - OFFSET].operador = BNE;
		break;
	case BNE:
		lista_terceto[indice - OFFSET].operador = BEQ;
		break;
	default:
			printf("operador no encontrado");
			break;
	}
}

//void guardarTercetos();
void guardarTercetos(){
	if(ultimo_terceto == -1)
		yyerror("No encontre los tercetos");

	FILE* arch = fopen("intermediate-code.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo intermedia.txt\n");
		return;
	}
  int i = 0;
	for(i ; i <= ultimo_terceto; i++){
		//La forma es [i] (operador, op1, op2)
		//Escribo indice
		fprintf(arch, "[%d] (", i + OFFSET);

		//escribo operador
		switch(lista_terceto[i].operador){
		case NOOP:
			fprintf(arch, "---");
			break;
		case BLOQ:
			fprintf(arch, "sentencia");
			break;
		case ID:
			fprintf(arch, "declaracion");
			break;
		case IF:
			fprintf(arch, "IF");
			break;
		case ELSE:
			fprintf(arch, "ELSE");
			break;
		case CICLO:
			fprintf(arch, "CICLO");
			break;
		case OP_ASIG:
			fprintf(arch, ":=");
			break;
		case OP_SUM:
			fprintf(arch, "+");
			break;
		case OP_RES:
			fprintf(arch, "-");
			break;
		case OP_MUL:
			fprintf(arch, "*");
			break;
		case OP_DIV:
			fprintf(arch, "/");
			break;
		case AND:
			fprintf(arch, "y");
			break;
		case OR:
			fprintf(arch, "o");
			break;
		case NEGADO:
			fprintf(arch, "no");
			break;
		case MENOR:
			fprintf(arch, "<");
			break;
		case MAYOR:
			fprintf(arch, ">");
			break;
		case MEN_O_IG:
			fprintf(arch, "<=");
			break;
		case MAY_O_IG:
			fprintf(arch, ">=");
			break;
		case IGUAL:
			fprintf(arch, "==");
			break;
		case DISTINTO:
			fprintf(arch, "!=");
			break;
		case TIMER:
			fprintf(arch, "timer");
			break;
		case ESTACONTENIDO:
			fprintf(arch, "ESTACONTENIDO");
			break;
		case RESULTADO:
			fprintf(arch, "RESULTADO");
			break;
		case END_IF:
			fprintf(arch, "END_IF");
			break;
		case END_WHILE:
			fprintf(arch, "END_WHILE");
			break;	
		case COMA:
			fprintf(arch, "\',\'");
			break;
		case P_Y_COMA:
			fprintf(arch, "\';\'");
			break;
		case READ:
			fprintf(arch, "LEER");
			break;
		case WRITE:
			fprintf(arch, "ESCRIBIR");
			break;
		case RESTO:
			fprintf(arch, "%%");
			break;
		case CMP:
			fprintf(arch, "CMP");
			break;
		case BNE:
			fprintf(arch, "BNE");
			break;
		case BEQ:
			fprintf(arch, "BEQ");
			break;
		case BGT:
			fprintf(arch, "BGT");
			break;
		case BGE:
			fprintf(arch, "BGE");
			break;
		case BLE:
			fprintf(arch, "BLE");
			break;
		case BLT:
			fprintf(arch, "BLT");
			break;
		case BI:
			fprintf(arch, "BI");
			break;
		default:
			fprintf(arch, "operador no encontrado");
			break;
		}

		fprintf(arch, ", ");
		//Escribo op1
		int op = lista_terceto[i].op1;

		if(op == VERDADERO)
			fprintf(arch, "VERDADERO");
		else if(op == FALSO) 
			fprintf(arch, "FALSO");
		else if(op == NOOP)
			fprintf(arch, "---");
		else if(op < TAM_TS){
			//Es una entrada a tabla de simbolos
			fprintf(arch, "%s", &(ts[op].nombre) );
		}
		else //Es el indice de otro terceto
			fprintf(arch, "[%d]", op);

		fprintf(arch, ", ");
		//Escribo op2
		op = lista_terceto[i].op2;
		if(op == VERDADERO)
			fprintf(arch, "VERDADERO");
		else if(op == FALSO) 
			fprintf(arch, "FALSO");
		else if(op == NOOP)
			fprintf(arch, "---");
		else if(op < TAM_TS){
			//Es una entrada a tabla de simbolos
			fprintf(arch, "%s", &(ts[op].nombre) );
		}
		else //Es el indice de otro terceto
			fprintf(arch, "[%d]", op);

		fprintf(arch, ")\n");
	}
	fclose(arch);
}

int saltarFalse(int comp){
	switch(comp){
	case MAYOR:
		return BLE;
	case MAY_O_IG:
		return BLT;
	case MENOR:
		return BGE;
	case MEN_O_IG:
		return BGT;
	case IGUAL:
		return BNE;
	case DISTINTO:
		return BEQ;
	}
	return NOOP;
}

int saltarTrue(int comp){
	switch(comp){
	case MAYOR:
		return BGT;
	case MAY_O_IG:
		return BGE;
	case MENOR:
		return BLT;
	case MEN_O_IG:
		return BLE;
	case IGUAL:
		return BEQ;
	case DISTINTO:
		return BNE;
	}
	return NOOP;
}


