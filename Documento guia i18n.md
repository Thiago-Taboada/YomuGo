# i18n en Yomu

## Idea general

En Yomu, el **i18n** debe separarse en dos partes:

### 1. Textos del sistema / interfaz
Estos textos deben vivir en el **frontend (Flutter)**, usando archivos de localización.

Ejemplos:
- Inicio
- Aprender
- Practicar
- Chat IA
- Progreso
- Continuar aprendiendo
- Accesos rápidos
- Tu progreso
- Precisión
- Tiempo hoy

Estos textos **no deben ir en la base de datos**.

---

### 2. Contenido del aprendizaje
Estos textos deben venir desde la **API / base de datos**, porque forman parte del contenido que el usuario estudia.

Ejemplos:
- significado de palabras
- significado de kanji
- traducción de ejemplos
- nombre visible de categorías

Estos textos **sí deben ir en la base de datos**, usando tablas de traducción como:
- `word_translations`
- `kanji_translations`
- `example_translations`
- `category_translations`

---

## Regla práctica

### Va en Flutter i18n si:
es texto fijo del sistema o de la interfaz.

### Va en DB si:
es contenido dinámico o contenido pedagógico que el usuario estudia.

---

## Ejemplo en Flutter

### `app_es.arb`
```json
{
  "home": "Inicio",
  "learn": "Aprender",
  "practice": "Practicar",
  "chatAi": "Chat IA",
  "progress": "Progreso",
  "continueLearning": "Continuar aprendiendo",
  "quickAccess": "Accesos rápidos",
  "yourProgress": "Tu progreso"
}
````

### `app_pt.arb`

```json
{
  "home": "Início",
  "learn": "Aprender",
  "practice": "Praticar",
  "chatAi": "Chat IA",
  "progress": "Progresso",
  "continueLearning": "Continuar aprendendo",
  "quickAccess": "Acessos rápidos",
  "yourProgress": "Seu progresso"
}
```

---

## Ejemplo con texto dinámico

El backend devuelve algo así:

```json
{
  "streakDays": 12
}
```

Y el frontend arma el texto según idioma:

### Español

`Llevas 12 días aprendiendo consecutivos`

### Portugués

`Você está há 12 dias aprendendo consecutivamente`

En este caso:

* el número viene de la API
* la plantilla del texto vive en Flutter i18n

---

## Idioma del usuario

Se recomienda guardar en `users`:

* `preferred_locale = 'es'`
* `preferred_locale = 'pt'`

Esto sirve para:

* iniciar la app en el idioma correcto
* pedir a la API el contenido traducido correcto

---

## Flujo ideal

1. El usuario tiene un `preferred_locale`
2. Flutter carga los textos de interfaz según ese idioma
3. El frontend llama a la API enviando `locale`
4. La API devuelve el contenido pedagógico ya traducido
5. La UI mezcla:

   * textos del sistema desde Flutter
   * contenido del aprendizaje desde backend

---

## Resumen

### Flutter i18n

Para:

* menús
* botones
* títulos
* labels
* mensajes del sistema

### Base de datos + API

Para:

* palabras
* categorías
* ejemplos
* significados
* traducciones del contenido de estudio

```