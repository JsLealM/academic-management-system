INSERT INTO academic.schedule (day, start_time, end_time, session_type, room_id, course_id, period_id)
VALUES
('MONDAY',    '08:00', '10:00', 'LECTURE',   1,  1, '2024A'),
('TUESDAY',   '10:00', '12:00', 'LECTURE',   2,  2, '2024A'),
('WEDNESDAY', '14:00', '16:00', 'LAB',       3,  3, '2024A'),
('THURSDAY',  '08:00', '10:00', 'LECTURE',   4,  4, '2024B'),
('FRIDAY',    '10:00', '12:00', 'SEMINAR',   5,  5, '2024B'),
('MONDAY',    '13:00', '15:00', 'LECTURE',   6,  6, '2025A'),
('TUESDAY',   '09:00', '11:00', 'TUTORIAL',  7,  7, '2025A'),
('WEDNESDAY', '15:00', '17:00', 'LECTURE',   8,  8, '2025A'),
('THURSDAY',  '11:00', '13:00', 'TUTORIAL',  9,  9, '2025A'), -- Corregido (antes era EXAM)
('FRIDAY',    '08:00', '10:00', 'LECTURE',  10, 10, '2025A');
