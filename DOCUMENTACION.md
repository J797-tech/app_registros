# Informe Detallado de Desarrollo - Protocolo Unidad 4 (Final)
**Proyecto:** App de Registros con Flutter & Backend Node.js
**Estado:** Aplicación Full-Stack Desplegada

---

## 1. Evolución del Proyecto

### De Local a Global
El proyecto ha trascendido la persistencia local en `shared_preferences` para convertirse en una solución **Full-Stack**. Se ha implementado un servidor propio y una base de datos en la nube, permitiendo que el usuario mantenga sus datos seguros y accesibles desde cualquier dispositivo.

---

## 2. Arquitectura Técnica Actualizada

### Backend (API REST)
*   **Motor:** Node.js con Express.
*   **Base de Datos:** MongoDB (NoSQL) para un manejo flexible de documentos (Tareas y Usuarios).
*   **Seguridad:** Encriptación de contraseñas mediante `bcrypt` y preparación para tokens `JWT`.
*   **Despliegue:** Alojado en **Render** (PaaS), garantizando disponibilidad vía HTTPS.

### Frontend (Flutter)
*   **Comunicación:** Cliente HTTP (`http` package) configurado para interactuar con la API en la nube.
*   **Sincronización:** Las preferencias de usuario (Tema y Color) se guardan tanto localmente (para carga rápida) como en el servidor (para persistencia entre dispositivos).
*   **Modelo de Datos:** Implementación de `TaskModel` para mapear de forma limpia las respuestas JSON del servidor.

---

## 3. Lista de Tareas Realizadas (Backlog Finalizado)

*   [x] **Infraestructura:** Creación del servidor Node.js y conexión a MongoDB Atlas.
*   [x] **Migración de Datos:** Los registros pasaron de archivos locales a documentos en la nube.
*   [x] **Seguridad:** Implementación de rutas de Registro e Inicio de Sesión.
*   [x] **Identidad Visual:** Generación de un nuevo set de iconos de aplicación profesionales mediante `flutter_launcher_icons`.
*   [x] **Estadísticas Reales:** Implementación de lógica en el servidor para calcular efectividad y conteo de tareas en tiempo real.
*   [x] **Despliegue:** Configuración y lanzamiento exitoso en la URL de producción de Render.

---

## 4. Diseño y UX Mejorado

### Branding
Se reemplazó el icono genérico de Flutter por uno personalizado que integra gráficas y un lápiz, reforzando la temática de "Gestión y Análisis".

### Rendimiento
*   **Caché Híbrida:** La app carga los últimos datos locales mientras espera la respuesta del servidor, mejorando la sensación de velocidad.
*   **Feedback:** Manejo de estados de carga (Loading) durante las peticiones a la API.

---

## 5. Pruebas y Validación

*   **Prueba de Conectividad:** Verificación de acceso desde dispositivos físicos Android a través de redes móviles hacia el servidor en Render.
*   **Ciclo CRUD:** Creación, edición, completado y eliminación masiva de tareas verificado contra la base de datos MongoDB.
*   **Persistencia de Perfil:** Se comprobó que al cambiar el color de la app en un dispositivo, este se mantiene al cerrar sesión y volver a entrar.

---

## 6. Manual de Configuración Técnica

### URL de la API
La aplicación apunta actualmente a: `https://overunidad4.onrender.com/api`

### Comandos de Mantenimiento
*   **Generar APK:** `flutter build apk`
*   **Actualizar Iconos:** `dart run flutter_launcher_icons`
*   **Sincronizar Git:** `git push origin main`

---
**Conclusión:** La aplicación ha alcanzado su madurez técnica, cumpliendo con los estándares de una aplicación moderna: Segura, Sincronizada y con una Experiencia de Usuario pulida.
