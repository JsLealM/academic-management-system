-- ##################################################
-- #            TableDefinitions                    #
-- ##################################################

-- Table: SYSTEM_USER
-- Brief: System users with access roles and permissions for audit tracking
-- Fields: user_id (PK, auto-increment), full_name (varchar(255)), email (varchar(255), unique), 
--         position (varchar(75)), role (varchar(75))
CREATE TABLE academic.SYSTEM_USER (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    position VARCHAR(75),
    role VARCHAR(75) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: STUDENT
-- Brief: Student information including personal details and academic status
-- Fields: student_id (PK, integer), first_name (varchar(25)), middle_name (varchar(25)), 
--         last_name (varchar(25)), maternal_surname (varchar(25)), birth_date (date), 
--         email (varchar(255), unique), status (varchar(20))
CREATE TABLE academic.STUDENT (
    student_id INTEGER PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    middle_name VARCHAR(25),
    last_name VARCHAR(25) NOT NULL,
    maternal_surname VARCHAR(25),
    birth_date DATE NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'GRADUATED', 'SUSPENDED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: PROFESSOR
-- Brief: Professor information including academic credentials and contact details
-- Fields: professor_id (PK, integer), first_name (varchar(25)), last_name (varchar(25)), 
--         email (varchar(255), unique), grade (varchar(75))
CREATE TABLE academic.PROFESSOR (
    professor_id INTEGER PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    grade VARCHAR(75),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: COURSE
-- Brief: Course catalog with academic details and credit information
-- Fields: course_id (PK, auto-increment), name (varchar(255)), credits (int), type (varchar(12))
CREATE TABLE academic.COURSE (
    course_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    credits INTEGER NOT NULL CHECK (credits > 0),
    type VARCHAR(12) NOT NULL CHECK (type IN ('CORE', 'ELECTIVE', 'MANDATORY')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: PERIOD
-- Brief: Academic periods defining semester/term boundaries and status
-- Fields: period_id (PK, varchar(20)), start_date (date), end_date (date), status (varchar(20))
CREATE TABLE academic.PERIOD (
    period_id VARCHAR(20) PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_period_dates CHECK (end_date > start_date)
);

-- Table: ROOM
-- Brief: Physical classroom and facility information with capacity limits
-- Fields: room_id (PK, auto-increment), capacity (int), location (varchar(255))
CREATE TABLE academic.ROOM (
    room_id SERIAL PRIMARY KEY,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: ENROLLMENT
-- Brief: Student course registrations by academic period with enrollment tracking
-- Fields: enrollment_id (PK, auto-increment), student_id (FK), course_id (FK), 
--         period_id (FK), enrollment_date (date), status (varchar(20))
CREATE TABLE academic.ENROLLMENT (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    period_id VARCHAR(20) NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'ENROLLED' CHECK (status IN ('ENROLLED', 'DROPPED', 'COMPLETED', 'FAILED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, course_id, period_id)
);

-- Table: COURSE_ASSIGNMENT
-- Brief: Professor-to-course assignments by academic period for teaching responsibilities
-- Fields: assignment_id (PK, auto-increment), course_id (FK), professor_id (FK), period_id (FK)
CREATE TABLE academic.COURSE_ASSIGNMENT (
    assignment_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    period_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, professor_id, period_id)
);

-- Table: SCHEDULE
-- Brief: Class scheduling with time slots, rooms, and session types
-- Fields: schedule_id (PK, auto-increment), day (varchar(10)), start_time (time), 
--         end_time (time), session_type (varchar(12)), room_id (FK), course_id (FK), period_id (FK)
CREATE TABLE academic.SCHEDULE (
    schedule_id SERIAL PRIMARY KEY,
    day VARCHAR(10) NOT NULL CHECK (day IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_type VARCHAR(12) NOT NULL CHECK (session_type IN ('LECTURE', 'LAB', 'SEMINAR', 'TUTORIAL', 'EXAM')),
    room_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    period_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_schedule_times CHECK (end_time > start_time)
);

-- Table: EVALUATION
-- Brief: Course evaluations and assessment definitions with scheduling
-- Fields: evaluation_id (PK, auto-increment), type (varchar(20)), date (date), course_id (FK)
CREATE TABLE academic.EVALUATION (
    evaluation_id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL CHECK (type IN ('EXAM', 'QUIZ', 'PROJECT', 'ASSIGNMENT', 'PRESENTATION')),
    date DATE NOT NULL,
    course_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: NOTE_EVALUATION
-- Brief: Student grades and evaluation results with comments
-- Fields: evaluation_id (PK, FK), student_id (PK, FK), grade (decimal(5,2)), comments (text)
CREATE TABLE academic.NOTE_EVALUATION (
    evaluation_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,
    grade DECIMAL(5,2) NOT NULL CHECK (grade >= 0 AND grade <= 5),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (evaluation_id, student_id)
);

-- Table: PREREQUISITE
-- Brief: Course prerequisite relationships defining academic dependencies
-- Fields: course_id (PK, FK), prerequisite_id (PK, FK)
CREATE TABLE academic.PREREQUISITE (
    course_id INTEGER NOT NULL,
    prerequisite_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (course_id, prerequisite_id),
    CONSTRAINT chk_no_self_prerequisite CHECK (course_id != prerequisite_id)
);

-- Table: AUDIT_LOG
-- Brief: System audit trail for data changes and user actions with full tracking
-- Fields: log_id (PK, auto-increment), user_id (FK), table_name (varchar(100)), 
--         action_type (varchar(20)), action_timestamp (timestamp), previous_values (text), 
--         new_values (text), affected_row_id (int)
CREATE TABLE academic.AUDIT_LOG (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE','READ')),
    action_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    previous_values TEXT,
    new_values TEXT,
    affected_row_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ##################################################
-- #           RELATIONSHIP DEFINITIONS             #
-- ##################################################

-- Relationships for ENROLLMENT
ALTER TABLE academic.ENROLLMENT ADD FOREIGN KEY (student_id) REFERENCES academic.STUDENT (student_id);
ALTER TABLE academic.ENROLLMENT ADD FOREIGN KEY (course_id) REFERENCES academic.COURSE (course_id);
ALTER TABLE academic.ENROLLMENT ADD FOREIGN KEY (period_id) REFERENCES academic.PERIOD (period_id);

-- Relationships for COURSE_ASSIGNMENT
ALTER TABLE academic.COURSE_ASSIGNMENT ADD FOREIGN KEY (course_id) REFERENCES academic.COURSE (course_id);
ALTER TABLE academic.COURSE_ASSIGNMENT ADD FOREIGN KEY (professor_id) REFERENCES academic.PROFESSOR (professor_id);
ALTER TABLE academic.COURSE_ASSIGNMENT ADD FOREIGN KEY (period_id) REFERENCES academic.PERIOD (period_id);

-- Relationships for SCHEDULE
ALTER TABLE academic.SCHEDULE ADD FOREIGN KEY (room_id) REFERENCES academic.ROOM (room_id);
ALTER TABLE academic.SCHEDULE ADD FOREIGN KEY (course_id) REFERENCES academic.COURSE (course_id);
ALTER TABLE academic.SCHEDULE ADD FOREIGN KEY (period_id) REFERENCES academic.PERIOD (period_id);

-- Relationships for EVALUATION
ALTER TABLE academic.EVALUATION ADD FOREIGN KEY (course_id) REFERENCES academic.COURSE (course_id);

-- Relationships for NOTE_EVALUATION
ALTER TABLE academic.NOTE_EVALUATION ADD FOREIGN KEY (evaluation_id) REFERENCES academic.EVALUATION (evaluation_id);
ALTER TABLE academic.NOTE_EVALUATION ADD FOREIGN KEY (student_id) REFERENCES academic.STUDENT (student_id);

-- Relationships for PREREQUISITE
ALTER TABLE academic.PREREQUISITE ADD FOREIGN KEY (course_id) REFERENCES academic.COURSE (course_id);
ALTER TABLE academic.PREREQUISITE ADD FOREIGN KEY (prerequisite_id) REFERENCES academic.COURSE (course_id);

-- Relationships for AUDIT_LOG
ALTER TABLE academic.AUDIT_LOG ADD FOREIGN KEY (user_id) REFERENCES academic.SYSTEM_USER (user_id);

-- ##################################################
-- #            PERFORMANCE INDICES                 #
-- ##################################################

-- Indexes for better query performance
CREATE INDEX idx_student_email ON academic.STUDENT (email);
CREATE INDEX idx_student_status ON academic.STUDENT (status);
CREATE INDEX idx_professor_email ON academic.PROFESSOR (email);
CREATE INDEX idx_enrollment_student_period ON academic.ENROLLMENT (student_id, period_id);
CREATE INDEX idx_enrollment_course_period ON academic.ENROLLMENT (course_id, period_id);
CREATE INDEX idx_schedule_day_time ON academic.SCHEDULE (day, start_time, end_time);
CREATE INDEX idx_schedule_room_period ON academic.SCHEDULE (room_id, period_id);
CREATE INDEX idx_evaluation_course_date ON academic.EVALUATION (course_id, date);
CREATE INDEX idx_audit_timestamp ON academic.AUDIT_LOG (action_timestamp);
CREATE INDEX idx_audit_table_action ON academic.AUDIT_LOG (table_name, action_type);

-- ##################################################
-- #               END DOCUMENTATION                #
-- ##################################################