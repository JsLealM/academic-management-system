# 🎓 Academic Database Insert Pipeline

Este proyecto contiene un pipeline en Python para insertar datos de prueba en una base de datos PostgreSQL correspondiente a un sistema de gestión académica.

---
## 📁 Estructura del proyecto
```bash
sql/
├── ddl/
│ ├── 01-create-database.sql
│ └── 02-create-tables.sql
├── dml/
│ └── insert/
│ ├── 01-period.sql
│ ├── ...
│ └── 12-system_user.sql

pipelines/
├── insert-data/
│ ├── academic_pipeline.py
│ └── README.md
├── pipeline-create-auto/
│ ├── sql_pipeline_auto.py
│ ├── test_connection.py
│ └── README.md
```
---
## ⚙️ Requisitos

### 1. Python 3.8 o superior

```bash
python --version
```
### 2. Crear entorno virtual
```bash
python -m venv venv
```

### 3. Activar entorno:
```bash
Windows: venv\Scripts\activate
Linux/macOS: source venv/bin/activate
```

### 4. Instalar dependencias
```bash
pip install psycopg2-binary tqdm
```

### 5. Ejecutar pipeline de inserción 🚀
Desde la carpeta insert-data:
```bash
python academic_pipeline.py --user sga_admin --password "your-password" --db-name academic_management_database --schema-name academic --sql-dir ../../dml/insert
```
Si todo se ejecuta correctamente debe mostrar:
```bash
2025-06-06 11:48:30,232 - INFO - 🚀 Starting Academic SQL Data Pipeline
2025-06-06 11:48:30,270 - INFO - ✅ Connected to PostgreSQL
2025-06-06 11:48:30,284 - INFO - ✅ ../../dml/insert\01-period.sql executed successfully
2025-06-06 11:48:31,298 - INFO - ✅ ../../dml/insert\02-room.sql executed successfully
2025-06-06 11:48:32,305 - INFO - ✅ ../../dml/insert\03-student.sql executed successfully
2025-06-06 11:48:33,320 - INFO - ✅ ../../dml/insert\04-professor.sql executed successfully
2025-06-06 11:48:34,324 - INFO - ✅ ../../dml/insert\05-course.sql executed successfully
2025-06-06 11:48:35,344 - INFO - ✅ ../../dml/insert\06-course_assignment.sql executed successfully
2025-06-06 11:48:36,359 - INFO - ✅ ../../dml/insert\07-evaluation.sql executed successfully
2025-06-06 11:48:37,376 - INFO - ✅ ../../dml/insert\08-schedule.sql executed successfully
2025-06-06 11:48:38,393 - INFO - ✅ ../../dml/insert\09-enrollment.sql executed successfully
2025-06-06 11:48:39,408 - INFO - ✅ ../../dml/insert\10-grade_evaluation.sql executed successfully
2025-06-06 11:48:40,422 - INFO - ✅ ../../dml/insert\11-prerequisite.sql executed successfully
2025-06-06 11:48:41,423 - INFO - 🎓 Pipeline completed: 11/11 files loaded.
2025-06-06 11:48:41,423 - INFO - 🔒 Database connection closed.
```

---
## Validación de Datos Insertados
Para verificar que todos los datos se han insertado correctamente, puedes ejecutar la siguiente consulta SQL:

### Conexión a PostgreSQL

```bash
psql -U sga_admin -d academic_management_database -p 5432
```

### Consulta de Validación

```sql
SELECT 'period' AS table_name, COUNT(*) AS record_count FROM academic.period
UNION ALL
SELECT 'room', COUNT(*) FROM academic.room
UNION ALL
SELECT 'student', COUNT(*) FROM academic.student
UNION ALL
SELECT 'professor', COUNT(*) FROM academic.professor
UNION ALL
SELECT 'course', COUNT(*) FROM academic.course
UNION ALL
SELECT 'course_assignment', COUNT(*) FROM academic.course_assignment
UNION ALL
SELECT 'evaluation', COUNT(*) FROM academic.evaluation
UNION ALL
SELECT 'schedule', COUNT(*) FROM academic.schedule
UNION ALL
SELECT 'enrollment', COUNT(*) FROM academic.enrollment
UNION ALL
SELECT 'grade_evaluation', COUNT(*) FROM academic.grade_evaluation
UNION ALL
SELECT 'prerequisite', COUNT(*) FROM academic.prerequisite
UNION ALL
SELECT 'student_audit', COUNT(*) FROM academic.student_audit
ORDER BY table_name;
```
La consulta debe mostrar:
```bash
    table_name     | record_count
-------------------+--------------
 course            |           10
 course_assignment |           13
 enrollment        |           10
 evaluation        |           10
 grade_evaluation  |           10
 period            |           10
 prerequisite      |           10
 professor         |           10
 room              |           10
 schedule          |           10
 student           |           10
 student_audit     |           10
(12 filas)
```
---
## 📌 Recomendaciones

- Asegúrate de que el esquema `academic` exista antes de ejecutar el pipeline.
- Los archivos `.sql` deben tener sentencias terminadas con `;`.
- Los nombres de archivo deben mantener orden lógico con prefijo (`01-`, `02-`, etc.).
- Si usas AWS RDS, asegúrate de permitir tu IP en el grupo de seguridad del clúster.

---

## 👥 Autores

- [@Johan Leal](https://github.com/JsLealM)
- [@Briyith Moreno](https://github.com/Briyith-Moreno)
- [@Jefferson Pinzon](https://github.com/S4LPICON)


Proyecto Final — Base de Datos — 2025
