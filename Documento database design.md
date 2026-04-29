# Tablas

> Base de datos: **`yomu`**

---

## 1. Vocabulario

### 📘 1. `words`

👉 Tabla principal de palabras en japonés.

```sql
words (
  id               SERIAL PRIMARY KEY,
  kanji            TEXT,          -- 食べる
  kana             TEXT NOT NULL, -- たべる
  romaji           TEXT,          -- taberu
  level            TEXT,          -- N5, N4...
  frequency        INT,           -- prioridad o frecuencia de uso
  part_of_speech   TEXT,          -- verbo, sustantivo, adjetivo, etc
  created_at       TIMESTAMP
);
```

### Qué guarda

* la forma en kanji de la palabra;
* la forma en kana;
* la romanización opcional;
* el nivel JLPT o nivel interno;
* frecuencia o prioridad;
* tipo gramatical.

---

### 🌐 2. `word_translations`

👉 Traducciones de cada palabra según idioma.

```sql
word_translations (
  id        SERIAL PRIMARY KEY,
  word_id   INT REFERENCES words(id),
  locale    TEXT,   -- 'es' | 'pt'
  meaning   TEXT,
  UNIQUE(word_id, locale)
);
```

### Qué guarda

* el idioma de la traducción;
* el significado de la palabra en ese idioma.

### Ejemplo

Para una palabra:

* `es` → `comer`
* `pt` → `comer`

---

### 🔤 3. `kanji`

👉 Información principal de cada kanji.

```sql
kanji (
  id            SERIAL PRIMARY KEY,
  character     TEXT UNIQUE,   -- 食
  onyomi        TEXT,          -- ショク
  kunyomi       TEXT,          -- た(べる)
  level         TEXT,          -- N5, N4...
  stroke_count  INT,
  frequency     INT
);
```

### Qué guarda

* el carácter kanji;
* lectura onyomi;
* lectura kunyomi;
* nivel;
* cantidad de trazos;
* frecuencia o prioridad.

---

### 🌐 4. `kanji_translations`

👉 Traducciones del significado de cada kanji según idioma.

```sql
kanji_translations (
  id        SERIAL PRIMARY KEY,
  kanji_id  INT REFERENCES kanji(id),
  locale    TEXT,   -- 'es' | 'pt'
  meaning   TEXT,
  UNIQUE(kanji_id, locale)
);
```

### Qué guarda

* el idioma;
* el significado del kanji en ese idioma.

---

### 🔗 5. `word_kanji`

👉 Relación entre palabras y kanji.

```sql
word_kanji (
  word_id   INT REFERENCES words(id),
  kanji_id  INT REFERENCES kanji(id),
  PRIMARY KEY (word_id, kanji_id)
);
```

### Qué permite

* asociar una palabra con uno o varios kanji;
* reutilizar un mismo kanji en varias palabras.

---

### 🧾 6. `examples`

👉 Ejemplos de uso en japonés asociados a una palabra.

```sql
examples (
  id            SERIAL PRIMARY KEY,
  word_id       INT REFERENCES words(id),
  japanese      TEXT NOT NULL,
  source        TEXT, -- "tatoeba", "ai", "manual"
  created_at    TIMESTAMP
);
```

### Qué guarda

* la palabra asociada;
* la frase de ejemplo en japonés;
* el origen del ejemplo;
* fecha de creación.

---

### 🌐 7. `example_translations`

👉 Traducciones de los ejemplos según idioma.

```sql
example_translations (
  id           SERIAL PRIMARY KEY,
  example_id   INT REFERENCES examples(id),
  locale       TEXT,   -- 'es' | 'pt'
  translation  TEXT,
  UNIQUE(example_id, locale)
);
```

### Qué guarda

* el idioma;
* la traducción del ejemplo en ese idioma.

---

### 📂 8. `categories`

👉 Categorías principales del sistema.

```sql
categories (
  id     SERIAL PRIMARY KEY,
  code   TEXT UNIQUE
);
```

### Qué guarda

* un código interno y estable para cada categoría.

### Ejemplos de `code`

* `pronouns`
* `verbs`
* `food`
* `transport`
* `greetings`

---

### 🌐 9. `category_translations`

👉 Nombre visible de cada categoría según idioma.

