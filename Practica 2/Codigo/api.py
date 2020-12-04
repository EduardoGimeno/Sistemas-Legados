#!/usr/bin/env python3

import time
from py3270 import Emulator

### Parámetros generales ###

# Parámetros de conexión al mainframe a través del emulador
HOST = '155.210.152.51'
PORT = '104'
USER = 'grupo_12'
PASSWD = 'secreto6'

# Parámetros para controlar la GUI del emulador
DELAY = 0.2
SCREEN_WIDTH = 80
SCREEN_HEIGTH = 43

# Parámetros para controlar la lógica del programa
ADD_TASK = 1
VIEW_TASK = 2
GENERAL_TASK = 1
SPECIFIC_TASK = 2
MAIN_MENU = 3

# Declaración del emulador
em = Emulator(visible=True)

### Funciones ###

# Espera para que la pantalla este lista
def wait():
    em.wait_for_field()
    time.sleep(DELAY)

def waiter(func):
    def inner(*args, **kwargs):
        wait()
        res = func(*args, **kwargs)
        return res

    return inner

# Conexión al mainframe a través del emulador
def connect():
    address = HOST + ":" + PORT
    em.connect(address)

# Desconexión del mainframe a través del emulador
def disconnect():
    em.terminate()

# Iniciar sesión en el mainframe
@waiter
def login():
    # Se completan los campos en la terminal rellenando los pixeles concretos
    # y se pulsa enter
    em.fill_field(3, 18, USER, 8)
    em.fill_field(5, 18, PASSWD, 8)
    em.send_enter()

# Ejecución en el mainframe del fichero tareas.c
@waiter
def execProgram():
    # Se completan los campos en la terminal rellenando los pixeles concretos
    # y se pulsa enter
    em.fill_field(3, 15, 'tareas.c', 8)
    em.send_enter()

# Esperar a que el programa comience la ejecución
def waitCompile():
    # Se espera a que en la terminal aparezca en la parte inferior
    # izquierda la palabra Reading, la cual indica que el programa
    # está listo
    while em.string_get(43, 71, 7) != 'Reading':
        pass

# Para poder capturar la salida en unas posiciones fijas de la pantalla,
# se pulsa enter repetidas veces hasta que la pantalla de la terminal se llena,
# apareciendo en la esquina inferior izquierda la palabra More...
@waiter
def clean():
    while em.string_get(43, 71, 7) != 'More...':
        em.send_enter()
        wait()
    em.send_enter()

def cleaner(func):
    def inner(*args, **kwargs):
        clean()
        res = func(*args, **kwargs)
        return res

    return inner

# Introducir un parámetro en la terminal
@waiter
def inputParam(input):
    # Se formatea input para obtener el valor de la variable
    # y se pulsa enter
    em.send_string(f'{input}')
    em.send_enter()

# Para simplificar el trabajo con una GUI nueva, cuando se finaliza una acción
# se vuelve a mostrar el menú principal
def backMenu(func):
    def inner(*args, **kwargs):
        res = func(*args, **kwargs)
        inputParam(MAIN_MENU)
        return res

    return inner

# Añadir una nueva tarea
@backMenu
@cleaner
def addT(taskType, day, month, description, name=None):
    # Seleccionar añadir tarea
    inputParam(ADD_TASK)
    # Seleccionar tipo de tarea
    inputParam(taskType)
    # Adaptar el día y la fecha al formato requerido en la terminal
    date = str(day).zfill(2) + str(month).zfill(2)
    inputParam(date)
    # Si es una tarea específica, se intorduce el nombre, por defecto el
    # parámetro name tiene el valor none, en caso de ser una tarea específica
    # contendrá otro valor
    if taskType == SPECIFIC_TASK:
        inputParam(name)
    # Introducir la descripción
    inputParam(description)

# Listar las tareas en función del tipo
@backMenu
@cleaner
def listT(taskType):
    taskList = []
    # Seleccionar listar tareas
    inputParam(VIEW_TASK)
    # Seleccionar el tipo de tarea
    inputParam(taskType)
    wait()

    # Si la pantalla ha sido limpiada la primera línea para leer
    # será la 9, si no la 8
    if em.string_get(1, 1, 1) == ' ':
        firstLine = 9
    else:
        firstLine = 8

    i = 1
    line = em.string_get(firstLine, 1, SCREEN_WIDTH).strip()

    # Mientras no se llegue al final del listado, comenzado por la
    # palabra TOTAL
    while line[0:5] != 'TOTAL':
        # Si la línea comienza por la palabra TASK es una tarea
        if line[0:4] == 'TASK':
            taskList += [line]
        line = em.string_get(firstLine + i, 1, SCREEN_WIDTH).strip()
        i += 1

    # Se compone la lista que se devolverá
    taskListFinal = [
        {
            'id': param[1],
            'type': param[2],
            'date': param[3],
            'name': param[4],
            'desc': param[5]
        }
        for param in [line.split() for line in taskList]
    ]

    return taskListFinal

# Proceso de inicialización desde la conexión con el mainframe hasta que
# se puede empezar a utilizar el programa tareas.c
def initialize():
    connect()
    em.send_enter()
    login()
    em.send_enter()
    execProgram()
    waitCompile()
