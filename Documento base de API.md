# Documento base de API

## Proyecto: Yomu

## Tipo: API REST

## Base de datos: PostgreSQL (`yomu`)

## Backend previsto: Node.js + TypeScript + Prisma

---

# 1. Objetivo de la API

La API de Yomu será responsable de servir el contenido, registrar el progreso del usuario, almacenar sesiones de práctica, gestionar conversaciones con IA y devolver métricas de avance para una plataforma web de aprendizaje de japonés. El modelo de datos actual contempla usuarios, palabras, kanji, ejemplos, categorías, progreso por palabra, estadísticas globales y conversaciones con mensajes. 

---

# 2. Alcance inicial

La API cubrirá inicialmente estos módulos:

* autenticación y usuario;
* contenido de aprendizaje;
* práctica y repaso;
* conversación con IA;
* progreso y métricas;
* categorías y traducciones.

No se incluye todavía en esta primera versión:

* voz;
* escenarios personalizados;
* panel administrativo avanzado;
* minijuegos complejos con lógica propia de ranking.

---

# 3. Convenciones generales

## 3.1. Base URL

```txt id="55351"
/api/v1
```

## 3.2. Formato de respuesta

Todas las respuestas deben devolverse en JSON.

## 3.3. Autenticación

Las rutas privadas usarán JWT en header:

```http id="82111"
Authorization: Bearer <token>
```

## 3.4. Idioma

La API debe soportar `es` y `pt`.

El idioma puede resolverse así, en este orden:

1. query param `locale`
2. header `Accept-Language`
3. `users.preferred_locale`
4. fallback a `es`

La necesidad de `preferred_locale` está alineada con la tabla `users`, que ya se propuso ampliar para soportar idioma preferido. La base actual ya contempla `users` como entidad principal del sistema. 

## 3.5. Códigos HTTP sugeridos

* `200` OK
* `201` Created
* `204` No Content
* `400` Bad Request
* `401` Unauthorized
* `403` Forbidden
* `404` Not Found
* `409` Conflict
* `422` Unprocessable Entity
* `500` Internal Server Error

## 3.6. Paginación

Para endpoints listados:

* `page`
* `limit`

## 3.7. Filtros

Según módulo:

* `locale`
* `level`
* `categoryId`
* `partOfSpeech`
* `scenario`
* `status`

---

# 4. Módulos principales de la API

## 4.1. Auth

Responsable de:

* registro
* login
* sesión actual

## 4.2. Users

Responsable de:

* perfil básico
* idioma preferido
* configuración mínima

## 4.3. Learning

Responsable de:

* categorías
* palabras
* kanji
* ejemplos
* contenido por nivel

## 4.4. Practice

Responsable de:

* práctica configurada
* revisión de errores
* actualización de progreso por palabra

## 4.5. Chat IA

Responsable de:

* conversaciones
* mensajes
* correcciones
* historial

## 4.6. Progress

Responsable de:

* dashboard de progreso
* estadísticas
* roadmap
* hitos

Estas áreas nacen directamente de las tablas ya modeladas para palabras, kanji, ejemplos, categorías, progreso, estadísticas y conversaciones.  

---

# 5. Entidades principales del sistema

## 5.1. Users

Usuarios de la plataforma. La tabla base actual incluye `id`, `username` y `created_at`. 

## 5.2. Words

Núcleo del sistema de vocabulario. Incluye kana, kanji opcional, romaji, nivel, frecuencia y tipo gramatical. 

## 5.3. Kanji

Kanji individuales con lecturas, nivel, trazos y frecuencia. 

## 5.4. Examples

Ejemplos asociados a palabras, con texto japonés y traducción por idioma. La estructura base de ejemplos ya existe en el esquema. 

## 5.5. Categories

Agrupaciones temáticas o funcionales del contenido. Ya definiste 26 categorías iniciales.  

## 5.6. UserWordProgress

Progreso del usuario por palabra, incluyendo repeticiones correctas, incorrectas y datos de spaced repetition. 

## 5.7. UserStats

Resumen global del rendimiento del usuario. 

## 5.8. Conversations / Messages

Historial del módulo de Chat IA, con mensajes, correcciones y explicaciones. 

---

# 6. Reglas de negocio iniciales

## RN-01

Una palabra se considera “vista” cuando aparece en una práctica, lección o conversación.

## RN-02

Una palabra aumenta su `correct_count` o `incorrect_count` según el resultado de práctica del usuario, usando `user_word_progress`. 

## RN-03