```sql
category_translations (
  id           SERIAL PRIMARY KEY,
  category_id  INT REFERENCES categories(id),
  locale       TEXT,   -- 'es' | 'pt'
  name         TEXT,
  UNIQUE(category_id, locale)
);
```

### Qué guarda

* el idioma;
* el nombre visible de la categoría en ese idioma.

### Ejemplo

Para una categoría:

* `es` → `saludos`
* `pt` → `saudações`

---

### 🔗 10. `word_categories`

👉 Relación entre palabras y categorías.

```sql
word_categories (
  word_id      INT REFERENCES words(id),
  category_id  INT REFERENCES categories(id),
  PRIMARY KEY (word_id, category_id)
);
```

### Qué permite

* asociar una palabra a una o varias categorías;
* filtrar contenido por tema o tipo.

---

## 2. Usuario y progreso

---

### 👤 11. `users`

👉 Usuarios de la plataforma.

```sql
users (
  id                SERIAL PRIMARY KEY,
  username          TEXT UNIQUE,
  preferred_locale  TEXT,   -- 'es' | 'pt'
  created_at        TIMESTAMP
);
```

### Qué guarda

* identificador del usuario;
* nombre de usuario;
* idioma preferido;
* fecha de creación.

---

### 📈 12. `user_word_progress`

👉 Progreso del usuario por palabra.

```sql
user_word_progress (
  id              SERIAL PRIMARY KEY,
  user_id         INT REFERENCES users(id),
  word_id         INT REFERENCES words(id),

  correct_count   INT DEFAULT 0,
  incorrect_count INT DEFAULT 0,

  last_seen       TIMESTAMP,
  next_review     TIMESTAMP,

  ease_factor     FLOAT DEFAULT 2.5,
  interval_days   INT DEFAULT 1,

  UNIQUE(user_id, word_id)
);
```

### Qué guarda

* usuario;
* palabra;
* número de respuestas correctas;
* número de respuestas incorrectas;
* última vez vista;
* próxima revisión;
* factor de facilidad;
* intervalo de revisión.

### Qué permite

* seguimiento individual de cada palabra por usuario;
* repetición espaciada;
* revisión inteligente.

---

### 🧠 13. `user_stats`

👉 Estadísticas generales del usuario.

```sql
user_stats (
  user_id            INT PRIMARY KEY REFERENCES users(id),
  total_words        INT DEFAULT 0,
  accuracy           FLOAT DEFAULT 0,
  total_study_time   INT DEFAULT 0
);
```

### Qué guarda

* cantidad total de palabras trabajadas;
* precisión general;
* tiempo total de estudio acumulado.

---

## 3. Conversación (IA)

---

### 💬 14. `conversations`

👉 Conversaciones del módulo de Chat IA.

```sql
conversations (
  id          SERIAL PRIMARY KEY,
  user_id     INT REFERENCES users(id),
  scenario    TEXT, -- restaurante, tienda, conversación casual, etc
  created_at  TIMESTAMP
);
```

### Qué guarda

* usuario propietario de la conversación;
* escenario de práctica;
* fecha de creación.

### Qué permite

* historial de conversaciones;
* organización de sesiones por usuario;
* práctica por contexto.

---

### 🗨️ 15. `messages`

👉 Mensajes de cada conversación.

```sql
messages (
  id                SERIAL PRIMARY KEY,
  conversation_id   INT REFERENCES conversations(id),

  role              TEXT, -- "user" | "assistant"
  content           TEXT,

  correction        TEXT, -- corrección generada por IA
  explanation       TEXT, -- explicación del error

  created_at        TIMESTAMP
);
```

### Qué guarda

* conversación a la que pertenece;
* rol del mensaje;
* contenido del mensaje;
* corrección propuesta;
* explicación asociada;
* fecha de creación.

### Qué permite

* guardar historial completo;
* almacenar correcciones;
* guardar explicaciones;
* revisar errores después.

---

# Relación general entre tablas

## Vocabulario

* `words` → palabra base
* `word_translations` → significado por idioma
* `kanji` → información base de kanji
* `kanji_translations` → significado del kanji por idioma
* `word_kanji` → relación palabra-kanji
* `examples` → ejemplos en japonés
* `example_translations` → traducción de ejemplos
* `categories` → categorías base
* `category_translations` → nombre visible de categorías
* `word_categories` → relación palabra-categoría

