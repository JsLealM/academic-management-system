CREATE OR REPLACE FUNCTION academic.audit_student_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Manejo de operación DELETE
    IF TG_OP = 'DELETE' THEN
        INSERT INTO academic.student_audit (
            action_type, student_id,
            old_first_name, old_middle_name, old_last_name, old_maternal_surname,
            old_birth_date, old_email, old_status
        ) VALUES (
            'DELETE', OLD.student_id,
            OLD.first_name, OLD.middle_name, OLD.last_name, OLD.maternal_surname,
            OLD.birth_date, OLD.email, OLD.status
        );
        RETURN OLD;
    END IF;

    -- Manejo de operación INSERT
    IF TG_OP = 'INSERT' THEN
        INSERT INTO academic.student_audit (
            action_type, student_id,
            new_first_name, new_middle_name, new_last_name, new_maternal_surname,
            new_birth_date, new_email, new_status
        ) VALUES (
            'INSERT', NEW.student_id,
            NEW.first_name, NEW.middle_name, NEW.last_name, NEW.maternal_surname,
            NEW.birth_date, NEW.email, NEW.status
        );
        RETURN NEW;
    END IF;

    -- Manejo de operación UPDATE
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO academic.student_audit (
            action_type, student_id,
            old_first_name, old_middle_name, old_last_name, old_maternal_surname,
            old_birth_date, old_email, old_status,
            new_first_name, new_middle_name, new_last_name, new_maternal_surname,
            new_birth_date, new_email, new_status
        ) VALUES (
            'UPDATE', NEW.student_id,
            OLD.first_name, OLD.middle_name, OLD.last_name, OLD.maternal_surname,
            OLD.birth_date, OLD.email, OLD.status,
            NEW.first_name, NEW.middle_name, NEW.last_name, NEW.maternal_surname,
            NEW.birth_date, NEW.email, NEW.status
        );
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger
CREATE TRIGGER trigger_audit_student
AFTER INSERT OR UPDATE OR DELETE
ON academic.student
FOR EACH ROW
EXECUTE FUNCTION academic.audit_student_changes();