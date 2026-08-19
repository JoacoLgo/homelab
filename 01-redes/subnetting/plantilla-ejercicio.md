# Ejercicio de subnetting — NN

**Enunciado:** dada la red `X.X.X.X/YY`, obtener ...
**Tiempo:** MM:SS *(objetivo: menos de 60 segundos)*

---

## Procedimiento

**1. Máscara en binario y bits de host**

```
/YY  →  255.255.___.___
Bits de host: 32 − YY = __
```

**2. Tamaño del bloque**

```
2^(bits de host) = ___ direcciones por subred
Salto en el octeto interesante: ___
```

**3. Dirección de red**

```
```

**4. Primer host / último host / broadcast**

```
Primer host:
Último host:
Broadcast:
```

**5. Hosts útiles**

```
2^(bits de host) − 2 = ___
```

---

## Verificación

Comprobado con `ipcalc` / subnettingpractice.com: ✅ / ❌

## Dónde me trabé

*(Si salió al primer intento, escribí "sin problemas". Si no, anotá exactamente qué te confundió.
Esa lista es la que te va a servir para repasar.)*
