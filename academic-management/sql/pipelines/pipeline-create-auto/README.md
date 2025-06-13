# Pipeline para Automatizar la Ejecución de Scripts SQL en PostgreSQL

Este script de Python automatiza la ejecución de archivos SQL para crear bases de datos, esquemas y tablas en PostgreSQL. Es especialmente útil para configurar rápidamente el entorno de base de datos **academic** para un sistema de gestion academica.

## Requisitos

- Python 3.6 o superior  
- Biblioteca `psycopg2` para la conexión con PostgreSQL

## Instalación

1. Asegúrate de tener Python instalado en tu sistema.
2. Instala las dependencias:

```bash
pip install psycopg2-binary
```

## Estructura de Archivos

El script busca automáticamente los siguientes archivos SQL:

1. `01-create-database.sql` – Crea el usuario, base de datos y esquema
2. `02-create-tables.sql` – Crea las tablas del sistema

Los archivos deben estar en el directorio especificado mediante `--sql-dir` o, si se omite, serán buscados automáticamente en la estructura del proyecto (por ejemplo, `scripts/ddl`).

---

## 🔄 Ejecución en Dos Pasos

1. Para ejecutar tu script, ve hasta la ruta donde tienes el script, la cual es `pipelines/pipeline-create-auto/`.
2. Activa tu entorno virtual `.\venv\Scripts\activate` y asegurate que las dependencias en el paso de _Instalación_ estén correctamente instaladas.
3. Prueba el script `test_connection` para validar si tu script y conección local es exitosa de la siguiente manera
   
    **Console**
    ```shell
    python .\test_connection.py localhost 5432 postgres your_password
    ``` 
    **Console Output**
    ```shell
    === Testing PostgreSQL Connection ===
    Host: localhost
    Port: 5432
    User: postgres
    Password: *********
    System locale: cp1252
    Python version: 3.13.3 (tags/v3.13.3:6280bb5, Apr  8 2025, 14:47:33) [MSC v.1943 64 bit (AMD64)]

    Attempting connection method 1 (keyword arguments)...
    ✅ Connection successful (Method 1)!

    Attempting connection method 2 (connection string)...
    ✅ Connection successful (Method 2)!

    Attempting connection method 3 (URI)...
    ✅ Connection successful (Method 3)!
    ```

