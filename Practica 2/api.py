#!/usr/bin/env python3

import time
from py3270 import Emulator

# https://pypi.org/project/py3270/
###### CONEXION WX3270 #######

HOST = '155.210.152.51'
PORT = '104'
USER = 'grupo_12'
PASSWD = 'secreto6'

###### PARAMETROS INTERFAZ GRAFICA #######
DELAY = 0.1
SCREEN_WIDTH = 80
SCREEN_HEIGTH = 43

###### VARIABLES PROGRAMA ######

ADD_TASK = 1
VIEW_TASK = 2
TASK_GENERAL = 1
TASK_SPECIFIC = 2
MAIN_MENU = 3

em = Emulator(visible=True)


###### FUNCIONES PROGRAMA ######

# espera antes de cada ejecucion de funcion para que no haya
# perdida de datos
def wait_screen():
    em.wait_for_field()
    time.sleep(DELAY)


def waiter(func):
    def inner(*args, **kwargs):
        wait_screen()
        res = func(*args, **kwargs)
        return res

    return inner


def connect():
    em.connect(f'{HOST, PORT}')


def disconnect():
    em.terminate()


@waiter
def login():
    em.fill_field(3, 18, USER, 8)
    em.fill_field(5, 18, PASSWD, 8)
    em.send_enter()


@waiter
def exec_task():
    em.fill_field(3, 15, 'tareas.c', 8)
    em.send_enter()


@waiter
def print_screen():
    print('*~' * 40)
    for i in range(SCREEN_HEIGTH):
        print(em.string_get(i + 1, 1, SCREEN_WIDTH))
    print('*~' * 40)


def wait_compile():
    while em.string_get(43, 71, 7) != 'Reading':
        pass


@waiter
def clean_screen():
    while em.string_get(43, 71, 7) != 'More...':
        em.send_enter()
        wait_screen()
    em.send_enter()


def pre_cleaner(func):
    def inner(*args, **kwargs):
        clean_screen()
        res = func(*args, **kwargs)
        return res

    return inner


@waiter
def input_option(input):
    em.send_string(f'{input}')
    em.send_enter()


def initialize():
    connect()
    em.send_enter()
    login()
    em.send_enter()
    exec_task()
    wait_compile()


# Por simplicidad, cada vez que se termina una acción, se vuelve
# al menú principal
def back_on_finish(func):
    def inner(*args, **kwargs):
        res = func(*args, **kwargs)
        input_option(MAIN_MENU)
        return res

    return inner


@back_on_finish
@pre_cleaner
def add_task(task_type, day, month, description, name=None):
    input_option(ADD_TASK)
    input_option(task_type)
    date = str(day).zfill(2) + str(month).zfill(2)
    input_option(date)
    if task_type == TASK_SPECIFIC:
        input_option(name)
    input_option(description)


@back_on_finish
@pre_cleaner
def list_tasks(task_type):
    task_list = []
    input_option(VIEW_TASK)
    input_option(task_type)
    wait_screen()

    if em.string_get(1, 1, 1) == ' ':
        first_line = 9
    else:
        first_line = 8

    i = 1
    line = em.string_get(first_line, 1, SCREEN_WIDTH).strip()

    while line[0:5] != 'TOTAL':
        if line[0:4] == 'TASK':
            task_list += [line]
        else:
            task_list[-1] += line
        line = em.string_get(first_line + i, 1, SCREEN_WIDTH).strip()
        i += 1

    task_dict_list = [
        {
            'id': frags[1][:-1],
            'type': frags[2],
            'date': frags[3],
            'name': frags[4],
            'desc': frags[5]
        }
        for frags in [line.split() for line in task_list]
    ]

    return task_dict_list


# Si se ejecuta el módulo directamente, prueba a insertar
# y listar tareas
if __name__ == "__main__":
    print('Initializing...')
    initialize()
    print('Initialized')
    add_task(TASK_GENERAL, 3, 10, 'Tarea1')
    print('Task added')
    add_task(TASK_GENERAL, 8, 11, 'Tarea2')
    print('Task added')
    add_task(TASK_GENERAL, 8, 11, 'Tarea3')
    print('Task added')
    add_task(TASK_GENERAL, 8, 11, 'Tarea4')
    print('Task added')
    add_task(TASK_GENERAL, 8, 11, 'Tarea5')
    print('Task added')
    add_task(TASK_SPECIFIC, 3, 10, 'TareaSpecific1', 'Nombre1')
    print('Task added')
    add_task(TASK_SPECIFIC, 3, 10, 'TareaSpecific2', 'Nombre2')
    print('Task added')
    add_task(TASK_SPECIFIC, 3, 10, 'TareaSpecific3', 'Nombre3')
    print('Task added')
    add_task(TASK_SPECIFIC, 3, 10, 'TareaSpecific4', 'Nombre4')
    print('Tasks added')
    g_tasks = list_tasks(TASK_GENERAL)
    s_tasks = list_tasks(TASK_SPECIFIC)
    print('Showing general tasks:')
    for task in g_tasks:
        print(task)
    print('Showing specific tasks:')
    for task in s_tasks:
        print(task)
    disconnect()
