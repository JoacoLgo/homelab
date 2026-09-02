# Conceptos de virtualización

**Paso 1 del plan** · Escrito con palabras propias, sin copiar de ninguna fuente.

---

## 1. Hipervisor tipo 1 vs. tipo 2
El hipervisor es un software que reparte el hardware enter maquinas virtuales. El hipervisor puede ser de tipo 1 donde es el principal sofware despues del hardward, corre directo sin nigun SO abajo de el, aca entra el hyper-v, proxmox, etc; Luego tenemos el tipo 2 que es un programa corriendo dentor de un SO creando ahi las vm y pidiendo permisos, aca entran UTM, VirtualBox, etc.
Hyper-V es un hipervisor de tipo 1 aunque parezca 2 por abrirse como una aplicacion desde el mismo windows, este esta por debajo del sistema operativo.
## 2. Qué es una VM en el disco
Una VM en el disco es una representacion digital de un equipo fisico que utiliza algun tipo de software.
Tener una maquina virtual es tener archivos en el disco, no significa que una carpeta es una vm sino que el hipervisor puede ver el inventario de estas. Cada carpeta tiene archivos con extenciones que marcan un punto de la vm, como lo es el .vhdx que es el disco rigido virtual, .vmcx contiene la configuracion como la ram, vCPU, etc y luego .vmgs (solo los generacion 2), .vmrs y en algunos casos .avhdx (disco diferencias en caso de hacerle un chekpoint).

## 3. Tipos de switch virtual
Private: Las VM hablan unicamante entre si (las que tengan switch private, no con el host ni con otra). Internal: Es igual que la private pero esta si puede hablar con el host. External: Se conecta a una placa real y puede salir la VM a la red de donde se encuentre fisicamante. Default Switch: Es identico de Internal pero con NAT y DHCP que administra Windows. Los 4 switches que utilizamos son private, son como 4 islas y por eso necesitamos una vm router con una placa de cada una.

## 4. Generación 1 vs. Generación 2
Las generaciones vienen de cual va a ser el gestor de arranque, generacion 1 (BIOS el primero que salio, universal y arranque emulado) y generacion 2 (UEFI mas moderno 2010, arranque sintetico). Elegir cual vamos a colocar implica saber que vamosa autilizar si un SO mas viejo o con ciertas caracteristicas que haga aceptar a uno o otro, dependiendo cual coloquemos va a depender el rendimiento de la vm, gen 1 al ser emulado usa driver de siempre y todo lo que se haga siempre se manda a la placa de red imaginaria lo cual hace que el hipervisor tenga que inteceptar y traducir constantemente, no sabe que es una vm, la gen 2 con arranque sintetico sabe que es una vm y habla directo con el host haciendo que exista mayor rendimiento. Una vez creada la vm con una o otra generacion, esto es irreversible, no existe forma de cambiarlo sin rehacer la vm desde cero. Esto se va a ver reflejado cuando creemos la vm de pfsense que no arranca con Generacion 2 porque lleva FreeBSD y no se lleva con UEFI.

## 5. Memoria estática vs. memoria dinámica
La memoria estatica es aquella que le asignamos a una vm para que tenga, esta memoria no se altera, si le asignamos 4GB va a tener eso 4GB siempre disponible, asi este usando 1GB. La dinamica por otro lado se le asignara una minimo que sera el piso, starup que va a ser con lo que arranque y un maximo el techo de la vm, siendo dinamica la ram disponible estara en ese rango, que tenga un maximo no significa que vaya a poder usarlo si hay otras vm que esten utilizando mas, en este caso van a estar pelandose por quien lo necesita.  

## 6. Checkpoints y discos diferenciales
Este es un punto de retorno que se crea, haciendo un archivo .avhdx para poder regresar en caso de ser necesario y asi no romper nada de lo que ya funciona. A partir del punto en que se crea todo lo que se hace en la vm se copia en ese archivo y no en el .vhdx (disco rigido de la vm), este .avhdx depende de su antecesor ya que es como una rama, en cuando suceda algo con el .vdhx como su eliminacion el .avhdx queda inservible, o en caso de sacar el .vhdx y no lo restauramos con con el .avhdx no sera la vm completa, solo quello que separamos en el momento de crear el checkpoint. Checkpoint estandar guarda el estado de la memoria, al resturar la vm vuelve a como estaba con los procesos corriendo. Comodo pero para un servidor con base de dato es un problema ya que revive con conexiones muertas y el reloj atrasado. Checkpoint de produccion usa VSS adento del sistema operativo invitado para pedirles alas aplicaciones que dejen todo consistente antes de sacar la foto, al restaurar la vm arranca como si se hubiera pagado bien.