4. Luego de validar, que el usuario si se puede conectar, viene la creación completa de la base de datos y sus tablas, para lograr esto se requiere que la ejecución se haga en **dos pasos independientes**, uno con el usuario administrador (`postgres`) y otro con el nuevo usuario de la aplicación (`sga_admin`):
   1. **🧩 Paso 1: Crear la base de datos y el esquema (como `postgres`)**
        
        Ejecuta el siguiente script, en una sola linea en la terminar actual, que tiene el entorno virtual activo y en la misma ruta
      ```bash
      python sql_pipeline_auto.py --user postgres --password "your_password" --db-name postgres --sql-dir ../../ddl --use-sql-for-db-creation
      ```
      **Console Output**
      ```shell
      2025-05-01 15:39:44,416 - sql_pipeline - INFO - Connecting to PostgreSQL at localhost:5432 with user postgres
      2025-05-01 15:39:44,416 - sql_pipeline - INFO - Using database: postgres, schema: academic
      2025-05-01 15:39:44,416 - sql_pipeline - INFO - SQL directory: ../../ddl
      2025-05-01 15:39:44,416 - sql_pipeline - INFO - Using SQL directory: ../../ddl
      2025-05-01 15:39:44,460 - sql_pipeline - INFO - Connected to PostgreSQL
      2025-05-01 15:39:44,460 - sql_pipeline - INFO - Executing database creation script: ../../ddl\01-create-database.sql
      2025-05-01 15:39:44,469 - sql_pipeline - INFO - Executing SQL statement 1 of 6
      2025-05-01 15:39:44,491 - sql_pipeline - INFO - Executing SQL statement 2 of 6
      2025-05-01 15:39:44,776 - sql_pipeline - INFO - Executing SQL statement 3 of 6
      2025-05-01 15:39:44,777 - sql_pipeline - INFO - Executing SQL statement 4 of 6
      2025-05-01 15:39:44,780 - sql_pipeline - INFO - Executing SQL statement 5 of 6
      2025-05-01 15:39:44,782 - sql_pipeline - INFO - Executing SQL statement 6 of 6
      2025-05-01 15:39:44,783 - sql_pipeline - INFO - Successfully executed SQL file: ../../ddl\01-create-database.sql
      2025-05-01 15:39:44,783 - sql_pipeline - INFO - Database created!
      2025-05-01 15:39:44,783 - sql_pipeline - INFO - SQL Pipeline completed successfully
      ``` 
    - Abrir una conexión desde SQL-Shell y validar si la base de datos y el usuario se crearon con la siguiente consulta
      ```sql
      SELECT 'rol' AS tipo, rolname AS nombre
      FROM pg_roles
      WHERE rolname = 'sga_admin'

      UNION ALL

      SELECT 'database' AS tipo, datname AS nombre
      FROM pg_database
      WHERE datname = 'academic_management_database'

      UNION ALL

      SELECT 'schema' AS tipo, schema_name AS nombre
      FROM information_schema.schemata
      WHERE schema_name = 'academic';
      ```
      **Console Output**
      ```shell
        tipo   |    nombre
        ----------+---------------
        rol      | sga_admin
        database | academic_management_database
        schema   | academic
        (3 filas)
      ```
   - Este paso ejecuta `01-create-database.sql` dentro de la base `postgres`. Aquí se crea:

     - El nuevo usuario (`sga_admin`)
     - La base de datos `academic_management_database`
     - El esquema `academic` en esa base
     - Comentarios opcionales
