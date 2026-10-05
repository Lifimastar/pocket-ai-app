# 📱 PocketAI — Smart Notes & Action Tracker

> Aplicación móvil desarrollada en Flutter conectada a Supabase y un microservicio backend en Python (FastAPI + IA) para procesar notas y extraer automáticamente tareas pendientes estructuradas.

---

## 🛠️ Stack Tecnológico

- **Frontend Móvil:** Flutter (Dart) — Arquitectura modular / Feature-first.
- **Backend & Almacenamiento:** Supabase (PostgreSQL, Row Level Security, Auth).
- **Servicio de IA / NLP:** Python (FastAPI, integración de LLMs para extracción de acciones).
- **Gestión de Estado:** Riverpod / Provider.

---

## 📂 Arquitectura del Proyecto

```text
lib/
├── core/           
└── features/      
```

---

## 🚀 Hoja de Ruta (Roadmap)

- [x] Configuración inicial del proyecto y arquitectura modular.
- [ ] Conexión y autenticación con Supabase.
- [ ] CRUD básico de notas en la app móvil.
- [ ] Integración con el microservicio FastAPI para análisis de texto con IA.
- [ ] Generación automática de tareas estructuradas con prioridades.
- [ ] Exportación y modo offline.

---

## ⚙️ Configuración Local

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/Lifimastar/pocket_ai_app.git
   cd pocket_ai_app
   ```
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Copiar archivo de entorno:
   ```bash
   cp .env.example .env
   ```
4. Ejecutar en emulador o dispositivo:
   ```bash
   flutter run
   ```

---
**Autor:** [Luis Urdaneta](https://github.com/Lifimastar) — Desarrollador Full-Stack (Python & Flutter)

