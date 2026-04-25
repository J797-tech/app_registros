# Informe Detallado de Desarrollo - Protocolo Unidad 3
**Proyecto:** App de Registros con Flutter
**Estado:** Prototipo Funcional Finalizado

---

## 1. Objetivos de la Aplicación

### Objetivo General
Desarrollar una solución móvil multiplataforma que permita la gestión eficiente de información personal mediante un sistema CRUD (Crear, Leer, Actualizar, Borrar), integrando persistencia de datos local y una interfaz de usuario altamente personalizable.

### Objetivos Específicos
*   **Funcionalidad:** Implementar un flujo de usuario completo que abarque desde la bienvenida y autenticación por nombre hasta la gestión de registros categorizados.
*   **Persistencia:** Utilizar almacenamiento local (`shared_preferences`) para mantener la integridad de los datos y las preferencias estéticas del usuario entre sesiones.
*   **Interfaz:** Aplicar los principios de **Material 3** para ofrecer una experiencia visual moderna, adaptativa y personalizable mediante colores semilla.

---

## 2. Lista de Tareas (Backlog)

El desarrollo se organizó siguiendo una metodología por módulos para asegurar un código limpio:
*   [x] **Módulo de Datos:** Creación del `PreferencesService` para manejar el guardado y carga de archivos JSON.
*   [x] **Interfaz de Acceso:** Desarrollo de la `WelcomePage` y el sistema de Login basado en perfiles únicos.
*   [x] **Gestión Central (CRUD):** Implementación de la lógica para insertar, listar, editar y eliminar registros en `HomePage`.
*   [x] **Personalización:** Desarrollo de la `SettingsPage` para el control de temas (Claro/Oscuro) y selección de colores.
*   [x] **Integración de Estilos:** Configuración de `Google Fonts (Poppins)` y esquemas de color dinámicos.

---

## 3. Diseño UI/UX

### Prototipado y Flujo
Se diseñó un flujo de usuario intuitivo y sin fricciones:
1.  **Entrada:** Bienvenida visual con imagen motivacional.
2.  **Identificación:** Registro de nombre para personalizar la base de datos local.
3.  **Gestión:** Panel principal con un formulario superior de fácil acceso y una lista cronológica inferior.
4.  **Configuración:** Menú lateral (Drawer) y acceso rápido a ajustes de apariencia.

### Validación Visual
*   **Tipografía:** Se seleccionó *Poppins* por su equilibrio entre modernidad y legibilidad.
*   **Componentes:** Uso de `Cards` con bordes redondeados (20.0) y `FilledButtons` para una estética limpia y amigable.
*   **Color Dinámico:** La app genera toda su paleta a partir de un único color elegido por el usuario (`seedColor`), garantizando armonía visual.

---

## 4. Desarrollo en Flutter

### Modularidad y Componentes
*   **Separación de Responsabilidades:** La lógica de almacenamiento está aislada en un servicio independiente, lo que permite cambiar la base de datos en el futuro sin afectar la interfaz.
*   **Gestión de Estados:** Se utiliza `setState` de forma eficiente para actualizar la UI instantáneamente al guardar o borrar registros.
*   **Componentes Reutilizables:** El sistema de temas en `main.dart` actúa como un proveedor de estilo para todas las pantallas del proyecto.

### Buenas Prácticas
*   **Nomenclatura:** Uso de nombres descriptivos (ej. `_saveOrUpdateRecord`, `_editingIndex`).
*   **Código Ordenado:** Estructura de archivos clara y uso de comentarios para facilitar el trabajo colaborativo.

---

## 5. Realización de Pruebas

### Validación Funcional
*   **CRUD:** Se verificó que el formulario actualice los registros existentes en lugar de crear duplicados cuando se está en modo edición.
*   **Persistencia:** Prueba de "reinicio en frío" (cerrar y abrir app) confirmando que los registros y el color elegido no se pierden.
*   **Validación:** El sistema impide el guardado de campos vacíos mediante validadores de formulario.

### Experiencia del Usuario (UX)
*   Se revisó la fluidez de las transiciones entre páginas.
*   El **Modo Oscuro** fue optimizado para mejorar la comodidad visual en entornos con poca luz.

---

## 6. Registro de Funcionalidades y Uso

### Funcionalidades Implementadas
*   **Categorización:** Clasificación de registros en: *General, Trabajo, Personal e Importante*.
*   **Sellos de Tiempo:** Registro automático de la fecha y hora de cada entrada.
*   **Sesión Inteligente:** La app detecta si ya existe un usuario activo para saltar el login automáticamente.

### Manual de Uso Rápido
1.  **Inicio:** Presione "COMENZAR" e ingrese su nombre.
2.  **Registrar:** Escriba una nota en el cuadro superior, elija una categoría y pulse "GUARDAR".
3.  **Editar/Borrar:** Use los iconos de la derecha en cada tarjeta del historial.
4.  **Personalizar:** Vaya a Ajustes para cambiar el color de la app o activar el modo noche.

---
**Conclusión:** Este proyecto representa un prototipo funcional robusto que cumple íntegramente con los requisitos de desarrollo colaborativo y buenas prácticas de la Unidad 3.
