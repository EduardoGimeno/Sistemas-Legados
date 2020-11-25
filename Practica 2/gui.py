#!/usr/bin/env python3
from tkinter import *
from api import initialize, disconnect, add_task, TASK_GENERAL, TASK_SPECIFIC, list_tasks

root = Tk()
root.config(width=300, height=200)

# Organización de la pantalla en frames
# Frames para las listas de tareas
frameLists = Frame(root)
frameLists.pack(side=TOP)
frameListGeneral = Frame(frameLists)
frameListGeneral.pack(side=LEFT)
frameListSpecific = Frame(frameLists)
frameListSpecific.pack(side=RIGHT)
# Frame para el tipo de tarea
frameAdd = Frame(root)
frameAdd.pack(side=BOTTOM)
frameChooseType = Frame(frameAdd)
frameChooseType.pack(side=TOP)
# Frames para el día y mes
frameAddDay = Frame(frameAdd)
frameAddDay.pack(side=TOP)
frameAddMonth = Frame(frameAdd)
frameAddMonth.pack(side=TOP)
# Frame para el nombre
frameAddName = Frame(frameAdd)
frameAddName.pack(side=TOP)
# Frame para la descripción
frameAddDesc = Frame(frameAdd)
frameAddDesc.pack(side=TOP)

# Función para parsear el listado de tareas recibido del mainframe
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
labelListGeneral.config(fg="green",
                        font=("Verdana", 12))
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
labelListSpecific.config(fg="green",
                         font=("Verdana", 12))
textListSpecific = Text(frameListSpecific)
textListSpecific.pack()

# Campos a introducir para las nuevas tareas
# Tipo de tarea
varType = IntVar()
radioGeneral = Radiobutton(frameChooseType, text="General", variable=varType, value=TASK_GENERAL, fg="green",
                           font=("Verdana", 10))
radioGeneral.pack(anchor=W, side=LEFT)
radioSpecific = Radiobutton(frameChooseType, text="Especifica", variable=varType, value=TASK_SPECIFIC, fg="green",
                            font=("Verdana", 10))
radioSpecific.pack(anchor=W, side=RIGHT)
# Día
labelAddDay = Label(frameAddDay, text="Dia")
labelAddDay.pack(side=LEFT)
labelAddDay.config(fg="green",
                   font=("Verdana", 12))
entryAddDay = Entry(frameAddDay, width=2, bd=5)
entryAddDay.pack(side=RIGHT)
# Mes
labelAddMonth = Label(frameAddMonth, text="Mes")
labelAddMonth.pack(side=LEFT)
labelAddMonth.config(fg="green",
                     font=("Verdana", 12))
entryAddMonth = Entry(frameAddMonth, width=2, bd=5)
entryAddMonth.pack(side=RIGHT)
# Nombre
labelAddName = Label(frameAddName, text="Nombre")
labelAddName.pack(side=LEFT)
labelAddName.config(fg="green",
                    font=("Verdana", 12))
entryAddName = Entry(frameAddName, width=25, bd=5)
entryAddName.pack(side=RIGHT)
# Descripción
labelAddDesc = Label(frameAddDesc, text="Descripcion")
labelAddDesc.pack(side=LEFT)
labelAddDesc.config(fg="green",
                    font=("Verdana", 12))
entryAddDesc = Entry(frameAddDesc,  width=50, bd=5)
entryAddDesc.pack(side=RIGHT)

# Función invocada al pulsar el botón para añadir una nueva tarea,
# Lee los campos para guardar la nueva tarea en el mainframe,
# borra el contenido actual de las listas para volver a mostrarlo
# recibiéndolo del mainframe y parseando el resultado 
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

# Botón para añadir la nueva tarea
buttonAddTask = Button(frameAdd, text="Anadir", fg="green", command=callbackAddTask)
buttonAddTask.pack()

if __name__ == "__main__":
    initialize()
    root.mainloop()
    disconnect()
