# Guía rápida de TargetBridge Intel Sender

Esta guía utiliza el Sender Intel de este fork y el TargetBridge Receiver sin
modificaciones del proyecto original.

## Antes de comenzar

- Sender: Mac Intel con macOS 14 o posterior.
- Receiver: Mac compatible con la versión correspondiente de TargetBridge
  Receiver.
- Cable Thunderbolt real y el servicio Thunderbolt Bridge activo en ambos Macs.
  Un cable USB-C de carga o un adaptador que solo transporte DisplayPort no es
  suficiente.

La aplicación no modifica la configuración de red ni desactiva Wi-Fi.

## Instalación

1. Instala `TargetBridge Receiver.app` en el Mac que funcionará como pantalla.
2. Instala `TargetBridge Intel Sender.app` en el Mac Intel que enviará la imagen.
3. Mantén separadas la aplicación original y la variante Intel; utilizan bundle
   identifiers, preferencias y datos diferentes.
4. Abre primero el Receiver y déjalo en su pantalla de espera.
5. Abre el Intel Sender y concede el permiso de Grabación de pantalla. Si macOS
   lo solicita, cierra completamente la aplicación y vuelve a abrirla.

## Conectar una pantalla

1. Comprueba que el Sender muestre una dirección de Thunderbolt Bridge. En el
   equipo validado aparece como `bridge0 · 10.0.0.1`.
2. Pulsa **Agregar pantalla** si todavía no existe una tarjeta de pantalla.
3. Abre **Ajustes de pantalla** en esa tarjeta.
4. Selecciona **Thunderbolt Bridge** y su dirección de interfaz local.
5. Elige el Receiver encontrado. Si Bonjour muestra únicamente su dirección
   Wi-Fi, ingresa manualmente la IP Thunderbolt; en el equipo validado es
   `10.0.0.2`.
6. Selecciona **Escritorio extendido** o **Duplicar escritorio**.
7. Para un iMac 4K comienza con **Trabajo 4K** y pulsa **Conectar pantalla**.

Cuando llegue el primer fotograma, el Receiver mostrará la transmisión. Para un
escritorio extendido, ordénalo en **Configuración del Sistema → Pantallas →
Ordenar** en el Sender.

## Perfiles recomendados para 4K

- `Trabajo 4K`: espacio lógico HiDPI de 2048 x 1152. Es el punto de partida.
- `4K HiDPI 2304`: espacio lógico de 2304 x 1296. Entrega más área de trabajo y
  se mantiene dentro del límite de transmisión validado en Intel.
- `Baja latencia`: prioriza movimiento y respuesta sobre la máxima nitidez.
- `Presentación`: simplifica el uso como pantalla duplicada.

La resolución lógica que muestra macOS no es igual a la resolución codificada.
Un escritorio lógico de 2048 x 1152 HiDPI, por ejemplo, puede transmitirse como
4096 x 2304 píxeles.

## Códecs y RAW NV12

Para la primera prueba deja la selección de códec en automático. El iMac Intel
validado dispone de H.264 y HEVC por hardware. HEVC suele entregar mejor calidad
para el mismo bitrate; H.264 funciona como alternativa compatible.

RAW NV12 evita la compresión de video y puede eliminar parte de la demora del
códec, pero a 4096 x 2304 y 60 FPS puede acercarse a 6,8 Gbit/s antes de sumar la
sobrecarga del protocolo. Úsalo solamente como prueba y cuando el Receiver
informe compatibilidad.

## Controles diarios

El icono de la barra superior permite manejar pantallas activas, Receiver, modo
duplicado o extendido, perfiles y brillo. Cambiar la topología de pantalla
durante una transmisión produce una detención y reconexión controladas porque
macOS debe reconstruir la pantalla virtual.

**Abrir al iniciar sesión** carga la aplicación con la sesión del usuario. La
opción de conexión automática funciona únicamente cuando la app se abre como
elemento de inicio; una apertura manual no conecta por sí sola.

## Solución de problemas

- **Conectar pantalla está desactivado:** selecciona una interfaz local y una IP
  del Receiver.
- **El permiso vuelve a aparecer:** revisa la entrada exacta `TargetBridge Intel
  Sender` en Privacidad y seguridad, cierra la app por completo y vuelve a abrirla.
- **El Receiver aparece solo por Wi-Fi:** selecciona o escribe su dirección
  Thunderbolt.
- **La imagen se ve demasiado grande:** utiliza el perfil lógico 2048 x 1152 o
  2304 x 1296 y permite la reconexión controlada.
- **No llega el primer fotograma:** ejecuta la revisión guiada y consulta los
  logs con:

```bash
log stream --predicate 'subsystem == "com.targetbridge.intel-sender"'
```

Para eliminar únicamente este fork, revisa y ejecuta `./uninstall.sh` desde el
repositorio. No borra el Receiver ni la configuración de red.
