#include "TablaSimbolos.h"

typedef struct s_nodo {
    struct s_nodo* sig;
    char dato[200];
    int nro;
} s_nodo;

typedef struct {
    s_nodo* frente;
    s_nodo* final;
} t_cola;

/* Funciones */

void crear_cola(t_cola*);
int encolar(t_cola*, int);
int cola_vacia(t_cola*);
void vaciar_cola(t_cola*);


void crear_cola(t_cola* c) {
    c->frente = NULL;
    c->final = NULL;
}

int encolar(t_cola* c, int nro) {
    s_nodo* nuevo = (s_nodo*)malloc(sizeof(s_nodo));

    if (!nuevo) {
        printf("No se pudo reservar memoria\n");
        return 0;
    }

    nuevo->nro = nro;
    nuevo->sig = NULL;

    if (c->final == NULL) {
        // La cola está vacía
        c->frente = nuevo;
        c->final = nuevo;
    } else {
        // Agregar al final de la cola
        c->final->sig = nuevo;
        c->final = nuevo;
    }

    return 1;
}

int desencolarEntero(t_cola* c) {
    s_nodo* viejo;
    int retorno = 0;

    if (c->frente == NULL) {
        // La cola está vacía
        return 0;
    }

    viejo = c->frente;
    retorno = viejo->nro;

    c->frente = viejo->sig;
    free(viejo);

    if (c->frente == NULL) {
        // Si la cola quedó vacía, actualizar el puntero final
        c->final = NULL;
    }

    return retorno;
}


int desencolar(t_cola* c, int* nro) {
    s_nodo* viejo;

    if (c->frente == NULL) {
        // La cola está vacía
        return 0;
    }

    viejo = c->frente;
    *nro = viejo->nro;

    c->frente = viejo->sig;
    free(viejo);

    if (c->frente == NULL) {
        // Si la cola quedó vacía, actualizar el puntero final
        c->final = NULL;
    }

    return 1;
}


int cola_vacia(t_cola* c) {
    return c->frente == NULL;
}

void vaciar_cola(t_cola* c) {
    s_nodo* actual = c->frente;
    s_nodo* siguiente;

    while (actual != NULL) {
        siguiente = actual->sig;
        free(actual);
        actual = siguiente;
    }

    c->frente = NULL;
    c->final = NULL;
}

int verFrente(t_cola* c, int* nro) {
    if (c->frente == NULL) {
        // La cola está vacía
        return 0;
    }

    *nro = c->frente->nro;

    return 1;
}