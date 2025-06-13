-- Consultas SQL complejas - Proyecto Sistema de Gestión Académica (SGA)
-- Fecha de generación: 2025-06-08

-- 1. Top 5 estudiantes con mejor promedio en curso 1 durante 2025A
SELECT ge.student_id, ROUND(AVG(ge.grade), 2) AS promedio
FROM academic.grade_evaluation ge
INNER JOIN academic.evaluation ev ON ge.evaluation_id = ev.evaluation_id
INNER JOIN academic.course_assignment ca ON ev.course_id = ca.course_id AND ca.period_id = '2025A'
WHERE ev.course_id = 1
GROUP BY ge.student_id
ORDER BY promedio DESC
LIMIT 5;

-- 2. Cursos con promedio > 4.0 en 2025A
SELECT ev.course_id, ROUND(AVG(ge.grade), 2) AS promedio
FROM academic.grade_evaluation ge
INNER JOIN academic.evaluation ev ON ge.evaluation_id = ev.evaluation_id
INNER JOIN academic.course_assignment ca ON ev.course_id = ca.course_id AND ca.period_id = '2025A'
GROUP BY ev.course_id
HAVING AVG(ge.grade) > 4.0;

-- 3. Salones más usados en 2025A
SELECT s.room_id, COUNT(*) AS sesiones
FROM academic.schedule s
WHERE s.period_id = '2025A'
GROUP BY s.room_id
ORDER BY sesiones DESC;

-- 4. Matrículas por día en 2025A
SELECT enrollment_date, COUNT(*) AS total_matriculas
FROM academic.enrollment
WHERE period_id = '2025A'
GROUP BY enrollment_date
ORDER BY enrollment_date;

-- 5. Unión entre cursos con prerrequisitos y cursos con exámenes después del 2025-06-01
SELECT course_id FROM academic.prerequisite
UNION
SELECT course_id FROM academic.evaluation
WHERE type = 'EXAM' AND date > '2025-06-01';

-- 6. Top 10 cursos con más evaluaciones y cantidad de docentes asignados
SELECT ev.course_id, COUNT(ev.evaluation_id) AS total_evaluaciones,
       COUNT(DISTINCT ca.professor_id) AS total_docentes
FROM academic.evaluation ev
INNER JOIN academic.course_assignment ca ON ev.course_id = ca.course_id
GROUP BY ev.course_id
ORDER BY total_evaluaciones DESC
LIMIT 10;

-- 7. Estudiantes por curso y profesor en 2025A
SELECT ca.professor_id, ca.course_id, COUNT(DISTINCT e.student_id) AS total_estudiantes
FROM academic.course_assignment ca
INNER JOIN academic.enrollment e ON e.course_id = ca.course_id AND e.period_id = ca.period_id
WHERE ca.period_id = '2025A'
GROUP BY ca.professor_id, ca.course_id;

-- 8. Evaluaciones por mes entre 2024-03-01 y 2025-03-31
SELECT DATE_TRUNC('month', date) AS mes, COUNT(*) AS total_evaluaciones
FROM academic.evaluation
WHERE date BETWEEN '2024-03-01' AND '2025-03-31'
GROUP BY mes
ORDER BY mes;

-- 9. Cursos con matrícula en 2025A pero sin evaluaciones registradas
SELECT DISTINCT e.course_id
FROM academic.enrollment e
WHERE e.period_id = '2025A'
  AND NOT EXISTS (
      SELECT 1 FROM academic.evaluation ev
      WHERE ev.course_id = e.course_id
  );

-- 10. Estudiantes con más notas y su promedio
SELECT ge.student_id, COUNT(*) AS total_notas, ROUND(AVG(ge.grade), 2) AS promedio_general
FROM academic.grade_evaluation ge
GROUP BY ge.student_id
ORDER BY total_notas DESC;