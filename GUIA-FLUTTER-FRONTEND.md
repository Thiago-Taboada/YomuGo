# Guía rápida — Frontend Flutter (login / registro)

Orientación para el cliente en `frontend/`, especialmente la pantalla de autenticación y el i18n del proyecto YomuGo.

---

## 1. Punto de entrada: `frontend/lib/main.dart`

Ahí arranca la aplicación (`void main()` → `runApp`).

- **`YomuGoApp`**: es un `StatefulWidget` que guarda el **idioma de la interfaz** (`Locale`: español o portugués) y se lo pasa a `MaterialApp` con `locale: _locale`.
- **`_toggleUiLocale`**: alterna entre `es` y `pt` al pulsar el botón redondo de la pantalla de auth.
- **`MaterialApp`**: define delegados de traducción, `theme: buildDarkTheme()` (tema oscuro global) y `home: AuthPage(...)`.

Para cambiar/editar el **idioma por defecto** de la UI: el valor inicial de `Locale _locale` en `_YomuGoAppState`.

---

## 2. Pantalla login / registro: `frontend/lib/features/auth/auth_page.dart`

Archivo principal de esa pantalla.

| Pieza | Rol |
|--------|-----|
| **`AuthPage`** (`StatefulWidget`) | Pantalla completa: formularios, pestañas login/registro, registro contra la API. |
| **`_AuthPageState`** | Estado: `TextEditingController`, contraseña visible/oculta, pestaña activa, idioma de **cuenta** (`_accountPreferredLocale`), estado de envío. |
| **`Scaffold` + `Stack`** | Cuerpo con `LayoutBuilder` (ancho vs móvil) y el **botón redondo** de idioma UI (`_UiLocaleRoundButton`). |
| **`_BrandingColumn`** | Panel de marca: título, subtítulo, lista de features, cita. |
| **`_FormColumn`** | Formulario: toggle login/registro, campos, botón principal, legales, caja info, **selector idioma de cuenta** (solo registro). |
| **`_AuthModeToggle` / `_ToggleChip`** | Píldoras «Iniciar sesión» / «Crear cuenta». |

**Dónde editar:**

- **Textos visibles**: preferible vía **ARB** (sección 4), usando `l10n.algo` en el código.
- **Disposición de campos y bloques UI**: sobre todo **`_FormColumn`** y **`_BrandingColumn`** en este mismo archivo.
- **Validación, llamada a la API, diálogo con la respuesta**: métodos como **`_submitRegister`** y **`_showApiAlert`** en **`_AuthPageState`**.

---

## 3. Estilos: `frontend/lib/app/app_theme.dart`

- **`AppColors`**: fondo, superficies, acento violeta, textos secundarios, etc.
- **`buildDarkTheme()`**: `ColorScheme` oscuro, `InputDecorationTheme` (campos), `FilledButtonThemeData` (botón principal).

Para cambiar el **aspecto global** (colores, bordes redondeados del tema), empezar aquí. `auth_page.dart` también usa `AppColors` en muchos sitios.

---

## 4. Idiomas (i18n)

Alineado con `Documento guia i18n.md`: textos de interfaz en Flutter.

**Archivos a editar al traducir o cambiar frases:**

- `frontend/lib/l10n/app_es.arb`
- `frontend/lib/l10n/app_pt.arb`

Cada clave debe existir en **ambos** ARB con el mismo nombre.

**Archivos generados** (suelen regenerarse; coherencia con ARB):

- `frontend/lib/l10n/app_localizations.dart`
- `frontend/lib/l10n/app_localizations_es.dart`
- `frontend/lib/l10n/app_localizations_pt.dart`

Tras modificar solo los ARB:

```bash
cd frontend
flutter gen-l10n
```

(o `flutter pub get`, según tu flujo / IDE).

**Uso en código:**

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.authTabLogin);
```

**Dos niveles de «idioma» en auth:**

1. **Idioma de la interfaz**: `MaterialApp.locale` — botón redondo ES/PT; los textos salen del ARB según ese locale.
2. **Idioma de la cuenta** (`preferredLocale` en API): `SegmentedButton` en registro; va en el `POST /auth/register` y puede diferir del idioma de la UI.

---

## 5. API de registro

- **`frontend/lib/core/api_config.dart`**: URL base; se puede sobrescribir con `--dart-define=API_BASE_URL=...`.
- **`frontend/lib/data/auth_api.dart`**: `register(...)` → `POST /auth/register`.

---

## 6. Conceptos útiles (Flutter)

- **Widget**: casi todo es un widget; **sin estado** (`StatelessWidget`) o **con estado** (`StatefulWidget` + `State`).
- **`BuildContext`**: tema, `AppLocalizations.of(context)`, navegación, `ScaffoldMessenger`.
- **`setState`**: notifica que el estado cambió y hay que volver a construir la UI.
- **Desarrollo web**: con `flutter run -d chrome`, usar **hot reload** (`r`) / **hot restart** (`R`) en la terminal; solo recargar el navegador no equivale a recompilar el código Dart.

---

## 7. Mapa «¿dónde toco esto?»

| Objetivo | Archivo(s) |
|----------|------------|
| Textos ES / PT | `lib/l10n/app_es.arb`, `app_pt.arb` |
| Estructura login/registro | `lib/features/auth/auth_page.dart` |
| Colores / tema Material | `lib/app/app_theme.dart` |
| Idioma por defecto de la app | `lib/main.dart` (`_locale`) |
| URL del backend | `lib/core/api_config.dart` + `dart-define` |
| Petición HTTP de registro | `lib/data/auth_api.dart` |

---

## 8. Tests

`frontend/test/widget_test.dart` es la plantilla por defecto. Si cambias `home` o el título de la app, el test puede fallar hasta actualizarlo.

---

## Ejecutar el frontend (web)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Backend (Nest) en el puerto configurado (p. ej. 3000) y CORS habilitado para desarrollo.