El sistema debe recalcular `next_review`, `ease_factor` e `interval_days` cuando una palabra se practica en modo repetición espaciada. La tabla actual ya contempla esos campos. 

## RN-04

Las estadísticas globales del usuario deben actualizarse tras finalizar sesiones de práctica o revisiones, usando `user_stats.total_words`, `accuracy` y `total_study_time`. 

## RN-05

Una conversación debe pertenecer a un usuario y puede tener escenario opcional. La estructura de `conversations` ya contempla ambos campos. 

## RN-06

Cada mensaje del usuario puede guardar corrección y explicación generadas por IA. Esto está directamente alineado con `messages.correction` y `messages.explanation`. 

## RN-07

La API debe devolver textos traducidos según idioma cuando el contenido tenga traducciones disponibles.

## RN-08

Las categorías no deben depender de un nombre fijo en un solo idioma; deben devolverse según `locale`.

## RN-09

La precisión del usuario se calcula como:

```txt id="30727"
correctas / (correctas + incorrectas)
```

## RN-10

Los módulos más fuertes y más débiles del dashboard se calculan según desempeño agregado por categoría, tipo de práctica o nivel.

---

# 7. Estructura general de respuesta

## 7.1. Respuesta exitosa simple

```json id="97438"
{
  "success": true,
  "data": {}
}
```

## 7.2. Respuesta con paginación

```json id="45041"
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 120,
    "totalPages": 6
  }
}
```

## 7.3. Respuesta de error

```json id="54204"
{
  "success": false,
  "error": {
    "code": "CATEGORY_NOT_FOUND",
    "message": "La categoría no existe"
  }
}
```

---

# 8. Endpoints por módulo

---

# 8.1. AUTH

## POST `/auth/register`

Crear usuario nuevo.

### Body

```json id="28670"
{
  "username": "thiago",
  "password": "123456",
  "preferredLocale": "es"
}
```

### Response

```json id="97550"
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "username": "thiago",
      "preferredLocale": "es"
    },
    "token": "jwt-token"
  }
}
```

---

## POST `/auth/login`

Iniciar sesión.

### Body

```json id="84216"
{
  "username": "thiago",
  "password": "123456"
}
```

---

## GET `/auth/me`

Obtener usuario autenticado.

### Response

```json id="82768"
{
  "success": true,
  "data": {
    "id": 1,
    "username": "thiago",
    "preferredLocale": "es",
    "createdAt": "2026-04-29T12:00:00.000Z"
  }
}
```

---

# 8.2. USERS

## PATCH `/users/me`

Actualizar perfil básico.

### Body

```json id="19309"
{
  "preferredLocale": "pt"
}
```

---

## GET `/users/me/settings`

Obtener configuración del usuario.

---

# 8.3. CATEGORIES / LEARNING

## GET `/categories`

Listar categorías traducidas según idioma.

### Query params

* `locale=es|pt`

### Response

```json id="73193"
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "pronouns",
      "name": "pronombres"
    },
    {
      "id": 2,
      "code": "verbs",
      "name": "verbos"
    }
  ]
}
```

Estas categorías se apoyan en tu catálogo inicial de 26 categorías. 

---

## GET `/categories/:id`

Detalle de una categoría.

### Response

```json id="44087"
{
  "success": true,
  "data": {
    "id": 7,
    "code": "food",
    "name": "comida"
  }
}
```

---

## GET `/words`

Listar palabras.

### Query params

* `locale`
* `level`
* `categoryId`
* `partOfSpeech`
* `page`
* `limit`

### Response

```json id="66565"
{
  "success": true,
  "data": [
    {
      "id": 1,
      "kanji": "食べる",
      "kana": "たべる",
      "romaji": "taberu",
      "meaning": "comer",
      "level": "N5",
      "partOfSpeech": "verb"
    }
  ]
}
```

Se basa en la tabla `words`, que es el núcleo del sistema. 

---

## GET `/words/:id`

Detalle de palabra con ejemplos, categorías y kanji relacionados.

### Response

```json id="15364"
{
  "success": true,
  "data": {
    "id": 1,
    "kanji": "食べる",
    "kana": "たべる",
    "romaji": "taberu",
    "meaning": "comer",
    "level": "N5",
    "partOfSpeech": "verb",
    "categories": [
      { "id": 7, "name": "comida" }
    ],
    "examples": [
      {
        "id": 1,
        "japanese": "私は寿司を食べる。",
        "translation": "Yo como sushi."
      }
    ],
    "kanjiItems": [
      {
        "id": 1,
        "character": "食",
        "meaning": "comida / comer"
      }
    ]
  }
}
```

