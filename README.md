# Inventario Móvil La Convicción

Aplicación móvil de **La Convicción** para llevar el control de productos, repartidores y reportes de inventario. Está desarrollada con Flutter y guarda la información localmente en una base de datos SQLite.

## Funciones principales

- **Productos y categorías:** registrar y organizar productos con su precio y categoría.
- **Repartidores:** registrar y editar los repartidores asociados a los reportes.
- **Observadores:** administrar los usuarios que registran inventario e iniciar sesión mediante un PIN de cuatro dígitos.
- **Reportes de inventario:** crear, consultar, editar y eliminar reportes por fecha, repartidor y observador, con el detalle de los productos registrados.
- **Exportación:** generar y compartir el resumen de un reporte en PDF.

## Requisitos

- Flutter instalado y configurado para ejecutar aplicaciones móviles.
- Dart compatible con la versión indicada en `pubspec.yaml` (SDK `^3.10.7`).
- Un dispositivo o emulador Android o iOS.

## Ejecutar el proyecto

Desde la raíz del repositorio:

```bash
flutter pub get
flutter run
```

Para ejecutar las pruebas disponibles:

```bash
flutter test
```

## Datos

La aplicación crea automáticamente la base de datos SQLite `control_reparto.db` en el dispositivo. Los datos se mantienen en ese dispositivo; esta versión no incluye sincronización en la nube.
