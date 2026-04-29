# YomuGo backend (API v1)

Backend REST de **Yomu** en **NestJS + TypeScript + Prisma + PostgreSQL**, alineado con el diseño de base de datos y el documento de API del repo.

## Requisitos

- Node.js (LTS recomendado)
- PostgreSQL 14+ con una base de datos llamada `yomu` (o ajusta `DATABASE_URL`)

## Configuracion

1. Copia `.env.example` a `.env` y edita valores.

Variables principales:

| Variable          | Descripcion                                  |
|-------------------|----------------------------------------------|
| `PORT`            | Puerto HTTP (default `3000`)                 |
| `API_PREFIX`      | Prefijo global (default `api/v1`)            |
| `DATABASE_URL`    | URL de conexion PostgreSQL                    |
| `JWT_SECRET`      | Clave firma JWT (min. 8 caracteres)         |
| `JWT_EXPIRES_IN`  | Expiracion del token (ej. `7d`)              |
| `DEFAULT_LOCALE`  | `es` o `pt`                                   |

## Instalacion y base de datos

```bash
cd backend
npm install
npx prisma migrate deploy
npm run prisma:seed
```

En desarrollo (genera/aplica migraciones interactivas):

```bash
npm run prisma:migrate
npm run prisma:seed
```

Generar solo el cliente Prisma:

```bash
npm run prisma:generate
```

## Ejecutar

```bash
npm run dev
```

- Health: `GET http://localhost:3000/api/v1/health`
- Idiomas soportados: `GET http://localhost:3000/api/v1/locales`

## Scripts npm

| Script            | Uso                    |
|-------------------|------------------------|
| `npm run dev`     | Desarrollo con watch   |
| `npm run build`   | Compilar a `dist/`     |
| `npm run start:prod` | Produccion (`node`) |
| `npm run prisma:generate` | `prisma generate` |
| `npm run prisma:migrate`  | `prisma migrate dev` |
| `npm run prisma:seed`     | `prisma db seed` |
| `npm run prisma:studio`   | Prisma Studio |
| `npm test`        | Unit tests (puede no haber specs) |
| `npm run test:e2e` | E2E (health; Prisma mockeado) |

## Endpoints implementados (Fase 1)

Prefijo base: `/api/v1`

### Auth

- `POST /auth/register` — body obligatorio: `username`, `email`, `password`; opcional: `preferredLocale` (`es`|`pt`). Siempre crea rol **USER**.
- `POST /auth/login` — body: `identifier` (nombre de usuario **o** email), `password`. Si la cuenta tiene `isActive: false`, responde **403** con código `ACCOUNT_DISABLED`.
- `GET /auth/me` — JWT requerido

### Usuarios y roles

- **ADMIN:** acceso a todo el CRUD de usuarios y al listado.
- **USER:** solo puede operar sobre **su propio** registro (`/users/me`, `GET/PATCH /users/:id` si `:id` es el suyo). No puede asignar `role`, `isActive`, `emailVerified` ni borrar a otros.

| Metodo | Ruta | Quien |
|--------|------|--------|
| `POST` | `/users` | ADMIN — crear usuario (`role`, `isActive`, `emailVerified`, `profileImageBase64` opcionales) |
| `GET` | `/users` | ADMIN — listar (paginado `page`, `limit`) |
| `GET` | `/users/me` | JWT — perfil propio |
| `PATCH` | `/users/me` | JWT — actualizar perfil (`username`, `email`, `password`, `preferredLocale`, `profileImageBase64`; sin `role` ni flags admin) |
| `GET` | `/users/me/settings` | JWT |
| `DELETE` | `/users/me` | JWT — borrar la cuenta propia |
| `GET` | `/users/:id` | ADMIN o el propio usuario |
| `PATCH` | `/users/:id` | ADMIN (puede incluir `role`, `isActive`, `emailVerified`) o el propio usuario (mismo perfil que `/users/me`, sin esos campos) |
| `DELETE` | `/users/:id` | ADMIN — borrar cualquier usuario |