---

## GET `/kanji`

Listar kanji.

### Query params

* `locale`
* `level`
* `page`
* `limit`

---

## GET `/kanji/:id`

Detalle de kanji con lecturas y palabras relacionadas.

La tabla `kanji` ya contempla `character`, `onyomi`, `kunyomi`, `level`, `stroke_count` y `frequency`. 

---

## GET `/examples`

Listar ejemplos por palabra.

### Query params

* `wordId`
* `locale`

---

# 8.4. PRACTICE

Como tu esquema actual no tiene todavía tablas explícitas para “practice sessions”, recomiendo una primera versión de API donde la práctica actualice directamente `user_word_progress` y `user_stats`, y más adelante se agregue una tabla de sesiones si quieres auditoría más fuerte. La base actual sí tiene ya progreso por palabra y estadísticas globales. 

## POST `/practice/session/start`

Iniciar una práctica configurada.

### Body

```json id="70104"
{
  "type": "recognition",
  "module": "hiragana",
  "level": "N5",
  "questionCount": 10,
  "mode": "free",
  "categoryId": 7
}
```

### Response

```json id="23570"
{
  "success": true,
  "data": {
    "sessionId": "temp-session-id",
    "type": "recognition",
    "module": "hiragana",
    "questionCount": 10
  }
}
```

---

## POST `/practice/session/submit`

Enviar resultados de práctica.

### Body

```json id="62615"
{
  "type": "multiple_choice",
  "module": "vocabulary",
  "durationSeconds": 180,
  "answers": [
    {
      "wordId": 1,
      "isCorrect": true
    },
    {
      "wordId": 2,
      "isCorrect": false
    }
  ]
}
```

### Acción esperada

* actualizar `user_word_progress`
* recalcular repaso
* actualizar `user_stats`

---

## GET `/practice/review/errors`

Listar palabras o ítems con más errores del usuario.

### Response

```json id="78815"
{
  "success": true,
  "data": [
    {
      "wordId": 2,
      "kanji": "行く",
      "kana": "いく",
      "meaning": "ir",
      "incorrectCount": 5
    }
  ]
}
```

---

## GET `/practice/review/due`

Listar palabras pendientes de repaso por `next_review`.

La tabla `user_word_progress` ya está pensada justamente para spaced repetition con `next_review`, `ease_factor` e `interval_days`. 

---

# 8.5. CHAT IA

## GET `/chat/conversations`

Listar conversaciones del usuario.

### Query params

* `scenario`
* `page`
* `limit`

### Response

```json id="45804"
{
  "success": true,
  "data": [
    {
      "id": 1,
      "scenario": "restaurant",
      "createdAt": "2026-04-29T12:00:00.000Z",
      "messageCount": 8
    }
  ]
}
```

La estructura de conversaciones y mensajes ya existe en tu esquema actual. 

---

## POST `/chat/conversations`

Crear conversación nueva.

### Body

```json id="27947"
{
  "mode": "scenario",
  "scenario": "restaurant"
}
```

### Response

```json id="46918"
{
  "success": true,
  "data": {
    "id": 10,
    "scenario": "restaurant",
    "createdAt": "2026-04-29T12:00:00.000Z"
  }
}
```

---

## GET `/chat/conversations/:id`

Obtener detalle de conversación y mensajes.

### Response

```json id="87031"
{
  "success": true,
  "data": {
    "id": 10,
    "scenario": "restaurant",
    "messages": [
      {
        "id": 1,
        "role": "user",
        "content": "watashi wa sushi taberu",
        "correction": "watashi wa sushi o tabemasu",
        "explanation": "Falta la partícula を y la conjugación más natural"
      }
    ]
  }
}
```

Esto está alineado con `messages.role`, `content`, `correction` y `explanation`. 

---

## POST `/chat/conversations/:id/messages`

Enviar mensaje a la conversación.

### Body

```json id="49695"
{
  "content": "watashi wa sushi taberu",
  "inputType": "romaji"
}
```

### Response esperada

```json id="63150"
{
  "success": true,
  "data": {
    "userMessage": {
      "id": 101,
      "role": "user",
      "content": "watashi wa sushi taberu",
      "correction": "watashi wa sushi o tabemasu",
      "explanation": "Falta la partícula を y la forma verbal es poco natural en este contexto"
    },
    "assistantMessage": {
      "id": 102,
      "role": "assistant",
      "content": "いいですね。お寿司が好きですか？"
    }
  }
}
```

