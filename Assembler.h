#include <stdio.h>
#include <stdlib.h>

void generarAssembler();
void escribirInicio(FILE* arch);
void escribirInicioCodigo(FILE* arch);
void escribirFinal(FILE *arch);
void generarTabla(FILE* arch);

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

//Variables externas
extern simbolo ts[TAM_TS];
extern int ultimo;
extern terceto lista_terceto[MAX_TERCETOS];
extern int ultimo_terceto;

void generarAssembler(){
  FILE* arch = fopen("Final.asm", "w");
  if(!arch){
		printf("No pude crear el archivo final.txt\n");
		return;
	}

  escribirInicio(arch);
  generarTabla(arch);
  escribirInicioCodigo(arch);
  int i;
  for( i=0; i <= ultimo_terceto; i++){
    switch(lista_terceto[i].operador){
      case OP_ASIG:
	  	asignacion(arch, i);
        break;
      case CMP:
		comparacion(arch, i);
        break;
      case BGT:
        escribirSalto(arch, "JA", lista_terceto[i].op2);
        break;
      case BGE:
        escribirSalto(arch, "JAE", lista_terceto[i].op2);
        break;
      case BLT:
        escribirSalto(arch, "JB", lista_terceto[i].op2);
        break;
      case BLE:
        escribirSalto(arch, "JBE", lista_terceto[i].op2);
        break;
      case BNE:
        escribirSalto(arch, "JNE", lista_terceto[i].op2);
        break;
      case BEQ:
        escribirSalto(arch, "JE", lista_terceto[i].op2);
        break;
      case BI:
        escribirSalto(arch, "JMP", lista_terceto[i].op1);
        break;
      case ELSE:
        escribirEtiqueta(arch, "else", i);
        break;
      case CICLO:
        escribirEtiqueta(arch, "while", i);
        break;
      case ESTACONTENIDO:
		escribirEtiqueta(arch, "estaContenido", i);
		break;
	  case TIMER:
		escribirEtiqueta(arch, "timer", i);
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
    }
  }

  escribirFinal(arch);
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
        switch((int)ts[i].tipoDato){
        case CTE_INT:
            fprintf(arch, "dd %d\n", ts[i].valor);
            break;
        case CTE_FLOAT:
            fprintf(arch, "dd %f\n", ts[i].valor);
            break;
        case CTE_STRING:
            fprintf(arch, "db \"%s\", '$'\n", ts[i].valor);
            break;
        default: //Es una variable int, float o puntero a string
            fprintf(arch, "dd ?\n");
        }
    }

    fprintf(arch, "\n");
}

void escribirEtiqueta(FILE* arch, char* etiqueta, int n){
    fprintf(arch, "%s%d:\n", etiqueta, n+OFFSET);
}

void escribirSalto(FILE* arch, char* salto, int tercetoDestino){
    fprintf(arch, "%s ", salto);

    //Por si nos olvidamos de rellenar un salto
    if(tercetoDestino == NOOP){
        printf("Ups. Parece que me olvide de rellenar un salto en los tercetos y ahora no se como seguir.\n");
        system("Pause");
        exit(10);
    }

        switch( lista_terceto[tercetoDestino - OFFSET].operador ){
        case ELSE:
            fprintf(arch, "else");
            break;
        case CICLO:
            fprintf(arch, "while");
            break;
        fprintf(arch, "%d\n", tercetoDestino);
    }
}
void asignacion(FILE* arch, int ind){
	int destino = lista_terceto[ind].op1;
	int origen = lista_terceto[ind].op2;

	//Ver tipo de dato
	switch((int)ts[destino].tipoDato){
	case INT:
		// Si es un int de tabla de simbolos, primero hay que traerlo de memoria a st(0)
		// Sino es el resultado de una expresion anterior y ya esta en st(0)
		if(origen < OFFSET) //Es un int en tabla de simbolos
			fprintf(arch, "FILD %s\n", ts[origen].nombre);
		else //El valor ya esta en el copro, puede que haga falta redondear
			fprintf(arch, "FSTCW CWprevio ;Guardo Control Word del copro\nOR CWprevio, 0400h ;Preparo Control Word seteando RC con redondeo hacia abajo\nFLDCW CWprevio ;Cargo nueva Control Word\n");
		fprintf(arch, "FISTP %s", ts[destino].nombre);
		break;
	case FLOAT:
		// Si es un float de tabla de simbolos, primero hay que traerlo de memoria a st(0)
		// Sino es el resultado de una expresion anterior y ya esta en st(0)
		if(origen < OFFSET) //Es un float en tabla de simbolos
			fprintf(arch, "FLD %s\n", ts[origen].nombre);
		fprintf(arch, "FSTP %s", ts[destino].nombre);
		break;
	case STRING:
		//destino y origen son entradas a tabla de simbolos
		//Cargo direccion del origen y pongo esa direccion en la variable en memoria. La variable sera puntero a string.
		fprintf(arch, "LEA EAX, %s\nMOV %s, EAX", ts[origen].nombre, ts[destino].nombre);
	}

	fprintf(arch, "\n");
}

