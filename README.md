# 📱 Gestor Personal Full-Stack

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![Render](https://img.shields.io/badge/Render-%2346E3B7.svg?style=for-the-badge&logo=render&logoColor=white)

**Gestor Personal** ha evolucionado de una aplicación local a una herramienta de productividad **Full-Stack**. Ahora permite la persistencia de datos en la nube y la sincronización multiplataforma mediante una arquitectura cliente-servidor robusta.

---

## 📖 Tabla de Contenidos
- [Características Destacadas](#-características-destacadas)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación y Configuración](#-instalación-y-configuración)

---

## 🚀 Características Destacadas

### ☁️ Sincronización en la Nube
- **Persistencia Real**: Todos tus datos se guardan en una base de datos MongoDB Atlas.
- **Acceso Remoto**: Gracias al despliegue en Render, puedes acceder a tus registros desde cualquier dispositivo con la app.

### 👤 Autenticación y Perfiles
- **Sistema de Cuentas**: Registro e inicio de sesión seguro con contraseñas encriptadas (bcrypt).
- **Preferencia de Usuario**: El Modo Oscuro y el Color Primario se sincronizan automáticamente con tu cuenta en el servidor.

### 📊 Estadísticas y Productividad
- **Panel de Control**: Visualización en tiempo real de tareas totales, completadas y efectividad en la sección de ajustes.
- **Historial Completo**: Gestión avanzada de tareas con posibilidad de limpieza total de historial.

### 🎨 Identidad Visual Renovada
- **Nuevo Icono**: Imagen de marca personalizada que representa productividad y análisis.
- **Material 3**: Interfaz refinada con colores dinámicos.

---

## 🏗️ Arquitectura del Sistema

La aplicación utiliza una arquitectura **MERN-like** adaptada para móvil:

1.  **Frontend (Flutter)**: Interfaz de usuario reactiva y gestión de estado local con `SharedPreferences` para caché.
2.  **Backend (Node.js/Express)**: API RESTful encargada de la lógica de negocio y seguridad.
3.  **Base de Datos (MongoDB)**: Almacenamiento NoSQL para flexibilidad en los registros de tareas y preferencias.

---

## 🛠️ Stack Tecnológico

| Tecnología | Propósito |
| :--- | :--- |
| **Flutter** | Desarrollo de la aplicación móvil |
| **Node.js & Express** | Servidor API REST |
| **MongoDB** | Base de Datos persistente |
| **Render** | Hosting del Backend |
| **Bcrypt & JWT** | Seguridad y Autenticación |

---

## 📁 Estructura del Proyecto

```bash
app_registros/          # Repositorio Frontend (Flutter)
├── lib/
│   ├── api_service.dart     # Comunicación con el Servidor Render
│   ├── preferences_service.dart # Caché local
│   ├── main.dart            # Temas y Navegación
│   └── ...                  # Pantallas (Home, Login, Settings)
└── assets/icon/             # Recursos visuales y Nuevo Icono

API_GESTION/            # Repositorio Backend (Node.js)
├── server.js                # Servidor Express y Rutas API
├── models/                  # Esquemas de MongoDB (User, Task, Prefs)
└── .env                     # Configuración de variables (Puerto 3001)
```

---

## ⚙️ Instalación y Configuración

### Backend
1. Navegar a la carpeta del servidor.
2. Ejecutar `npm install`.
3. Configurar variables de entorno y ejecutar con `npm start` (usa el puerto 3001 por defecto).

### Frontend
1. Asegurarse de tener la URL de la API correcta en `api_service.dart`.
2. Ejecutar `flutter pub get`.
3. Ejecutar `flutter run` para desarrollo o `flutter build apk` para generar el instalador.

---
*Gestor Personal: Productividad real, sincronizada y segura.*
