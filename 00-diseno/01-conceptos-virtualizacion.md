# Conceptos de virtualización

**Paso 1 del plan** · Escrito con palabras propias, sin copiar de ninguna fuente.

---

## 1. Hipervisor tipo 1 vs. tipo 2
    El hipervisor es un software que reparte el hardware enter maquinas virtuales. El hipervisor puede ser de tipo 1 donde es el principal sofware despues del hardward, corre directo sin nigun SO abajo de el, aca entra el hyper-v, proxmox, etc; Luego tenemos el tipo 2 que es un programa corriendo dentor de un SO creando ahi las vm y pidiendo permisos, aca entran UTM, VirtualBox, etc.

## 2. Qué es una VM en el disco
    Una VM en el disco es una representacion digital de un equipo fisico que utiliza algun tipo de software

## 3. Tipos de switch virtual
    Private: Las VM hablan unicamante entre si (las que tengan switch private, no con el host ni con otra).
    Internal: Es igual que la private pero esta si puede hablar con el host.
    External: Se conecta a una placa real y puede salir la VM a la red de donde se encuentre fisicamante.
    Default Switch: Es identico de Internal pero con NAT y DHCP que administra Windows. 

## 4. Generación 1 vs. Generación 2
    

## 5. Memoria estática vs. memoria dinámica

## 6. Checkpoints y discos diferenciales
