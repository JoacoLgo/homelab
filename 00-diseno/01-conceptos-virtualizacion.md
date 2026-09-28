# Conceptos de virtualización

**Paso 1 del plan** · Escrito con palabras propias, sin copiar de ninguna fuente.

---

## 1. Hipervisor tipo 1 vs. tipo 2

El hipervisor es un software que reparte el hardware entre máquinas virtuales. El hipervisor puede ser de tipo 1, donde es el principal software después del hardware: corre directo, sin ningún SO abajo de él. Acá entran Hyper-V, Proxmox, etc. Luego tenemos el tipo 2, que es un programa corriendo dentro de un SO, creando ahí las VM y pidiendo permisos. Acá entran UTM, VirtualBox, etc.

Hyper-V es un hipervisor de tipo 1 aunque parezca de tipo 2, por abrirse como una aplicación desde el mismo Windows: en realidad está por debajo del sistema operativo.

## 2. Qué es una VM en el disco

Una VM en el disco es una representación digital de un equipo físico que utiliza algún tipo de software.

Tener una máquina virtual es tener archivos en el disco. Que exista una carpeta no significa que haya una VM: hace falta además que el hipervisor la tenga registrada en su inventario. Cada carpeta tiene archivos con extensiones que marcan una parte de la VM: el `.vhdx` es el disco rígido virtual; el `.vmcx` contiene la configuración, como la RAM y los vCPU; y después están el `.vmgs` (solo en las de generación 2), el `.vmrs` y, en algunos casos, el `.avhdx` (disco diferencial, cuando se le hizo un checkpoint).

## 3. Tipos de switch virtual

- **Private:** las VM hablan únicamente entre sí, las que tengan ese mismo switch. No hablan con el host ni con otro switch.
- **Internal:** es igual que el private, pero este sí puede hablar con el host.
- **External:** se conecta a una placa real y la VM puede salir a la red donde se encuentre físicamente.
- **Default Switch:** es idéntico al internal, pero con NAT y DHCP que administra Windows.

Los cuatro switches que utilizamos son private, así que son como cuatro islas: por eso necesitamos una VM router con una placa en cada una.

## 4. Generación 1 vs. Generación 2

Las generaciones vienen de cuál va a ser el gestor de arranque: generación 1 (BIOS, el primero que salió, universal) y generación 2 (UEFI, más moderno). Elegir cuál vamos a colocar implica saber qué vamos a utilizar: si un SO más viejo, o uno con ciertas características que haga aceptar a uno o a otro.

La diferencia de rendimiento viene por el tipo de dispositivos. Los dispositivos emulados usan drivers genéricos y todo lo que se hace se manda a una placa imaginaria, lo cual obliga al hipervisor a interceptar y traducir constantemente: el sistema invitado no sabe que es una VM. Los dispositivos sintéticos, en cambio, saben que están en una VM y hablan directo con el host, así que rinden más. La generación 1 soporta las dos cosas —usa los sintéticos si tiene instalados los Integration Services—, mientras que la generación 2 directamente eliminó todo el hardware emulado.

Una vez creada la VM con una u otra generación, esto es irreversible: no existe forma de cambiarlo sin rehacer la VM desde cero. Esto se va a ver reflejado cuando creemos la VM de pfSense, que no arranca con generación 2 porque lleva FreeBSD y no se lleva bien con ese UEFI.

## 5. Memoria estática vs. memoria dinámica

La memoria estática es aquella que le asignamos a una VM para que tenga siempre. Esta memoria no se altera: si le asignamos 4 GB, va a tener esos 4 GB siempre disponibles, aunque esté usando 1 GB.

La dinámica, en cambio, se define con tres valores: un mínimo, que es el piso; un startup, que es con lo que arranca; y un máximo, que es el techo de la VM. Siendo dinámica, la RAM disponible va a estar en ese rango. Que tenga un máximo no significa que vaya a poder usarlo si hay otras VM que estén utilizando más: en ese caso van a estar peleándose por quién lo necesita.

## 6. Checkpoints y discos diferenciales

Un checkpoint es un punto de retorno que se crea, haciendo un archivo `.avhdx` para poder regresar en caso de ser necesario y así no romper nada de lo que ya funciona. A partir del punto en que se crea, todo lo que se hace en la VM se escribe en ese archivo y no en el `.vhdx` (el disco rígido de la VM). Este `.avhdx` depende de su antecesor, ya que es como una rama: en cuanto suceda algo con el `.vhdx`, como su eliminación, el `.avhdx` queda inservible. Y en caso de sacar el `.vhdx` y no restaurarlo con el `.avhdx`, no va a ser la VM completa, sino solo aquello que separamos en el momento de crear el checkpoint.

El checkpoint estándar guarda el estado de la memoria: al restaurar, la VM vuelve a como estaba, con los procesos corriendo. Es cómodo, pero para un servidor con base de datos es un problema, ya que revive con conexiones muertas y el reloj atrasado. El checkpoint de producción usa VSS adentro del sistema operativo invitado para pedirle a las aplicaciones que dejen todo consistente antes de sacar la foto; al restaurar, la VM arranca como si se hubiera apagado bien.
