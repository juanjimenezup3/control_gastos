# 💰 Priority Control Gastos

App profesional de control financiero personal con gastos compartidos, modo viaje y sincronización en la nube.

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-v3.19+-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-v3.3+-blue?logo=dart" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
</div>

---

## 🚀 Features

### ✅ FREE (Con anuncios)
- 📊 Gastos e ingresos ilimitados
- 🐜 Gastos hormiga (registro rápido)
- ✅ Tareas con notificaciones
- 💰 Editar saldo manualmente
- 🏷️ Gastos fijos y variables
- 🎨 Tipos de ingreso con colores
- 👥 Gastos compartidos
- ✈️ Modo Viaje/Tesorero
- 📅 Calendario avanzado
- 📄 Exportar PDF/Excel
- 📸 Escanear documentos
- 📊 Estadísticas avanzadas

### ⭐ PREMIUM ($9.99 pago único)
- 🚫 Sin anuncios
- ☁️ Sincronización en la nube
- 🔐 Backup automático
- 🎨 Temas personalizados
- 📧 Reportes mensuales por email
- 📞 Soporte prioritario

---

## 🛠️ Tecnologías

- **Framework:** Flutter 3.19+
- **Lenguaje:** Dart 3.3+
- **Base de datos local:** Hive
- **Notificaciones:** flutter_local_notifications
- **Anuncios:** Google AdMob
- **Nube:** Firebase (Auth, Firestore, Storage)
- **Pagos:** in_app_purchase

---

## 📦 Instalación

### Requisitos previos
- Flutter SDK 3.19 o superior
- Android Studio / VS Code
- Git

### Pasos
```bash
# Clonar repositorio
git clone https://github.com/juanjimenezup3/control_gastos.git

# Entrar al directorio
cd control_gastos

# Instalar dependencias
flutter pub get

# Generar archivos de Hive
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release
```

---

## 🏗️ Arquitectura del Proyecto
```
lib/
├── models/              # Modelos de datos (Hive)
│   ├── gasto.dart
│   └── tarea.dart
├── screens/             # Pantallas de la app
│   ├── pantalla_inicio.dart
│   └── pantalla_estadisticas.dart
├── services/            # Servicios (notificaciones, ads, etc.)
│   └── notification_service.dart
├── widgets/             # Widgets reutilizables
└── main.dart            # Punto de entrada
```

---

## 🌿 Branches

- `main` - Código en producción (Play Store)
- `develop` - Desarrollo activo
- `feature/*` - Nuevas funcionalidades
- `hotfix/*` - Arreglos urgentes

---

## 📝 Commits Convencionales
```
feat: nueva funcionalidad
fix: corrección de bug
docs: cambios en documentación
chore: tareas de mantenimiento
refactor: refactorización de código
test: agregar o modificar tests
```

---

## 🧪 Testing
```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/
```

---

## 📱 Build para Producción

### Android (APK)
```bash
flutter build apk --release
```

### Android (App Bundle para Play Store)
```bash
flutter build appbundle --release
```

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

## 👨‍💻 Autor

**Juan Jiménez** - [GitHub](https://github.com/juanjimenezup3)

---

## 📞 Soporte

¿Encontraste un bug o tienes una sugerencia?
- Abre un [Issue](https://github.com/juanjimenezup3/control_gastos/issues)
- Contacto: [juan.fer.go@hotmail.com]
- 📞 Soporte prioritario
- 🔄 Actualizaciones de por vida

---

<div align="center">
  Hecho con ❤️ en Colombia 🇨🇴
</div>