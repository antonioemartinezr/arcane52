# Arcane 52: Fast Duels, Any Deck

Reglas oficiales v0.2

## Concepto

Arcane 52 es un duelo rapido de cartas inspirado en juegos de magia y criaturas, disenado para jugarse con una baraja tradicional de 52 cartas.

Cada carta obtiene su funcion a partir de su rango:

- `A, 2, 3, 4, 5`: criaturas.
- `6, 7, 8, 9, 10`: mana.
- `J, Q, K`: hechizos.

Los palos representan escuelas arcanas. Cada duelista pertenece a una escuela y puede activar voluntariamente su poder una sola vez por partida al jugar una carta de su propio palo. Cada poder afecta a una criatura objetivo. Si decide no activarlo, conserva el poder para una carta posterior del mismo palo.

## Objetivo

Reduce los puntos de vida del oponente a `0` o menos.

## Preparacion

1. Baraja las 52 cartas.
2. Cada jugador comienza con `15` puntos de vida.
3. Cada jugador roba `7` cartas.
4. Cada jugador elige o recibe al azar una escuela arcana.
5. Elige al jugador inicial.

## Escuelas Arcanas

Cada jugador tiene una escuela asociada a un palo y dispone de una activación por partida, independiente de la del oponente. Después de jugar y resolver una carta de su escuela, puede activar el poder correspondiente o reservarlo. Primero se resuelven el efecto de la carta, las muertes de criaturas y la victoria; si la partida termina, no se ofrece una activación.

Todos los poderes eligen una criatura objetivo en juego. Si no hay una criatura válida, no se ofrece la activación y el poder se conserva.

| Palo | Escuela | Poder | Objetivo |
| --- | --- | --- | --- |
| Corazones | Vitalis | La criatura gana `+1` de defensa. | Una criatura propia. |
| Diamantes | Aether | La criatura pierde `1` de defensa. | Una criatura del oponente. |
| Treboles | Grove | La criatura gana `+1` de ataque. | Una criatura propia. |
| Picas | Ruin | Haces `1` punto de dano a la criatura. | Una criatura del oponente. |

Los cambios de ataque y defensa de Vitalis, Aether y Grove son permanentes: duran mientras la criatura siga en juego. Si Aether deja una criatura con defensa `0` o menos, va al fondo del mazo. El dano de Ruin es dano normal: si no destruye a la criatura, se limpia al final del turno.

Rechazar la activación o cancelar la selección de objetivo no consume el poder ni deshace la carta jugada. El poder solo se consume cuando su efecto se aplica correctamente. No se recupera al cambiar de turno; vuelve a estar disponible al comenzar una partida nueva. Esta elección no permite jugar cartas adicionales ni abre otra ventana de respuesta.

En el cartucho, `Z` acepta y `X` reserva el poder. Al activarlo, las flechas seleccionan la criatura objetivo, `Z` confirma y `X` cancela sin consumir la activación. El indicador junto a la escuela muestra `+` si está disponible y `-` si ya se usó. La CPU elige automáticamente cuándo usar su propia activación, bajo las mismas condiciones de uso único y objetivo válido.

## Tipos De Carta

### Mana

Las cartas `6`, `7`, `8`, `9` y `10` son cartas de mana.

- Cada carta de mana produce `1` mana al girarse.
- Puedes jugar solo `1` carta de mana por turno.
- El mana usado se gira y no puede volver a usarse hasta tu siguiente turno.

### Criaturas

Las criaturas atacan al oponente y bloquean criaturas enemigas.

| Carta | Coste | Ataque | Defensa | Regla |
| --- | ---: | ---: | ---: | --- |
| A | 1 | 1 | 1 | Tambien puede girarse para producir `1` mana. |
| 2 | 2 | 2 | 2 | - |
| 3 | 2 | 3 | 3 | - |
| 4 | 3 | 4 | 4 | - |
| 5 | 3 | 5 | 5 | - |

Una criatura que entra en juego no puede atacar ese mismo turno, pero si puede bloquear durante el turno del oponente si esta enderezada.

### Hechizos

Los hechizos se juegan desde la mano pagando su coste. Despues de resolver su efecto, van al fondo del mazo.

| Carta | Coste | Efecto |
| --- | ---: | --- |
| J | 1 | Cancela una criatura atacante objetivo. |
| J | 1 | Una criatura objetivo no puede ser bloqueada este turno. |
| Q | 1 | Una criatura objetivo gana `+0/+2` este turno. |
| Q | 3 | Ganas `4` puntos de vida. |
| K | 1 | Una criatura objetivo gana `+1/+0` este turno. |
| K | 1 | Haces `1` punto de dano a una criatura objetivo. |

