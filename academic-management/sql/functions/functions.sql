--CALCULA EL PROMEDIO DE NOTAS DE UN ESTUDIANTE EN UN CURSO ESPECÍFICO,
--CONSIDERANDO ÚNICAMENTE LAS EVALUACIONES DEL PERÍODO ACADÉMICO INDICADO.
CREATE OR REPLACE FUNCTION academic.fn_avg_grade_by_course_period(
    p_student_id INT,
    p_course_id INT,
    p_period_id VARCHAR
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT AVG(ge.grade)
        FROM academic.grade_evaluation ge
        INNER JOIN academic.evaluation ev 
        ON ge.evaluation_id = ev.evaluation_id
        INNER JOIN academic.course_assignment ca 
        ON ca.course_id = ev.course_id AND ca.period_id = p_period_id
        WHERE ge.student_id = p_student_id
          AND ev.course_id = p_course_id
          AND ca.period_id = p_period_id
    );
END;
$$ LANGUAGE plpgsql;

--DEVUELVE LA CANTIDAD DE ESTUDIANTES MATRICULADOS EN UN CURSO ESPECÍFICO DURANTE UN PERÍODO DETERMINADO.
CREATE OR REPLACE FUNCTION academic.fn_total_students_by_course_and_period(
    p_course_id INT,
    p_period_id VARCHAR
)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(DISTINCT student_id) AS total_students
        FROM academic.enrollment
        WHERE course_id = p_course_id
          AND period_id = p_period_id
          AND status = 'ENROLLED'
    );
END;
$$ LANGUAGE plpgsql;