## Usuario y progreso

* `users` → usuario del sistema
* `user_word_progress` → progreso por palabra
* `user_stats` → resumen global de rendimiento

## Chat IA

* `conversations` → sesión de conversación
* `messages` → mensajes dentro de la conversación

---

# Categorías iniciales

Los `code` internos sugeridos para las categorías son:

* `pronouns`
* `verbs`
* `adjectives`
* `particles`
* `expressions`
* `daily_life`
* `food`
* `transport`
* `shopping`
* `time`
* `numbers`
* `family`
* `greetings`
* `farewells`
* `introductions`
* `casual_conversation`
* `common_questions`
* `friendship`
* `dating`
* `emotions`
* `opinions`
* `courtesy`
* `formality`
* `apologies`
* `gratitude`
* `requests`

---

## Resumen

La base de datos de **Yomu** está organizada en tres grandes áreas:

* **vocabulario**, con soporte multiidioma;
* **usuario y progreso**, para seguimiento y repetición espaciada;
* **chat IA**, para conversaciones, correcciones y explicaciones.

La estructura está pensada para servir contenido en japonés, mostrar traducciones en español o portugués, registrar el avance del usuario y guardar historial de práctica y conversación.

Si quieres, te lo puedo convertir ahora a un formato todavía más profesional, tipo **documentación técnica final**, con secciones como:
**propósito, tablas, relaciones, claves, reglas de negocio y notas de implementación**.


## Esquema completo

```sql
-- =========================
-- USERS
-- =========================
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  preferred_locale TEXT NOT NULL DEFAULT 'es'
    CHECK (preferred_locale IN ('es', 'pt')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- WORDS
-- =========================
CREATE TABLE words (
  id SERIAL PRIMARY KEY,
  kanji TEXT,
  kana TEXT NOT NULL,
  romaji TEXT,
  level TEXT,
  frequency INT,
  part_of_speech TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_words_level ON words(level);
CREATE INDEX idx_words_frequency ON words(frequency);

-- Traducciones de palabras
CREATE TABLE word_translations (
  id SERIAL PRIMARY KEY,
  word_id INT NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('es', 'pt')),
  meaning TEXT NOT NULL,
  UNIQUE(word_id, locale)
);

CREATE INDEX idx_word_translations_word ON word_translations(word_id);
CREATE INDEX idx_word_translations_locale ON word_translations(locale);

-- =========================
-- KANJI
-- =========================
CREATE TABLE kanji (
  id SERIAL PRIMARY KEY,
  character TEXT UNIQUE NOT NULL,
  onyomi TEXT,
  kunyomi TEXT,
  level TEXT,
  stroke_count INT,
  frequency INT
);

CREATE INDEX idx_kanji_level ON kanji(level);

-- Traducciones de kanji
CREATE TABLE kanji_translations (
  id SERIAL PRIMARY KEY,
  kanji_id INT NOT NULL REFERENCES kanji(id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('es', 'pt')),
  meaning TEXT NOT NULL,
  UNIQUE(kanji_id, locale)
);

CREATE INDEX idx_kanji_translations_kanji ON kanji_translations(kanji_id);
CREATE INDEX idx_kanji_translations_locale ON kanji_translations(locale);

-- =========================
-- WORD_KANJI (N:M)
-- =========================
CREATE TABLE word_kanji (
  word_id INT REFERENCES words(id) ON DELETE CASCADE,
  kanji_id INT REFERENCES kanji(id) ON DELETE CASCADE,
  PRIMARY KEY (word_id, kanji_id)
);

-- =========================
-- EXAMPLES
-- =========================
CREATE TABLE examples (
  id SERIAL PRIMARY KEY,
  word_id INT REFERENCES words(id) ON DELETE CASCADE,
  japanese TEXT NOT NULL,
  source TEXT, -- 'tatoeba' | 'ai'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_examples_word ON examples(word_id);

-- Traducciones de ejemplos
CREATE TABLE example_translations (
  id SERIAL PRIMARY KEY,
  example_id INT NOT NULL REFERENCES examples(id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('es', 'pt')),
  translation TEXT NOT NULL,
  UNIQUE(example_id, locale)
);

CREATE INDEX idx_example_translations_example ON example_translations(example_id);
CREATE INDEX idx_example_translations_locale ON example_translations(locale);

-- =========================
-- CATEGORIES
-- =========================
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  code TEXT NOT NULL UNIQUE
);

-- Traducciones de categorías
CREATE TABLE category_translations (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('es', 'pt')),
  name TEXT NOT NULL,
  UNIQUE(category_id, locale)
);

CREATE INDEX idx_category_translations_category ON category_translations(category_id);
CREATE INDEX idx_category_translations_locale ON category_translations(locale);

-- =========================
-- WORD_CATEGORIES
-- =========================
CREATE TABLE word_categories (
  word_id INT REFERENCES words(id) ON DELETE CASCADE,
  category_id INT REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (word_id, category_id)
);

-- =========================
-- USER WORD PROGRESS
-- =========================
CREATE TABLE user_word_progress (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  word_id INT REFERENCES words(id) ON DELETE CASCADE,

  correct_count INT DEFAULT 0,
  incorrect_count INT DEFAULT 0,

  last_seen TIMESTAMP,
  next_review TIMESTAMP,

  ease_factor FLOAT DEFAULT 2.5,
  interval_days INT DEFAULT 1,

  UNIQUE(user_id, word_id)
);

CREATE INDEX idx_progress_user ON user_word_progress(user_id);
CREATE INDEX idx_progress_next_review ON user_word_progress(next_review);

-- =========================
-- USER STATS
-- =========================
CREATE TABLE user_stats (
  user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_words INT DEFAULT 0,
  accuracy FLOAT DEFAULT 0,
  total_study_time INT DEFAULT 0
);

-- =========================
-- CONVERSATIONS
-- =========================
CREATE TABLE conversations (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  scenario TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_conversations_user ON conversations(user_id);

-- =========================
-- MESSAGES
-- =========================
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  conversation_id INT REFERENCES conversations(id) ON DELETE CASCADE,

  role TEXT CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,

  correction TEXT,
  explanation TEXT,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
```