---
   2. **🧩 Paso 2: Crear tablas y cargar datos (como `sga_admin`)**
        
        Ejecuta el siguiente script, en una sola linea en la terminar actual, que tiene el entorno virtual activo y en la misma ruta
      ```bash
      python sql_pipeline_auto.py --user sga_admin --password "password_academic_user" --db-name academic_management_database --sql-dir ../../ddl
      ```

      **Console Output**
      ```shell
      2025-06-06 11:39:37,333 - sql_pipeline - INFO - Connecting to PostgreSQL at localhost:5432 with user sga_admin
      2025-06-06 11:39:37,333 - sql_pipeline - INFO - Using database: academic_management_database, schema: academic
      2025-06-06 11:39:37,333 - sql_pipeline - INFO - SQL directory: ../../ddl
      2025-06-06 11:39:37,333 - sql_pipeline - INFO - Using SQL directory: ../../ddl
      2025-06-06 11:39:37,374 - sql_pipeline - INFO - Connected to PostgreSQL - academic_management_database
      2025-06-06 11:39:37,377 - sql_pipeline - INFO - Schema 'academic' created successfully
      2025-06-06 11:39:37,377 - sql_pipeline - INFO - Skipping ../../ddl\01-create-database.sql - Database already created via code
      2025-06-06 11:39:37,377 - sql_pipeline - INFO - Executing ../../ddl\02-create-tables.sql
      2025-06-06 11:39:37,385 - sql_pipeline - INFO - Executing SQL statement 1 of 35
      2025-06-06 11:39:37,393 - sql_pipeline - INFO - Executing SQL statement 2 of 35
      2025-06-06 11:39:37,395 - sql_pipeline - INFO - Executing SQL statement 3 of 35
      2025-06-06 11:39:37,397 - sql_pipeline - INFO - Executing SQL statement 4 of 35
      2025-06-06 11:39:37,399 - sql_pipeline - INFO - Executing SQL statement 5 of 35
      2025-06-06 11:39:37,401 - sql_pipeline - INFO - Executing SQL statement 6 of 35
      2025-06-06 11:39:37,404 - sql_pipeline - INFO - Executing SQL statement 7 of 35
      2025-06-06 11:39:37,407 - sql_pipeline - INFO - Executing SQL statement 8 of 35
      2025-06-06 11:39:37,409 - sql_pipeline - INFO - Executing SQL statement 9 of 35
      2025-06-06 11:39:37,411 - sql_pipeline - INFO - Executing SQL statement 10 of 35
      2025-06-06 11:39:37,414 - sql_pipeline - INFO - Executing SQL statement 11 of 35
      2025-06-06 11:39:37,415 - sql_pipeline - INFO - Executing SQL statement 12 of 35
      2025-06-06 11:39:37,419 - sql_pipeline - INFO - Executing SQL statement 13 of 35
      2025-06-06 11:39:37,422 - sql_pipeline - INFO - Executing SQL statement 14 of 35
      2025-06-06 11:39:37,423 - sql_pipeline - INFO - Executing SQL statement 15 of 35
      2025-06-06 11:39:37,424 - sql_pipeline - INFO - Executing SQL statement 16 of 35
      2025-06-06 11:39:37,425 - sql_pipeline - INFO - Executing SQL statement 17 of 35
      2025-06-06 11:39:37,426 - sql_pipeline - INFO - Executing SQL statement 18 of 35
      2025-06-06 11:39:37,427 - sql_pipeline - INFO - Executing SQL statement 19 of 35
      2025-06-06 11:39:37,428 - sql_pipeline - INFO - Executing SQL statement 20 of 35
      2025-06-06 11:39:37,429 - sql_pipeline - INFO - Executing SQL statement 21 of 35
      2025-06-06 11:39:37,430 - sql_pipeline - INFO - Executing SQL statement 22 of 35
      2025-06-06 11:39:37,431 - sql_pipeline - INFO - Executing SQL statement 23 of 35
      2025-06-06 11:39:37,431 - sql_pipeline - INFO - Executing SQL statement 24 of 35
      2025-06-06 11:39:37,432 - sql_pipeline - INFO - Executing SQL statement 25 of 35
      2025-06-06 11:39:37,433 - sql_pipeline - INFO - Executing SQL statement 26 of 35
      2025-06-06 11:39:37,434 - sql_pipeline - INFO - Executing SQL statement 27 of 35
      2025-06-06 11:39:37,435 - sql_pipeline - INFO - Executing SQL statement 28 of 35
      2025-06-06 11:39:37,436 - sql_pipeline - INFO - Executing SQL statement 29 of 35
      2025-06-06 11:39:37,437 - sql_pipeline - INFO - Executing SQL statement 30 of 35
      2025-06-06 11:39:37,438 - sql_pipeline - INFO - Executing SQL statement 31 of 35
      2025-06-06 11:39:37,438 - sql_pipeline - INFO - Executing SQL statement 32 of 35
      2025-06-06 11:39:37,439 - sql_pipeline - INFO - Executing SQL statement 33 of 35
      2025-06-06 11:39:37,440 - sql_pipeline - INFO - Executing SQL statement 34 of 35
      2025-06-06 11:39:37,441 - sql_pipeline - INFO - Executing SQL statement 35 of 35
      2025-06-06 11:39:37,442 - sql_pipeline - INFO - Successfully executed SQL file: ../../ddl\02-create-tables.sql
      2025-06-06 11:39:37,442 - sql_pipeline - INFO - SQL Pipeline completed successfully
      ```
      - Abrir una conexión desde SQL-Shell y conectarse con el usuario `sga_admin` y la base de datos `academic_management_database` y validar si las tablas están creadas en el esquema con la siguiente consulta
  
        ```sql
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = 'academic';
        ```
        **Console Output**

          ```shell
           table_schema |    table_name
          --------------+-------------------
           academic     | course
           academic     | period
           academic     | course_assignment
           academic     | evaluation
           academic     | professor
           academic     | grade_evaluation
           academic     | prerequisite
           academic     | student
           academic     | student_audit
           academic     | enrollment
           academic     | room
           academic     | schedule
          (12 filas)
          ```
   - Este paso se conecta directamente a la base `academic_management_database` y ejecuta:

     - `02-create-tables.sql` para crear las tablas.

     
   3. **🧩 Paso 3: Crear Funcion y Trigger de Auditoria**
      Ejecuta el siguiente script, en una sola linea en la terminar actual, que tiene el entorno virtual activo y en la misma ruta
      ```bash
      python execute_triggers.py --host localhost --port 5432 --user sga_admin --password "your_password" --database academic_management_database --sql-file ../../ddl/03-create-trigger.sql
      ```

      **Console Output**
      ```shell
      🚀 Starting SQL trigger execution
      ==================================================
      🔄 Executing SQL file: ../../ddl/03-create-trigger.sql
      📍 Database: academic_management_database
      🖥️  Server: localhost:5432
      👤 User: sga_admin
      --------------------------------------------------
      ✅ Output:
      CREATE FUNCTION
      CREATE TRIGGER

      ✅ SQL file executed successfully
      ==================================================
      🎉 Process completed successfully
      📝 Trigger 'trigger_audit_student' has been created
      📊 Function 'audit_student_changes()' is ready      
      ```
      - Abrir una conexión desde SQL-Shell y conectarse con el usuario `sga_admin` y la base de datos `academic_management_database` y validar si el trigger esta creado. Haz lo siguiente:

        ```sql
        \df academic.audit_student_changes;
        ```
        **Console Output**
        ```shell
                                              Listado de funciones
         Esquema  |        Nombre         | Tipo de dato de salida | Tipos de datos de argumentos | Tipo
        ----------+-----------------------+------------------------+------------------------------+------
         academic | audit_student_changes | trigger                |                              | func
        (1 fila)
        ```

        Luego verificamos si el trigger se ha creado:

        ```sql
        SELECT 
        trigger_name,
        event_manipulation,
        action_timing,
        action_statement
        FROM information_schema.triggers 
        WHERE event_object_schema = 'academic' 
        AND event_object_table = 'student';
        ```

        **Console Output**
        ```shell
             trigger_name      | event_manipulation | action_timing |                 action_statement
        -----------------------+--------------------+---------------+---------------------------------------------------
         trigger_audit_student | INSERT             | AFTER         | EXECUTE FUNCTION academic.audit_student_changes()
         trigger_audit_student | DELETE             | AFTER         | EXECUTE FUNCTION academic.audit_student_changes()
         trigger_audit_student | UPDATE             | AFTER         | EXECUTE FUNCTION academic.audit_student_changes()
        (3 filas)
        ```
---

   

## Opciones Disponibles

- `--host`: Host de PostgreSQL (predeterminado: localhost)
- `--port`: Puerto de PostgreSQL (predeterminado: 5432)
- `--user`: Usuario de PostgreSQL (obligatorio)
- `--password`: Contraseña del usuario (obligatorio)
- `--db-name`: Base de datos a usar o crear (predeterminado: academic_management_database)
- `--schema-name`: Esquema a crear o usar (predeterminado: academic)
- `--sql-dir`: Ruta donde están los archivos SQL (predeterminado: búsqueda automática)
- `--use-sql-for-db-creation`: Ejecuta el archivo `01-create-database.sql` como parte del proceso


---

## Notas Importantes

- **No ejecutes ambos pasos con el mismo usuario**: el primer paso requiere privilegios administrativos (`postgres`) y el segundo, el usuario creado (`sga_admin`).
- Si `01-create-database.sql` no existe, el script puede crear la base de datos y el esquema directamente desde código (modo alternativo).
- Para mayor seguridad, usa variables de entorno para las credenciales.
