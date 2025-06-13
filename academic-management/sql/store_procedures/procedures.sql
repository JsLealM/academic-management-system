--ACTUALIZA EL ESTADO DEL ESTUDIANTE SI ESTE ESTA ACTIVO.
CREATE OR REPLACE PROCEDURE academic.sp_update_student_status_if_active(
    p_student_id INT,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM academic.student
        WHERE student_id = p_student_id AND status = 'ACTIVE'
    ) THEN
        UPDATE academic.student
        SET status = p_new_status
        WHERE student_id = p_student_id;
    END IF;
END;
$$;

--REPROGRAMA UNA CLASE SOLO SI NO HAY CONFLICTOS DE HORARIO CON OTRAS CLASES.
CREATE OR REPLACE PROCEDURE academic.sp_reschedule_course_if_no_conflict(
    p_schedule_id INT,
    p_new_day VARCHAR,
    p_new_start TIME,
    p_new_end TIME,
    p_new_room_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar conflicto con otra clase en el mismo salón, mismo día y franja horaria
    IF NOT EXISTS (
        SELECT 1
        FROM academic.schedule
        WHERE room_id = p_new_room_id
          AND day = p_new_day
          AND schedule_id <> p_schedule_id
          AND (
              (p_new_start < end_time AND p_new_end > start_time)  -- conflicto de horario
          )
    ) THEN
        -- Si no hay conflicto, actualizar el horario
        UPDATE academic.schedule
        SET day = p_new_day,
            start_time = p_new_start,
            end_time = p_new_end,
            room_id = p_new_room_id
        WHERE schedule_id = p_schedule_id;
    END IF;
END;
$$;

--REGISTRA LA CALIFICACIÓN DE UN ESTUDIANTE EN UNA EVALUACIÓN ESPECÍFICA, 
--PERO SOLO SI ESTÁ MATRICULADO EN EL CURSO Y NO TIENE UNA NOTA PREVIA EN ESA EVALUACIÓN.
CREATE OR REPLACE PROCEDURE academic.sp_register_student_grade(
    p_evaluation_id INT,
    p_student_id INT,
    p_grade NUMERIC,
    p_comment TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_course_id INT;
BEGIN
    -- Obtener el curso de la evaluación
    SELECT course_id INTO v_course_id
    FROM academic.evaluation
    WHERE evaluation_id = p_evaluation_id;
    
    -- Verificar si el estudiante está matriculado en ese curso
    IF EXISTS (
        SELECT 1 FROM academic.enrollment
        WHERE student_id = p_student_id AND course_id = v_course_id
    ) THEN
        -- Solo insertar si el estudiante no tiene nota en esta evaluación
        IF NOT EXISTS (
            SELECT 1 FROM academic.grade_evaluation 
            WHERE evaluation_id = p_evaluation_id AND student_id = p_student_id
        ) THEN
            INSERT INTO academic.grade_evaluation (
                evaluation_id, student_id, grade, comments
            ) VALUES (
                p_evaluation_id, p_student_id, p_grade, p_comment
            );
        END IF;
    END IF;
END;
$$;