---

## DELETE `/chat/conversations/:id`

Eliminar conversación.

---

# 8.6. PROGRESS

## GET `/progress/dashboard`

Obtener dashboard principal de progreso.

### Response

```json id="97703"
{
  "success": true,
  "data": {
    "currentLevel": "N5",
    "wordsLearned": 120,
    "accuracy": 0.84,
    "totalStudyTime": 5400,
    "streakDays": 7,
    "weeklyHistory": [
      { "day": "Mon", "minutes": 20 },
      { "day": "Tue", "minutes": 15 }
    ],
    "moduleProgress": [
      { "module": "hiragana", "progress": 0.9 },
      { "module": "vocabulary", "progress": 0.45 }
    ],
    "strongModules": ["hiragana", "saludos"],
    "weakModules": ["partículas", "verbos"]
  }
}
```

El dashboard se apoyará sobre `user_stats` y agregaciones derivadas de progreso y práctica. La tabla `user_stats` ya define `total_words`, `accuracy` y `total_study_time`. 

---

## GET `/progress/stats`

Estadísticas detalladas.

### Debe devolver

* precisión por tipo de ejercicio
* errores más comunes
* tiempo promedio por sesión
* módulos completados
* palabras dominadas / en revisión / difíciles

---

## GET `/progress/roadmap`

Roadmap del nivel.

### Debe devolver

* nivel actual estimado
* siguiente meta
* checklist de pendientes
* checkpoint disponible
* mensaje motivador

### Ejemplo

```json id="88844"
{
  "success": true,
  "data": {
    "currentEstimatedLevel": "N5 básico",
    "nextGoal": "Completar vocabulario esencial N5",
    "checklist": [
      { "label": "Hiragana completo", "done": true },
      { "label": "Katakana básico", "done": false },
      { "label": "100 palabras dominadas", "done": true }
    ],
    "checkpointAvailable": false,
    "message": "Ya estás cerca de completar N5 básico"
  }
}
```

---

## GET `/progress/achievements`

Logros del usuario.

### Ejemplo

```json id="69339"
{
  "success": true,
  "data": [
    {
      "code": "hiragana_completed",
      "title": "Completaste hiragana",
      "unlockedAt": "2026-04-20T10:00:00.000Z"
    },
    {
      "code": "seven_day_streak",
      "title": "7 días de práctica",
      "unlockedAt": "2026-04-28T10:00:00.000Z"
    }
  ]
}
```

---

# 9. Endpoints de soporte sugeridos

## GET `/health`

Healthcheck del backend.

## GET `/locales`

Idiomas soportados.

### Response

```json id="33268"
{
  "success": true,
  "data": ["es", "pt"]
}
```

---

# 10. Orden recomendado de implementación

## Fase 1

* auth
* users
* categories
* words
* word detail
* progress dashboard básico

## Fase 2

* practice submit
* review errors
* review due
* examples
* kanji

## Fase 3

* conversations
* messages
* correcciones IA
* historial de chat

## Fase 4

* roadmap
* achievements
* stats detalladas

---

# 11. Recomendaciones técnicas

## 11.1. Separación por módulos

Organiza el backend así:

* `auth`
* `users`
* `categories`
* `words`
* `kanji`
* `examples`
* `practice`
* `chat`
* `progress`

## 11.2. Resolver idioma en servicio

No hagas que el frontend tenga que reconstruir traducciones; la API ya debe devolver el texto final según `locale`.

## 11.3. No exponer demasiada lógica en el cliente

El cálculo de:

* precisión
* roadmap
* repaso pendiente
* módulos fuertes y débiles

debe vivir en backend.

## 11.4. Pensar ya en sesiones de práctica

Aunque tu esquema actual no tenga una tabla de `practice_sessions`, seguramente más adelante te convendrá agregarla para trazabilidad más fuerte. Hoy puedes arrancar solo con progreso por palabra y estadísticas globales. 

---

# 12. Próximo paso recomendado

Con este documento, el siguiente paso ideal sería bajar esto a una versión más técnica por módulo, empezando por:

1. **Auth**
2. **Categories**
3. **Words**
4. **Practice**
5. **Chat**
6. **Progress**

Y para cada endpoint definir:

* request exacto
* response exacta
* validaciones
* reglas de negocio
* relación con Prisma

Si quieres, en el siguiente mensaje te lo convierto en una **versión mucho más implementable**, módulo por módulo, empezando por **Auth + Categories + Words**.