/** Levanta, da vuelta los elementos y compara */
void comparacion(FILE* arch, int ind){
	levantarEnPila(arch, ind);
	fprintf(arch, "FXCH\nFCOMP\nFSTSW AX\nSAHF\n");

}
/** Levanta, suma, y deja en pila */
void suma(FILE* arch, int ind){
	levantarEnPila(arch, ind);
	fprintf(arch, "FADD\n");
}
/** Levanta, revisa si hay dos operadores: Si hay uno, calcula el negativo. Si hay dos, resta y deja en pila*/
void resta(FILE* arch, int ind){
	if(lista_terceto[ind].op2==NOOP){
		int aux;
		if((aux = lista_terceto[ind].op1) < OFFSET){ //Es decir si está en la tabla
			switch((int)ts[aux].tipoDato){
				case INT:
					//FILD n; Donde n es el numero integer en memoria
					fprintf(arch, "FILD %s\n", ts[aux].nombre);
					break;
				case FLOAT:
					//FLD n; Donde n es el numero float en memoria
					fprintf(arch, "FLD %s\n", ts[aux].nombre);
					break;
				case CTE_INT:
					//FILD n;Donde n es el numero integer en tabla
					fprintf(arch, "FILD %s\n", ts[aux].nombre);
					break;
				case CTE_FLOAT:
					//FLD n;Donde n es el numero float en tabla
					fprintf(arch, "FLD %s\n", ts[aux].nombre);
					break;
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
	levantarEnPila(arch, ind);
	fprintf(arch, "FMUL\n");
}
/** Levanta, divide, si la cuenta era de enteros se asegura de truncar y deja en pila */
void division(FILE* arch, int ind){ //Mañana reviso, seguro acá distinguimos operación integer de flotante
	levantarEnPila(arch, ind);
	fprintf(arch, "FDIV\n");
}

/** Asegura que el elemento de la izquierda esté en st1, y el de la derecha en st0 */
void levantarEnPila(FILE* arch, const int ind){
	int elemIzq = lista_terceto[ind].op1;
	int elemDer = lista_terceto[ind].op2;
	int izqLevantado = 0;
	/* Si el elemento no está en pila lo levanta */
	if(elemIzq < OFFSET){
		switch((int)ts[elemIzq].tipoDato){
		case INT:
			//FILD n; Donde n es el numero integer en memoria
			fprintf(arch, "FILD %s\n", ts[elemIzq].nombre);
			break;
		case FLOAT:
			//FLD n; Donde n es el numero float en memoria
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
			break;
		case CTE_INT:
			//FILD n;Donde n es el numero integer en tabla
			fprintf(arch, "FILD %s\n", ts[elemIzq].nombre);
			break;
		case CTE_FLOAT:
			//FLD n;Donde n es el numero float en tabla
			fprintf(arch, "FLD %s\n", ts[elemIzq].nombre);
			break;
		}
		izqLevantado=1;
	}
	if(elemDer < OFFSET){
		switch((int)ts[elemDer].tipoDato){
		case INT:
			//FILD n; Donde n es el numero integer en memoria
			fprintf(arch, "FILD %s\n", ts[elemDer].nombre);
			break;
		case FLOAT:
			//FLD n; Donde n es el numero float en memoria
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
			break;
		case CTE_INT:
			//FILD n;Donde n es el numero integer en tabla
			fprintf(arch, "FILD %s\n", ts[elemDer].nombre);
			break;
		case CTE_FLOAT:
			//FLD n;Donde n es el numero float en tabla
			fprintf(arch, "FLD %s\n", ts[elemDer].nombre);
			break;
		}
		izqLevantado=0;
	}
	if(izqLevantado){
		fprintf(arch, "FXCH\n");
	}
}

void write(FILE* arch, int terceto){
	int ind = lista_terceto[terceto].op1; //Indice de entrada a tabla de simbolos del mensaje a mostrar
	switch((int)ts[ind].tipoDato){
	case INT:
		fprintf(arch, "DisplayInteger %s\n", ts[ind].nombre);
		fprintf(arch, "displayString NEW_LINE\n");
		break;
	case FLOAT:
		fprintf(arch, "DisplayFloat %s,2\n", ts[ind].nombre);
		fprintf(arch, "displayString NEW_LINE\n");
		break;
	case STRING:
		fprintf(arch, "MOV EBX, %s\ndisplayString [EBX]\n", ts[ind].nombre);
		fprintf(arch, "displayString NEW_LINE\n");
		break;
	case CTE_STRING:
		fprintf(arch, "displayString %s\n", ts[ind].nombre);
		fprintf(arch, "displayString NEW_LINE\n");
		break;
	}
	fprintf(arch, "\n");
}

void read(FILE* arch, int terceto){
	int ind = lista_terceto[terceto].op1;
	switch((int)ts[ind].tipoDato){
	case INT:
		fprintf(arch, "getInteger %s\n", ts[ind].nombre);
		break;
	case FLOAT:
		fprintf(arch, "getFloat %s\n", ts[ind].nombre);
		break;
	case STRING:
		fprintf(arch, "getString %s\n", ts[ind].nombre);

	}
	fprintf(arch, "\n");
}
