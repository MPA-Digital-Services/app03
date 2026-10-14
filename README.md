# app03 · Northwind Móvil

Aplicación móvil **Flutter (Material 3)** que consume la API REST **NorthwindApi** de
`app02` (ASP.NET Core sobre la base de datos Northwind). Permite consultar el panel de
ventas, gestionar el catálogo CRUD, explorar vistas y procedimientos, y administrar las
líneas de los pedidos.

## Funcionalidad

| Pestaña      | Contenido                                                                 |
|--------------|---------------------------------------------------------------------------|
| Panel        | Resumen (ventas, pedidos, ticket medio, clientes, productos), ventas por mes, estado de pedidos, productos más vendidos, mejores clientes y pedidos recientes |
| Catálogo     | Las 10 entidades CRUD (categorías, transportistas, proveedores, clientes, empleados, productos, pedidos, regiones, territorios, perfiles demográficos) con búsqueda, orden, paginación, alta, edición y borrado |
| Consultas    | Explorador de las 16 vistas de solo lectura y ejecución de los 7 procedimientos almacenados con sus parámetros |
| Ajustes      | URL base de la API (persistida en el dispositivo) y prueba de conexión (`/health`) |

Además, el detalle de cada pedido muestra su cabecera y permite **añadir, editar y
eliminar líneas** (`/api/orders/{id}/details`).

La URL base por defecto es `http://localhost:5297`, excepto en el **emulador de
Android**, donde es `http://10.0.2.2:5297` (alias del host). Se puede sobreescribir en
tiempo de compilación con `--dart-define=API_BASE_URL=http://mi-servidor:5297` o en
tiempo de ejecución desde **Ajustes**.

## Requisitos

- **Flutter SDK** (canal estable; `sdk: ^3.11.1` según `pubspec.yaml`).
- Un dispositivo o emulador (Android / iOS), o un navegador (Chrome) para la versión web.
- La API `app02` en ejecución y accesible desde el dispositivo
  (`dotnet run --project src/NorthwindApi.Api`).

## Pasos para desarrollar

### 1. Obtener las dependencias

```sh
flutter pub get
```

### 2. Levantar la API (app02)

```powershell
dotnet run --project ..\app02\src\NorthwindApi.Api
```

Verifique `http://localhost:5297/health` y `http://localhost:5297/swagger`.

### 3. Ejecutar la app

```sh
# Dispositivo conectado o emulador en marcha (ver `flutter devices`)
flutter run

# Contra una API en otra máquina o puerto:
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5297

# Versión web (útil para depurar rápido contra localhost):
flutter run -d chrome
```

> En Android físico la URL `localhost` apunta al propio teléfono: use la IP del PC en
> la red local y configúrela en **Ajustes** o con `--dart-define`.

### 4. Analizar y probar

```sh
flutter analyze   # análisis estático (flutter_lints)
flutter test      # pruebas unitarias y de widgets
```

| Prueba                | Qué cubre                                              |
|-----------------------|--------------------------------------------------------|
| `test/formatters_test.dart`     | Formato de fechas, números, moneda y porcentajes |
| `test/paged_result_test.dart`   | Deserialización de resultados paginados          |
| `test/api_exception_test.dart`  | Traducción de errores HTTP/ProblemDetails        |
| `test/widget_test.dart`         | Widget de gráfico de barras (`SimpleBarChart`)   |

### 5. Compilar para distribuir

```sh
flutter build apk --release                          # Android
flutter build appbundle --release                    # Android (Play Store)
flutter build ipa --release                          # iOS (requiere macOS + Xcode)
flutter build web --release                          # Web estática
```

## Estructura

```
lib/
  main.dart                 Arranque: ajustes, ApiClient y MaterialApp
  app/home_shell.dart       Navegación inferior (Panel, Catálogo, Consultas, Ajustes)
  core/
    config/                 URL base (AppConfig) y preferencias (AppSettings)
    network/                ApiClient (http + ProblemDetails) y ApiException
    models/                 PagedResult genérico
    crud/                   Framework genérico: EntitySpec, FieldSpec, lista y formulario
    theme/                  Temas claro/oscuro (Material 3, sigue al sistema)
    utils/                  Formateadores en español (Fmt)
    widgets/                AppScope, AsyncView, gráficos, tarjetas
  features/
    dashboard/              API, modelos y pantalla del panel
    catalog/                Descriptores de entidades, catálogo y loaders de referencia
    orders/                 API, modelo y pantalla de líneas del pedido
    views/                  API, modelo y pantallas del explorador de vistas
    procedures/             API, catálogo y pantalla de procedimientos
    queries/                Pestaña que agrupa vistas y procedimientos
    settings/               Pantalla de ajustes de conexión
test/                       Pruebas unitarias y de widgets
```

## Cómo extender

### Agregar una entidad al catálogo

1. Añada su descriptor en `lib/features/catalog/entity_descriptors.dart` (`EntitySpec`
   con `route`, `idField`, `searchParam`, `sortParam` y `fields`).
2. Si otros formularios la referencian, añada un loader en
   `lib/features/catalog/reference_loaders.dart` y úselo como `optionsLoader`.
3. Aparecerá automáticamente en `CatalogScreen`; la lista, el formulario y el borrado
   los aporta el framework de `core/crud`.

### Agregar un procedimiento almacenado

1. Regístrelo en `lib/features/procedures/models/procedures_catalog.dart` (ruta y
   parámetros de ruta/consulta).
2. Si devuelve una forma nueva, añada el parseo en `lib/features/procedures/data/procedures_api.dart`.
3. Aparecerá automáticamente en `ProceduresScreen`.

### Cambiar la URL de la API

- En desarrollo: `--dart-define=API_BASE_URL=...` o la pantalla de **Ajustes**.
- El valor se normaliza (esquema `http`, sin barras finales) y se persiste con
  `shared_preferences`.

## Convenciones

- DTO de la API en `camelCase` (serialización por defecto de ASP.NET Core).
- Errores HTTP → `ApiException` (red, 400 con errores por campo, 404, 409, 500),
  mostrados con `AsyncView` y `SnackBar`.
- Formato en español (`Fmt.money`, `Fmt.number`, `Fmt.date`, `Fmt.percent`).
- Comentarios de documentación (`///`) en español en la API pública.
