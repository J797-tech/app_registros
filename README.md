# 📱 Gestor Personal

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material--3-7D5260?style=for-the-badge&logo=materialdesign&logoColor=white)

**Gestor Personal** es una solución móvil integral diseñada para la organización de la vida cotidiana. Enfocada en la privacidad y la experiencia de usuario, permite gestionar registros diarios bajo un entorno seguro, multiusuario y altamente personalizable.

---

## 📖 Tabla de Contenidos
- [Características Destacadas](#-características-destacadas)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación y Configuración](#-instalación-y-configuración)

---

## 🚀 Características Destacadas

### 👥 Experiencia Multi-Usuario
- **Aislamiento de Datos**: Cada perfil cuenta con su propio almacenamiento mediante prefijos de usuario.
- **Sesión Persistente**: Implementación de acceso automático para una entrada sin fricciones.

### 📝 Gestión de Registros (CRUD)
- **Categorización**: Organiza tus notas en: *Trabajo, Personal, Importante o General*.
- **Historial Estampado**: Registro preciso de fecha y hora mediante `intl`.
- **Edición Reactiva**: Modifica registros existentes al instante.

### 🎨 Personalización UI/UX
- **Material 3**: Interfaz moderna con componentes dinámicos.
- **Engine de Temas**: 
  - Selector de colores semilla dinámico.
  - Soporte para **Modo Oscuro** y **Modo Claro**.
- **Tipografía**: Integración con Google Fonts (Poppins).

### 🛡️ Seguridad y Migración
- **Visualización Segura**: Control de visibilidad en contraseñas.
- **Motor de Migración**: Al actualizar un usuario, el sistema transfiere automáticamente todos los datos a la nueva identidad.

---

## 🏗️ Arquitectura del Sistema

La aplicación sigue un patrón de **Separación de Responsabilidades**:

1.  **Capa de Presentación (UI)**: Localizada en `lib/*.dart`, gestiona la interacción del usuario.
2.  **Capa de Lógica de Negocio**: Controlada por el estado global en `main.dart`.
3.  **Capa de Persistencia**: Encapsulada en `PreferencesService` para centralizar el uso de `SharedPreferences`.

---

## 🛠️ Stack Tecnológico

| Tecnología | Propósito |
| :--- | :--- |
| **Flutter** | Framework de desarrollo UI |
| **Dart** | Lenguaje de programación |
| **Shared Preferences** | Persistencia de datos local |
| **Google Fonts** | Tipografía personalizada |
| **Intl** | Formateo de fechas |

---

## 📁 Estructura del Proyecto

```bash
lib/
├── main.dart               # Orquestador global y Tematización
├── preferences_service.dart # Servicio de persistencia y Migraciones
├── welcome_page.dart       # Landing page de bienvenida
├── login_page.dart          # Autenticación y Registro
├── home_page.dart           # Dashboard y Gestión de registros
└── settings_page.dart       # Perfil y Personalización visual
```

---

## ⚙️ Instalación y Configuración

### Pasos
1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/app_registros.git
   ```
2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```
3. **Ejecutar:**
   ```bash
   flutter run
   ```

---
*Desarrollado para la organización de registros personales.*
