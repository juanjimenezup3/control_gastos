# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/).

---

## [Unreleased]

### En desarrollo
- Sistema de anuncios AdMob
- Features premium
- Sincronización en la nube

---

## [0.9.5] - 2026-02-26

### Added
- Pestañas GASTOS y TAREAS
- Botones de gastos hormiga ($2.000, $5.000, $10.000)
- Modelo de Tarea con notificaciones
- Fecha y hora en tareas
- Editar gastos y tareas
- Vibración al eliminar
- Texto de ayuda "Mantén presionado para eliminar"

### Fixed
- Organización del código en carpetas (models, screens, services)
- Persistencia de datos con Hive

---

## [0.9.0] - 2026-02-25

### Added
- Control de gastos e ingresos
- Historial de gastos
- Checkboxes para marcar gastos como pagados
- Fecha de vencimiento en gastos
- Notificaciones de vencimiento
- Estadísticas básicas (gráfica de torta)
- Exportar a PDF/Excel básico

### Technical
- Integración de Hive para persistencia local
- flutter_local_notifications
- intl para formato de fechas y moneda
- Separación de código en modelos

---

## [0.1.0] - 2026-02-12

### Added
- Versión inicial del proyecto
- Instalación de Flutter
- Estructura básica de la app