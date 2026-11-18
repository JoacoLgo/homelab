# Migrar SQL Server 2022 Express con FILESTREAM a una VM

**Caso real** · Migración de una base de datos de un servidor físico a una VM en Proxmox

---

## Qué problema resuelve

Había que mover una base de **SQL Server 2022 Express** a una máquina virtual en **Proxmox**. La base
usa **FILESTREAM**: los archivos adjuntos no están adentro de la base sino en una carpeta del disco
que SQL Server administra. Si la migración no se lleva esos archivos, la base queda con referencias
a documentos que no existen.

## Cómo lo abordé

Elegí un **backup nativo `.BAK`** y un **restore** en el servidor nuevo, en lugar de copiar los
archivos `.mdf` y `.ldf` a mano:

- El `.BAK` nativo incluye los datos de FILESTREAM. Copiar archivos sueltos obliga a mover la
  carpeta de FILESTREAM por separado y a reengancharla.
- El restore deja la base consistente, y con `RESTORE ... WITH MOVE` se pueden cambiar las rutas
  de los archivos en el servidor nuevo.
- En el servidor nuevo **FILESTREAM tiene que estar habilitado a nivel de instancia antes del
  restore**. Si no, el restore falla.

## Qué se rompió

El primer intento fue un backup comprimido:

```sql
BACKUP DATABASE ... TO DISK = '...bak' WITH COMPRESSION;
```

```
Msg 1844: BACKUP DATABASE WITH COMPRESSION is not supported on Express Edition.
```

**La compresión de backups no existe en la edición Express.** Es una de las limitaciones de la
edición gratuita, junto con el tope de tamaño por base y la falta del SQL Server Agent para
programar tareas.

## Cómo lo resolví

Hice el backup **sin `WITH COMPRESSION`** y lo restauré en la VM.

## Cómo lo verifiqué

- El restore terminó sin errores.
- La base quedó en línea y la aplicación funcionó contra el servidor nuevo.
- Los documentos guardados con FILESTREAM se abrían desde la aplicación.

## Qué aprendí

- **Antes de migrar, revisar las limitaciones de la edición**, no solo la versión: Express y
  Standard aceptan opciones distintas.
- Con FILESTREAM, el backup nativo es la forma más segura de que los archivos viajen con la base.
- Un backup no está probado hasta que se restaura. La migración fue, de hecho, la prueba de restore.
