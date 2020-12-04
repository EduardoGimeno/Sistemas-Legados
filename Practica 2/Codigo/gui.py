#!/usr/bin/env python3
from tkinter import *
from api import initialize, disconnect, addT, listT, GENERAL_TASK, SPECIFIC_TASK

root = Tk()
root.config(width=300, height=200)

# Organización de la pantalla en frames
# Frames para las listas de tareas
frameL = Frame(root)
frameL.pack(side=TOP)
frameLG = Frame(frameL)
frameLG.pack(side=LEFT)
frameLS = Frame(frameL)
frameLS.pack(side=RIGHT)
# Frame para el tipo de tarea
frameTask = Frame(root)
frameTask.pack(side=BOTTOM)
frameType = Frame(frameTask)
frameType.pack(side=TOP)
# Frames para el día y mes
frameTDay = Frame(frameTask)
frameTDay.pack(side=TOP)
frameTMonth = Frame(frameTask)
frameTMonth.pack(side=TOP)
# Frame para el nombre
frameTName = Frame(frameTask)
frameTName.pack(side=TOP)
# Frame para la descripción
frameTDesc = Frame(frameTask)
frameTDesc.pack(side=TOP)

# Lista de tareas generales
titleLabelLG = StringVar()
titleLabelLG.set('Tareas generales')
labelLG = Label(
    frameLG,
    textvariable=titleLabelLG,
    relief=RAISED
)
labelLG.pack(side=TOP)
labelLG.config(fg="green",
               font=("Verdana", 12))
textLG = Text(frameLG)
textLG.pack()

# Lista de tareas especificas
titleLabelLS = StringVar()
titleLabelLS.set('Tareas especificas')
labelLS = Label(
    frameLS,
    textvariable=titleLabelLS,
    relief=RAISED
)
labelLS.pack(side=TOP)
labelLS.config(fg="green",
               font=("Verdana", 12))
textLS = Text(frameLS)
textLS.pack()

# Campos a introducir para las nuevas tareas
# Tipo de tarea
taskType = IntVar()
radioG = Radiobutton(frameType, text="General", variable=taskType, value=GENERAL_TASK, fg="green",
                           font=("Verdana", 10))
radioG.pack(anchor=W, side=LEFT)
radioS = Radiobutton(frameType, text="Especifica", variable=taskType, value=SPECIFIC_TASK, fg="green",
                            font=("Verdana", 10))
radioS.pack(anchor=W, side=RIGHT)
# Día
labelTDay = Label(frameTDay, text="Dia")
labelTDay.pack(side=LEFT)
labelTDay.config(fg="green",
                   font=("Verdana", 12))
entryTDay = Entry(frameTDay, width=2, bd=5)
entryTDay.pack(side=RIGHT)
# Mes
labelTMonth = Label(frameTMonth, text="Mes")
labelTMonth.pack(side=LEFT)
labelTMonth.config(fg="green",
                     font=("Verdana", 12))
entryTMonth = Entry(frameTMonth, width=2, bd=5)
entryTMonth.pack(side=RIGHT)
# Nombre
labelTName = Label(frameTName, text="Nombre")
labelTName.pack(side=LEFT)
labelTName.config(fg="green",
                    font=("Verdana", 12))
entryTName = Entry(frameTName, width=25, bd=5)
entryTName.pack(side=RIGHT)
# Descripción
labelTDesc = Label(frameTDesc, text="Descripcion")
labelTDesc.pack(side=LEFT)
labelTDesc.config(fg="green",
                    font=("Verdana", 12))
entryTDesc = Entry(frameTDesc,  width=50, bd=5)
entryTDesc.pack(side=RIGHT)

# Función para parsear el listado de tareas recibido del mainframe
def convertirLista(listaTareas):
    tareas = ''
    for tarea in listaTareas:
        id = tarea['id']
        fecha = tarea['date']
        nombre = tarea['name']
        descripcion = tarea['desc']
        tareas += f'{id}\t{fecha}\t{nombre}\t{descripcion}\n'
    return tareas

# Función invocada al pulsar el botón para añadir una nueva tarea,
# Lee los campos para guardar la nueva tarea en el mainframe,
# borra el contenido actual de las listas para volver a mostrarlo
# recibiéndolo del mainframe y parseando el resultado 
def addTask():
    addT(
        taskType.get(),
        entryTDay.get(),
        entryTMonth.get(),
        entryTDesc.get(),
        entryTName.get()
    )
    textLG.delete(1.0, END)
    textLS.delete(1.0, END)
    textLG.insert(INSERT, convertirLista(listT(GENERAL_TASK)))
    textLS.insert(INSERT, convertirLista(listT(SPECIFIC_TASK)))

# Botón para añadir la nueva tarea
buttonTask = Button(frameTask, text="Anadir", fg="green", command=addTask)
buttonTask.pack()

if __name__ == "__main__":
    initialize()
    root.mainloop()
    disconnect()
