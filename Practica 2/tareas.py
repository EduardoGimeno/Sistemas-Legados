#!/usr/bin/env python3
from tkinter import *
# tkinter es una libreria de interfaces graficas con usuario
from api import initialize, disconnect, add_task, TASK_GENERAL, TASK_SPECIFIC, list_tasks

root = Tk()

# FRAMES #
# Listas
frameLists = Frame(root)
frameLists.pack(side=LEFT)
frameListGeneral = Frame(frameLists)
frameListGeneral.pack(side=TOP)
frameListSpecific = Frame(frameLists)
frameListSpecific.pack(side=TOP)
frameAdd = Frame(root)
frameAdd.pack(side=RIGHT)
frameChooseType = Frame(frameAdd)
frameChooseType.pack(side=TOP)
# Fecha
frameAddDay = Frame(frameAdd)
frameAddDay.pack(side=TOP)
frameAddMonth = Frame(frameAdd)
frameAddMonth.pack(side=TOP)
# Nombre
frameAddName = Frame(frameAdd)
frameAddName.pack(side=TOP)
# Desc
frameAddDesc = Frame(frameAdd)
frameAddDesc.pack(side=TOP)


def convertir_lista_string(lista_tareas):
    tareas = ''
    for tarea in lista_tareas:
        id = tarea['id']
        fecha = tarea['date']
        nombre = tarea['name']
        descripcion = tarea['desc']
        tareas += f'{id}\t{fecha}\t{nombre}\t{descripcion}\n'
    return tareas


# Lista de tareas generales
stringLabelListGeneral = StringVar()
stringLabelListGeneral.set('Tareas generales')
labelListGeneral = Label(
    frameListGeneral,
    textvariable=stringLabelListGeneral,
    relief=RAISED
)
labelListGeneral.pack(side=TOP)
textListGeneral = Text(frameListGeneral)
textListGeneral.pack()

# Lista de tareas especificas
stringLabelListSpecific = StringVar()
stringLabelListSpecific.set('Tareas especificas')
labelListSpecific = Label(
    frameListSpecific,
    textvariable=stringLabelListSpecific,
    relief=RAISED
)
labelListSpecific.pack(side=TOP)
textListSpecific = Text(frameListSpecific)
textListSpecific.pack()

# Anadir tareas nuevas
varType = IntVar()
radioGeneral = Radiobutton(frameChooseType, text="General", variable=varType, value=TASK_GENERAL)
radioGeneral.pack(anchor=W, side=LEFT)
radioSpecific = Radiobutton(frameChooseType, text="Especifica", variable=varType, value=TASK_SPECIFIC)
radioSpecific.pack(anchor=W, side=RIGHT)
labelAddDay = Label(frameAddDay, text="Dia")
labelAddDay.pack(side=LEFT)
entryAddDay = Entry(frameAddDay, bd=5)
entryAddDay.pack(side=RIGHT)
labelAddMonth = Label(frameAddMonth, text="Mes")
labelAddMonth.pack(side=LEFT)
entryAddMonth = Entry(frameAddMonth, bd=5)
entryAddMonth.pack(side=RIGHT)
labelAddName = Label(frameAddName, text="Nombre de la tarea")
labelAddName.pack(side=LEFT)
entryAddName = Entry(frameAddName, bd=5)
entryAddName.pack(side=RIGHT)
labelAddDesc = Label(frameAddDesc, text="Descripcion")
labelAddDesc.pack(side=LEFT)
entryAddDesc = Entry(frameAddDesc, bd=5)
entryAddDesc.pack(side=RIGHT)


def callbackAddTask():
    add_task(
        varType.get(),
        entryAddDay.get(),
        entryAddMonth.get(),
        entryAddDesc.get(),
        entryAddName.get()
    )
    textListGeneral.delete(1.0, END)
    textListSpecific.delete(1.0, END)
    textListGeneral.insert(INSERT, convertir_lista_string(list_tasks(TASK_GENERAL)))
    textListSpecific.insert(INSERT, convertir_lista_string(list_tasks(TASK_SPECIFIC)))


buttonAddTask = Button(frameAdd, text="Add", command=callbackAddTask)

buttonAddTask.pack()

if __name__ == "__main__":
    initialize()
    root.mainloop()
    disconnect()
