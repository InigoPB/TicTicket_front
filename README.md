# TicTicket_front
Front del proyecto TFG para DAM desarrollado por Alberto Aceña Bartolome e Iñigo Pascual Bogajo


# TICKEA – Guía Completa de Instalación, Configuración y Ejecución

## Descripción general

**TICKEA** es un sistema completo para el registro y análisis de tickets de compra mediante OCR y almacenamiento en base de datos.  
Incluye:

- **App móvil / Flutter (TICKEAFRONT)**  
- **Backend Spring Boot (TICKEABACK)**  
- **Base de datos MySQL en Aiven**  
- **Integración con UiPath Orchestrator** (OCR automatizado)  
- **Firebase** (autenticación y Firestore)  
- **Diseño en Figma y seguimiento en Jira**

Este documento explica paso a paso cómo levantar **todas las partes del sistema desde cero**, tanto en local como mediante la **zona de cobertura inalámbrica móvil (hotspot)** para probar en un dispositivo real.

---

## 1. Accesos y enlaces

| Recurso | Enlace / Forma de acceso |
|----------|--------------------------|
| **Frontend (Flutter)** | [Repositorio TICKEAFRONT](https://github.com/usuario/tickea_front) |
| **Backend (Spring Boot)** | [Repositorio TICKEABACK](https://github.com/usuario/tickea_back) |
| **Diseño Figma** | [Enlace al diseño](https://www.figma.com/file/xxxxx/TickeaApp) |
| **Jira (gestión de tareas)** | [Enlace al tablero](https://tickea.atlassian.net/jira/software/c/projects/TIC/board) |
| **Firebase Console** | [Proyecto Firebase](https://console.firebase.google.com/project/tickea-project) |
| **Base de datos (Aiven MySQL)** | Conexión mediante variables de entorno (`DB_URL`, `DB_USER`, `DB_PASSWORD`) |
| **UiPath Orchestrator** | Configuración hardcodeada en backend (no requiere cambios) |

> Si el profesor no puede acceder a alguno de los enlaces, dale permisos de **"Viewer"** en Figma, Jira y Firebase.

---

## 2. Requisitos de software

| Entorno | Versión mínima | Comentario |
|----------|----------------|-------------|
| **Java** | 17 | Requerido para el backend |
| **Maven** | 3.8+ | Gestión de dependencias |
| **Flutter** | 3.24.x | (SDK compatible con Dart 3.5.x) |
| **Dart** | ^3.5.3 | Definido en `pubspec.yaml` |
| **Android SDK** | Última estable | Si se ejecuta en emulador o dispositivo físico |
| **Navegador (para Web)** | Chrome o Edge | Para ejecutar Flutter Web |

---

## 3. Variables de entorno (Backend)

El backend **no incluye credenciales en el código**.  
Antes de arrancar, define las siguientes variables (ajusta con tus valores):

### macOS / Linux
```bash
export DB_URL="jdbc:mysql://HOST:PORT/defaultdb?ssl-mode=REQUIRED"
export DB_USER="tickeaAdmin"
export DB_PASSWORD="AVNS_XXXXXX"
export SERVER_PORT=8080
export SPRING_PROFILES_ACTIVE=local