## Zonas De Juego

- Mazo: cartas boca abajo desde donde se roba.
- Mano: cartas disponibles para jugar.
- Zona de mana: cartas de mana jugadas.
- Zona de criaturas: criaturas en juego.

No hay pila de descarte. Las cartas usadas, destruidas o retiradas del juego vuelven boca abajo al fondo del mazo, sin barajar.

## Estructura Del Turno

Cada turno tiene cuatro etapas.

### 1. Inicio

El jugador activo:

1. Endereza sus cartas giradas.
2. Limpia efectos temporales de sus criaturas.
3. Roba `1` carta.

El inicio del turno no restablece el poder de escuela usado durante la partida.

### 2. Invocacion

El jugador activo puede jugar cartas desde su mano en cualquier orden:

- Puede jugar `1` carta de mana.
- Puede jugar cualquier cantidad de criaturas si puede pagar sus costes.
- Puede jugar cualquier cantidad de hechizos si puede pagar sus costes.
- Si aún conserva su activación de escuela de esta partida, puede usarla voluntariamente al resolver una carta de su propio palo. También puede reservarla.

### 3. Combate

El jugador activo elige que criaturas atacan y las gira.

No pueden atacar:

- Criaturas que entraron en juego este turno.
- Criaturas que ya estan giradas.

El defensor asigna bloqueadores:

- Cada criatura defensora puede bloquear a una sola atacante.
- Una criatura girada no puede bloquear. Las criaturas que atacaron, o los Ases girados para dar mana, siguen girados hasta el inicio del siguiente turno de su dueno.
- Una criatura no se gira al bloquear.
- Una criatura imbloqueable no puede ser bloqueada.

Despues de declarar bloqueos, ambos jugadores pueden jugar hechizos de combate. Para mantener el duelo rapido, cada hechizo se resuelve inmediatamente.

Al resolver un hechizo de su propio palo, cualquiera de los jugadores puede activar su escuela si todavía conserva su único uso de la partida. Se aplica la misma elección voluntaria, sin una ventana de respuesta adicional.

### 4. Fin

El turno termina.

Se limpian en ambos jugadores:

- Bonus temporales de ataque y defensa de los hechizos.
- Dano temporal marcado en criaturas.

El estado de poder de escuela usado se conserva hasta el final de la partida. Limpiar efectos temporales no devuelve la activación ni deshace los cambios permanentes de las escuelas.

Luego el turno pasa al oponente.

## Resolucion De Combate

Si una criatura atacante no fue bloqueada, hace dano al jugador defensor igual a su ataque.

Si una criatura atacante fue bloqueada:

1. La atacante hace dano igual a su ataque a la bloqueadora.
2. La bloqueadora hace dano igual a su ataque a la atacante.
3. Toda criatura con defensa `0` o menos va al fondo del mazo.

Ejemplo: una criatura `3/3` es bloqueada por una criatura `2/2`. La `3/3` recibe `2` de dano y sobrevive como `3/1` durante la resolucion. La `2/2` recibe `3` de dano y va al fondo del mazo.

## Victoria

Un jugador gana inmediatamente cuando el oponente queda con `0` o menos puntos de vida.

## Ejemplo De Turno

La Jugadora 1 pertenece a la escuela de Diamantes. Su oponente tiene en juego una criatura `2/2`.

1. Inicio: endereza sus cartas y roba `1`.
2. Invocacion: juega un `8` de Diamantes como mana.
3. Como jugó una carta de su escuela y aún no usó su poder en esta partida, elige activar Aether sobre la criatura `2/2` del oponente, que queda como `2/1` de forma permanente. Podría reservarlo; en este ejemplo lo consume y no podrá activarlo otra vez durante la partida.
4. Gira `2` cartas de mana para jugar un `3` de Treboles como criatura `3/3`.
5. Esa criatura no puede atacar este turno porque acaba de entrar en juego.
6. Combate: no declara atacantes.
7. Fin: termina el turno. Su poder de escuela sigue usado en los turnos siguientes y la criatura rival sigue siendo `2/1`.

## Principio De Diseno

Arcane 52 debe ser rapido de explicar, facil de leer en 128x128 pixeles y jugable con cualquier baraja tradicional. Si una regla agrega profundidad pero exige demasiada explicacion, debe simplificarse o dejarse para una variante avanzada.