---

## Categorías iniciales

Aquí va la versión con `code` en la tabla principal y con traducciones en español y portugués.

```sql
-- =========================
-- CATEGORIES BASE
-- =========================
INSERT INTO categories (id, code) VALUES
(1,  'pronouns'),
(2,  'verbs'),
(3,  'adjectives'),
(4,  'particles'),
(5,  'expressions'),
(6,  'daily_life'),
(7,  'food'),
(8,  'transport'),
(9,  'shopping'),
(10, 'time'),
(11, 'numbers'),
(12, 'family'),
(13, 'greetings'),
(14, 'farewells'),
(15, 'introductions'),
(16, 'casual_conversation'),
(17, 'common_questions'),
(18, 'friendship'),
(19, 'dating'),
(20, 'emotions'),
(21, 'opinions'),
(22, 'courtesy'),
(23, 'formality'),
(24, 'apologies'),
(25, 'gratitude'),
(26, 'requests');

-- =========================
-- CATEGORY TRANSLATIONS (ES)
-- =========================
INSERT INTO category_translations (category_id, locale, name) VALUES
(1,  'es', 'pronombres'),
(2,  'es', 'verbos'),
(3,  'es', 'adjetivos'),
(4,  'es', 'partículas'),
(5,  'es', 'expresiones'),
(6,  'es', 'vida diaria'),
(7,  'es', 'comida'),
(8,  'es', 'transporte'),
(9,  'es', 'compras'),
(10, 'es', 'tiempo'),
(11, 'es', 'números'),
(12, 'es', 'familia'),
(13, 'es', 'saludos'),
(14, 'es', 'despedidas'),
(15, 'es', 'presentaciones'),
(16, 'es', 'conversación casual'),
(17, 'es', 'preguntas comunes'),
(18, 'es', 'amistad'),
(19, 'es', 'citas'),
(20, 'es', 'emociones'),
(21, 'es', 'opiniones'),
(22, 'es', 'cortesía'),
(23, 'es', 'formalidad'),
(24, 'es', 'disculpas'),
(25, 'es', 'agradecimientos'),
(26, 'es', 'peticiones');

-- =========================
-- CATEGORY TRANSLATIONS (PT)
-- =========================
INSERT INTO category_translations (category_id, locale, name) VALUES
(1,  'pt', 'pronomes'),
(2,  'pt', 'verbos'),
(3,  'pt', 'adjetivos'),
(4,  'pt', 'partículas'),
(5,  'pt', 'expressões'),
(6,  'pt', 'vida diária'),
(7,  'pt', 'comida'),
(8,  'pt', 'transporte'),
(9,  'pt', 'compras'),
(10, 'pt', 'tempo'),
(11, 'pt', 'números'),
(12, 'pt', 'família'),
(13, 'pt', 'saudações'),
(14, 'pt', 'despedidas'),
(15, 'pt', 'apresentações'),
(16, 'pt', 'conversa casual'),
(17, 'pt', 'perguntas comuns'),
(18, 'pt', 'amizade'),
(19, 'pt', 'encontros'),
(20, 'pt', 'emoções'),
(21, 'pt', 'opiniões'),
(22, 'pt', 'cortesia'),
(23, 'pt', 'formalidade'),
(24, 'pt', 'desculpas'),
(25, 'pt', 'agradecimentos'),
(26, 'pt', 'pedidos');
```