Respuesta de usuario (sin contraseña): `id`, `username`, `email`, `role`, `isActive`, `emailVerified`, `lastLoginAt`, `profileImageBase64`, `preferredLocale`, `createdAt`, `updatedAt`. `lastLoginAt` se actualiza en cada login correcto. `profileImageBase64` es texto largo (p. ej. `data:image/png;base64,...`); evita subidas enormes en produccion (considera CDN u objeto mas adelante).

**Primer usuario admin (una sola vez en desarrollo):** el registro publico (`POST /auth/register`) crea siempre rol **USER**. Para tener un admin, registra una cuenta y en la base de datos cambia `role` a `ADMIN` para ese usuario (por ejemplo con **Prisma Studio**: `npm run prisma:studio`, tabla `users`, columna `role`). A partir de ahi puedes loguearte y usar `POST /users` con `role: ADMIN` para crear mas administradores si lo necesitas.

### Campos modelo User

- **Registro publico:** `username`, `email`, `password` y opcional `preferredLocale`; `role` siempre **USER**, `emailVerified` false, `isActive` true.
- **Admin POST /users:** ademas opcionales `role`, `isActive`, `emailVerified`, `profileImageBase64`.
- `profileImageBase64` en columna PostgreSQL `TEXT`; cadena vacia en PATCH borra la imagen.

### Contenido

- `GET /categories` — lista; query `locale` opcional (resolucion global ver abajo)
- `GET /categories/:id` — detalle
- `GET /words` — lista paginada; query: `locale`, `level`, `categoryId`, `partOfSpeech`, `page`, `limit`
- `GET /words/:id` — detalle con categorias, ejemplos y kanji traducidos

### Progreso

- `GET /progress/dashboard` — JWT; lectura basica de `user_stats` (metricas extendidas pendientes en fases siguientes)

### Soporte

- `GET /health`
- `GET /locales`

Todas las rutas privadas usan cabecera: `Authorization: Bearer <token>`.

## Respuestas JSON

Exito:

```json
{ "success": true, "data": {} }
```

Listado paginado (cuando el handler devuelve items + meta):

```json
{
  "success": true,
  "data": [],
  "meta": { "page": 1, "limit": 20, "total": 100, "totalPages": 5 }
}
```

Error:

```json
{
  "success": false,
  "error": { "code": "WORD_NOT_FOUND", "message": "..." }
}
```

## Resolucion de `locale`

Orden (segun documento de API):

1. Query `locale=es|pt`
2. Cabecera `Accept-Language` (si contiene `pt` o `es`)
3. `preferredLocale` del usuario autenticado (si aplica)
4. Variable `DEFAULT_LOCALE` (por defecto `es`)

## Prisma y migraciones

- Esquema: `prisma/schema.prisma`
- Incluye `password_hash` en `users` para autenticacion (hash con bcrypt).
- Migracion inicial SQL: `prisma/migrations/20260429130000_init/migration.sql`

Si `prisma migrate dev` falla por credenciales, crea la base `yomu`, ajusta `DATABASE_URL` y vuelve a ejecutar `migrate deploy` o `migrate dev`.

## Seed

`prisma/seed.ts` carga:

- 26 categorias con traducciones `es` y `pt`
- ~15 palabras N5 de ejemplo con traducciones, categorias y algunos enlaces kanji

## Stack

- NestJS 11
- Prisma 6 (`schema` clasico con `url` en `datasource`)
- PostgreSQL
- JWT + Passport + bcrypt
- Helmet, CORS, validacion con `class-validator`

## Estructura `src/`

- `common/` — interceptor de envelope, filtro de errores, guards JWT, decoradores `@CurrentUser` y `@ResolvedLocale`
- `config/` — validacion de variables de entorno (Joi)
- `modules/` — `auth`, `users`, `categories`, `words`, `progress`, `health`, `kanji` (placeholder)
- `prisma/` — `PrismaModule` global