---

## Ejemplo de cómo cargar palabras

```sql
INSERT INTO words (kanji, kana, romaji, level, frequency, part_of_speech)
VALUES ('食べる', 'たべる', 'taberu', 'N5', 100, 'verb');

INSERT INTO word_translations (word_id, locale, meaning) VALUES
(1, 'es', 'comer'),
(1, 'pt', 'comer');
```

---

## Ejemplo de cómo cargar kanji

```sql
INSERT INTO kanji (character, onyomi, kunyomi, level, stroke_count, frequency)
VALUES ('食', 'ショク', 'た(べる)', 'N5', 9, 120);

INSERT INTO kanji_translations (kanji_id, locale, meaning) VALUES
(1, 'es', 'comida / comer'),
(1, 'pt', 'comida / comer');
```

---

## Ejemplo de cómo cargar ejemplos

```sql
INSERT INTO examples (word_id, japanese, source)
VALUES (1, '私は寿司を食べる。', 'manual');

INSERT INTO example_translations (example_id, locale, translation) VALUES
(1, 'es', 'Yo como sushi.'),
(1, 'pt', 'Eu como sushi.');
```

---

## Schema prisma

```typescript
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id              Int                @id @default(autoincrement())
  username        String             @unique
  preferredLocale Locale             @default(es)
  createdAt       DateTime           @default(now()) @map("created_at")

  userWordProgress UserWordProgress[]
  userStats        UserStats?
  conversations    Conversation[]

  @@map("users")
}

model Word {
  id             Int                @id @default(autoincrement())
  kanji          String?
  kana           String
  romaji         String?
  level          String?
  frequency      Int?
  partOfSpeech   String?            @map("part_of_speech")
  createdAt      DateTime           @default(now()) @map("created_at")

  translations   WordTranslation[]
  examples       Example[]
  wordKanji      WordKanji[]
  wordCategories WordCategory[]
  userProgress   UserWordProgress[]

  @@index([level], map: "idx_words_level")
  @@index([frequency], map: "idx_words_frequency")
  @@map("words")
}

model WordTranslation {
  id       Int    @id @default(autoincrement())
  wordId   Int    @map("word_id")
  locale   Locale
  meaning  String

  word     Word   @relation(fields: [wordId], references: [id], onDelete: Cascade)

  @@unique([wordId, locale])
  @@index([wordId], map: "idx_word_translations_word")
  @@index([locale], map: "idx_word_translations_locale")
  @@map("word_translations")
}

model Kanji {
  id            Int                @id @default(autoincrement())
  character     String             @unique
  onyomi        String?
  kunyomi       String?
  level         String?
  strokeCount   Int?               @map("stroke_count")
  frequency     Int?

  translations  KanjiTranslation[]
  wordKanji     WordKanji[]

  @@index([level], map: "idx_kanji_level")
  @@map("kanji")
}

model KanjiTranslation {
  id       Int    @id @default(autoincrement())
  kanjiId  Int    @map("kanji_id")
  locale   Locale
  meaning  String

  kanji    Kanji  @relation(fields: [kanjiId], references: [id], onDelete: Cascade)

  @@unique([kanjiId, locale])
  @@index([kanjiId], map: "idx_kanji_translations_kanji")
  @@index([locale], map: "idx_kanji_translations_locale")
  @@map("kanji_translations")
}

model WordKanji {
  wordId   Int    @map("word_id")
  kanjiId  Int    @map("kanji_id")

  word     Word   @relation(fields: [wordId], references: [id], onDelete: Cascade)
  kanji    Kanji  @relation(fields: [kanjiId], references: [id], onDelete: Cascade)

  @@id([wordId, kanjiId])
  @@map("word_kanji")
}

model Example {
  id           Int                   @id @default(autoincrement())
  wordId       Int?                  @map("word_id")
  japanese     String
  source       String?
  createdAt    DateTime              @default(now()) @map("created_at")

  word         Word?                 @relation(fields: [wordId], references: [id], onDelete: Cascade)
  translations ExampleTranslation[]

  @@index([wordId], map: "idx_examples_word")
  @@map("examples")
}

model ExampleTranslation {
  id          Int      @id @default(autoincrement())
  exampleId   Int      @map("example_id")
  locale      Locale
  translation String

  example     Example  @relation(fields: [exampleId], references: [id], onDelete: Cascade)

  @@unique([exampleId, locale])
  @@index([exampleId], map: "idx_example_translations_example")
  @@index([locale], map: "idx_example_translations_locale")
  @@map("example_translations")
}

model Category {
  id           Int                   @id @default(autoincrement())
  code         String                @unique

  translations CategoryTranslation[]
  wordCategories WordCategory[]

  @@map("categories")
}

model CategoryTranslation {
  id          Int      @id @default(autoincrement())
  categoryId  Int      @map("category_id")
  locale      Locale
  name        String

  category    Category @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@unique([categoryId, locale])
  @@index([categoryId], map: "idx_category_translations_category")
  @@index([locale], map: "idx_category_translations_locale")
  @@map("category_translations")
}

model WordCategory {
  wordId      Int      @map("word_id")
  categoryId  Int      @map("category_id")

  word        Word     @relation(fields: [wordId], references: [id], onDelete: Cascade)
  category    Category @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@id([wordId, categoryId])
  @@map("word_categories")
}

model UserWordProgress {
  id             Int       @id @default(autoincrement())
  userId         Int       @map("user_id")
  wordId         Int       @map("word_id")
  correctCount   Int       @default(0) @map("correct_count")
  incorrectCount Int       @default(0) @map("incorrect_count")
  lastSeen       DateTime? @map("last_seen")
  nextReview     DateTime? @map("next_review")
  easeFactor     Float     @default(2.5) @map("ease_factor")
  intervalDays   Int       @default(1) @map("interval_days")

  user           User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  word           Word      @relation(fields: [wordId], references: [id], onDelete: Cascade)

  @@unique([userId, wordId])
  @@index([userId], map: "idx_progress_user")
  @@index([nextReview], map: "idx_progress_next_review")
  @@map("user_word_progress")
}

model UserStats {
  userId          Int    @id @map("user_id")
  totalWords      Int    @default(0) @map("total_words")
  accuracy        Float  @default(0)
  totalStudyTime  Int    @default(0) @map("total_study_time")

  user            User   @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("user_stats")
}

model Conversation {
  id         Int        @id @default(autoincrement())
  userId     Int        @map("user_id")
  scenario   String?
  createdAt  DateTime   @default(now()) @map("created_at")

  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  messages   Message[]

  @@index([userId], map: "idx_conversations_user")
  @@map("conversations")
}

model Message {
  id              Int         @id @default(autoincrement())
  conversationId  Int         @map("conversation_id")
  role            MessageRole
  content         String
  correction      String?
  explanation     String?
  createdAt       DateTime    @default(now()) @map("created_at")

  conversation    Conversation @relation(fields: [conversationId], references: [id], onDelete: Cascade)

  @@index([conversationId], map: "idx_messages_conversation")
  @@map("messages")
}

enum Locale {
  es
  pt
}

enum MessageRole {
  user
  assistant
}
```