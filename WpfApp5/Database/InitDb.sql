-- Ініціалізація бази даних для освітньої платформи
-- Створення схеми та таблиць

-- Створення розширень
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Створення таблиці користувачів
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Student', 'Teacher', 'Admin')),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50),
    profile_image_url TEXT,
    department VARCHAR(255),
    group_name VARCHAR(255), -- Для студентів
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці курсів
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    teacher_id UUID NOT NULL REFERENCES users(id),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Зв'язок багато-до-багатьох між студентами та курсами
CREATE TABLE IF NOT EXISTS course_enrollments (
    student_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    enrollment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id)
);

-- Створення таблиці модулів
CREATE TABLE IF NOT EXISTS modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL,
    unlock_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці навчальних матеріалів
CREATE TABLE IF NOT EXISTS learning_materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id UUID NOT NULL REFERENCES modules(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    material_type VARCHAR(20) NOT NULL CHECK (material_type IN ('Text', 'Video', 'PDF', 'Presentation', 'Link', 'Assignment')),
    content_url TEXT,
    content TEXT,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці завдань
CREATE TABLE IF NOT EXISTS assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    course_id UUID NOT NULL REFERENCES courses(id),
    module_id UUID NOT NULL REFERENCES modules(id),
    deadline TIMESTAMP WITH TIME ZONE,
    max_points INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці здачі завдань
CREATE TABLE IF NOT EXISTS submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID NOT NULL REFERENCES assignments(id),
    student_id UUID NOT NULL REFERENCES users(id),
    content TEXT,
    file_url TEXT,
    submission_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    grade INTEGER,
    feedback TEXT,
    graded_by UUID REFERENCES users(id),
    graded_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці тестів
CREATE TABLE IF NOT EXISTS tests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    course_id UUID REFERENCES courses(id),
    module_id UUID REFERENCES modules(id),
    time_limit INTEGER, -- в хвилинах
    passing_score INTEGER NOT NULL,
    max_attempts INTEGER DEFAULT 1,
    randomize_questions BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці запитань
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_id UUID NOT NULL REFERENCES tests(id),
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) NOT NULL CHECK (question_type IN ('SingleChoice', 'MultipleChoice', 'TrueFalse', 'Text')),
    points INTEGER NOT NULL DEFAULT 1,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Створення таблиці варіантів відповідей
CREATE TABLE IF NOT EXISTS question_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES questions(id),
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    order_index INTEGER NOT NULL
);

-- Створення таблиці результатів тестів
CREATE TABLE IF NOT EXISTS test_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_id UUID NOT NULL REFERENCES tests(id),
    student_id UUID NOT NULL REFERENCES users(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    score INTEGER,
    max_score INTEGER,
    attempt_number INTEGER NOT NULL,
    status VARCHAR(20) CHECK (status IN ('InProgress', 'Completed', 'Expired')),
    UNIQUE (test_id, student_id, attempt_number)
);

-- Створення таблиці відповідей на запитання
CREATE TABLE IF NOT EXISTS question_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_attempt_id UUID NOT NULL REFERENCES test_attempts(id),
    question_id UUID NOT NULL REFERENCES questions(id),
    selected_options UUID[],
    text_answer TEXT,
    is_correct BOOLEAN,
    points_earned INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Створення таблиці розкладу
CREATE TABLE IF NOT EXISTS schedule_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('Lecture', 'Seminar', 'Practice', 'Consultation', 'Exam', 'Other')),
    course_id UUID REFERENCES courses(id),
    teacher_id UUID REFERENCES users(id),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    location VARCHAR(255),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці учасників подій розкладу
CREATE TABLE IF NOT EXISTS schedule_participants (
    event_id UUID REFERENCES schedule_events(id),
    user_id UUID REFERENCES users(id),
    attendance_status VARCHAR(20) CHECK (attendance_status IN ('Present', 'Absent', 'Late', 'Unknown')),
    PRIMARY KEY (event_id, user_id)
);

-- Створення таблиці повідомлень
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    subject VARCHAR(255),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_system_message BOOLEAN DEFAULT FALSE,
    parent_message_id UUID REFERENCES messages(id),
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці сповіщень
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    related_entity_id UUID,
    related_entity_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE
);

-- Створення таблиці аналітики успішності
CREATE TABLE IF NOT EXISTS student_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES users(id),
    course_id UUID NOT NULL REFERENCES courses(id),
    completion_percentage DECIMAL(5,2) DEFAULT 0,
    average_test_score DECIMAL(5,2),
    assignments_completed INTEGER DEFAULT 0,
    assignments_total INTEGER DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, course_id)
);

-- Створення тригерних функцій для автоматичного оновлення поля updated_at
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ language 'plpgsql';

-- Створення тригерів для всіх таблиць з полем updated_at
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_courses_timestamp BEFORE UPDATE ON courses
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_modules_timestamp BEFORE UPDATE ON modules
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_learning_materials_timestamp BEFORE UPDATE ON learning_materials
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_assignments_timestamp BEFORE UPDATE ON assignments
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_tests_timestamp BEFORE UPDATE ON tests
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_schedule_events_timestamp BEFORE UPDATE ON schedule_events
FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

-- Створення індексів для підвищення продуктивності
CREATE INDEX idx_courses_teacher_id ON courses(teacher_id);
CREATE INDEX idx_course_enrollments_student_id ON course_enrollments(student_id);
CREATE INDEX idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX idx_modules_course_id ON modules(course_id);
CREATE INDEX idx_learning_materials_module_id ON learning_materials(module_id);
CREATE INDEX idx_assignments_module_id ON assignments(module_id);
CREATE INDEX idx_submissions_assignment_id ON submissions(assignment_id);
CREATE INDEX idx_submissions_student_id ON submissions(student_id);
CREATE INDEX idx_tests_course_id ON tests(course_id);
CREATE INDEX idx_tests_module_id ON tests(module_id);
CREATE INDEX idx_questions_test_id ON questions(test_id);
CREATE INDEX idx_question_options_question_id ON question_options(question_id);
CREATE INDEX idx_test_attempts_test_id ON test_attempts(test_id);
CREATE INDEX idx_test_attempts_student_id ON test_attempts(student_id);
CREATE INDEX idx_question_responses_test_attempt_id ON question_responses(test_attempt_id);
CREATE INDEX idx_schedule_events_course_id ON schedule_events(course_id);
CREATE INDEX idx_schedule_events_teacher_id ON schedule_events(teacher_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_messages_course_id ON messages(course_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_student_progress_student_id ON student_progress(student_id);
CREATE INDEX idx_student_progress_course_id ON student_progress(course_id);

-- Додавання тестових даних для демонстрації
-- Вставка тестових користувачів
INSERT INTO users (id, full_name, role, email, phone_number, department, group_name, is_active)
VALUES
    (uuid_generate_v4(), 'Олександр Іванов', 'Admin', 'admin@edu.com', '+380991234567', 'Адміністрація', NULL, TRUE),
    (uuid_generate_v4(), 'Марія Петренко', 'Teacher', 'teacher1@edu.com', '+380992345678', 'Факультет інформатики', NULL, TRUE),
    (uuid_generate_v4(), 'Василь Коваленко', 'Teacher', 'teacher2@edu.com', '+380993456789', 'Факультет математики', NULL, TRUE),
    (uuid_generate_v4(), 'Ірина Шевченко', 'Student', 'student1@edu.com', '+380994567890', 'Факультет інформатики', 'ІПЗ-21', TRUE),
    (uuid_generate_v4(), 'Андрій Мельник', 'Student', 'student2@edu.com', '+380995678901', 'Факультет інформатики', 'ІПЗ-21', TRUE),
    (uuid_generate_v4(), 'Наталія Бондаренко', 'Student', 'student3@edu.com', '+380996789012', 'Факультет математики', 'МТ-22', TRUE);

-- Функції для отримання ID користувачів за їх роллю
CREATE OR REPLACE FUNCTION get_admin_id() RETURNS UUID AS $$
    SELECT id FROM users WHERE role = 'Admin' LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_teacher_id(index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM users WHERE role = 'Teacher' ORDER BY full_name LIMIT 1 OFFSET (index - 1);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_student_id(index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM users WHERE role = 'Student' ORDER BY full_name LIMIT 1 OFFSET (index - 1);
$$ LANGUAGE SQL;

-- Вставка тестових курсів
INSERT INTO courses (id, name, description, teacher_id, start_date, end_date, is_active)
VALUES
    (uuid_generate_v4(), 'Основи програмування', 'Введення в програмування та основні алгоритми', get_teacher_id(1), CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE + INTERVAL '60 days', TRUE),
    (uuid_generate_v4(), 'Математичний аналіз', 'Курс з основ математичного аналізу', get_teacher_id(2), CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE + INTERVAL '75 days', TRUE);

-- Функції для отримання ID курсів
CREATE OR REPLACE FUNCTION get_course_id(index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM courses ORDER BY name LIMIT 1 OFFSET (index - 1);
$$ LANGUAGE SQL;

-- Запис студентів на курси
INSERT INTO course_enrollments (student_id, course_id)
VALUES
    (get_student_id(1), get_course_id(1)),
    (get_student_id(2), get_course_id(1)),
    (get_student_id(3), get_course_id(1)),
    (get_student_id(1), get_course_id(2)),
    (get_student_id(3), get_course_id(2));

-- Створення тестових модулів
INSERT INTO modules (id, course_id, title, description, order_index, unlock_date)
VALUES
    (uuid_generate_v4(), get_course_id(1), 'Модуль 1: Введення в програмування', 'Базові поняття програмування', 1, CURRENT_DATE - INTERVAL '30 days'),
    (uuid_generate_v4(), get_course_id(1), 'Модуль 2: Базові алгоритми', 'Основні алгоритмічні конструкції', 2, CURRENT_DATE - INTERVAL '15 days'),
    (uuid_generate_v4(), get_course_id(1), 'Модуль 3: Структури даних', 'Основні структури даних', 3, CURRENT_DATE),
    (uuid_generate_v4(), get_course_id(2), 'Модуль 1: Вступ до математичного аналізу', 'Основні поняття та означення', 1, CURRENT_DATE - INTERVAL '15 days'),
    (uuid_generate_v4(), get_course_id(2), 'Модуль 2: Диференціювання функцій', 'Похідні та їх застосування', 2, CURRENT_DATE);

-- Функції для отримання ID модулів
CREATE OR REPLACE FUNCTION get_module_id(course_index INTEGER DEFAULT 1, module_index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM modules WHERE course_id = get_course_id(course_index) ORDER BY order_index LIMIT 1 OFFSET (module_index - 1);
$$ LANGUAGE SQL;

-- Створення тестових навчальних матеріалів
INSERT INTO learning_materials (module_id, title, description, material_type, content, order_index)
VALUES
    (get_module_id(1, 1), 'Вступ до програмування', 'Що таке програмування?', 'Text', 'Програмування - це процес створення комп''ютерних програм...', 1),
    (get_module_id(1, 1), 'Відео: Основи програмування', 'Вступна лекція', 'Video', 'https://example.com/intro_to_programming.mp4', 2),
    (get_module_id(1, 2), 'Умовні оператори', 'Розгалуження в програмах', 'Text', 'Умовний оператор - це конструкція, яка дозволяє виконувати різні дії в залежності від умови...', 1),
    (get_module_id(2, 1), 'Вступ до математичного аналізу', 'Основні поняття', 'Text', 'Математичний аналіз - це розділ математики, який вивчає функції...', 1);

-- Створення тестових тестів
INSERT INTO tests (id, title, description, course_id, module_id, time_limit, passing_score, max_attempts, is_active, start_date, end_date, created_by)
VALUES
    (uuid_generate_v4(), 'Тест 1: Основи програмування', 'Перевірка знань з основ програмування', get_course_id(1), get_module_id(1, 1), 30, 70, 2, TRUE, CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE + INTERVAL '10 days', get_teacher_id(1)),
    (uuid_generate_v4(), 'Тест 2: Алгоритми', 'Перевірка знань з алгоритмів', get_course_id(1), get_module_id(1, 2), 45, 75, 2, TRUE, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '25 days', get_teacher_id(1)),
    (uuid_generate_v4(), 'Тест 1: Математичний аналіз', 'Вступний тест з математичного аналізу', get_course_id(2), get_module_id(2, 1), 60, 70, 2, TRUE, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '20 days', get_teacher_id(2));

-- Функція для отримання ID тестів
CREATE OR REPLACE FUNCTION get_test_id(index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM tests ORDER BY title LIMIT 1 OFFSET (index - 1);
$$ LANGUAGE SQL;

-- Створення тестових запитань
INSERT INTO questions (test_id, question_text, question_type, points, order_index)
VALUES
    (get_test_id(1), 'Що таке змінна в програмуванні?', 'SingleChoice', 2, 1),
    (get_test_id(1), 'Які з наступних типів даних є примітивними?', 'MultipleChoice', 3, 2),
    (get_test_id(1), 'Цикл for використовується для повторення коду.', 'TrueFalse', 1, 3),
    (get_test_id(2), 'Опишіть принцип роботи бінарного пошуку.', 'Text', 4, 1),
    (get_test_id(3), 'Що таке границя функції?', 'SingleChoice', 2, 1);

-- Функція для отримання ID запитань
CREATE OR REPLACE FUNCTION get_question_id(test_index INTEGER DEFAULT 1, question_index INTEGER DEFAULT 1) RETURNS UUID AS $$
    SELECT id FROM questions WHERE test_id = get_test_id(test_index) ORDER BY order_index LIMIT 1 OFFSET (question_index - 1);
$$ LANGUAGE SQL;

-- Створення варіантів відповідей для запитань з вибором
INSERT INTO question_options (question_id, option_text, is_correct, order_index)
VALUES
    (get_question_id(1, 1), 'Змінна - це іменоване місце в пам''яті для зберігання даних', TRUE, 1),
    (get_question_id(1, 1), 'Змінна - це функція в програмі', FALSE, 2),
    (get_question_id(1, 1), 'Змінна - це спосіб створення циклів', FALSE, 3),
    (get_question_id(1, 1), 'Змінна - це умовний оператор', FALSE, 4),
    
    (get_question_id(1, 2), 'int', TRUE, 1),
    (get_question_id(1, 2), 'boolean', TRUE, 2),
    (get_question_id(1, 2), 'Array', FALSE, 3),
    (get_question_id(1, 2), 'char', TRUE, 4),
    (get_question_id(1, 2), 'Object', FALSE, 5),
    
    (get_question_id(1, 3), 'Так', TRUE, 1),
    (get_question_id(1, 3), 'Ні', FALSE, 2),
    
    (get_question_id(3, 1), 'Границя функції - це число, до якого наближаються значення функції при наближенні аргументу до заданої точки', TRUE, 1),
    (get_question_id(3, 1), 'Границя функції - це максимальне значення функції', FALSE, 2),
    (get_question_id(3, 1), 'Границя функції - це мінімальне значення функції', FALSE, 3),
    (get_question_id(3, 1), 'Границя функції - це середнє значення функції', FALSE, 4);

-- Створення тестових подій розкладу
INSERT INTO schedule_events (id, title, description, event_type, course_id, teacher_id, start_time, end_time, location)
VALUES
    (uuid_generate_v4(), 'Лекція: Вступ до програмування', 'Перша лекція з програмування', 'Lecture', get_course_id(1), get_teacher_id(1), CURRENT_DATE + INTERVAL '1 day' + INTERVAL '10 hours', CURRENT_DATE + INTERVAL '1 day' + INTERVAL '12 hours', 'Аудиторія 101'),
    (uuid_generate_v4(), 'Практичне заняття: Основи алгоритмізації', 'Розв''язання задач з алгоритмами', 'Practice', get_course_id(1), get_teacher_id(1), CURRENT_DATE + INTERVAL '3 days' + INTERVAL '14 hours', CURRENT_DATE + INTERVAL '3 days' + INTERVAL '16 hours', 'Комп''ютерний клас 201'),
    (uuid_generate_v4(), 'Лекція: Введення в математичний аналіз', 'Вступна лекція з математичного аналізу', 'Lecture', get_course_id(2), get_teacher_id(2), CURRENT_DATE + INTERVAL '2 days' + INTERVAL '9 hours', CURRENT_DATE + INTERVAL '2 days' + INTERVAL '11 hours', 'Аудиторія 305');

-- Створення тестових повідомлень
INSERT INTO messages (sender_id, receiver_id, course_id, subject, content, is_read)
VALUES
    (get_teacher_id(1), get_student_id(1), get_course_id(1), 'Консультація з програмування', 'Доброго дня! Запрошую вас на консультацію у четвер з 14:00 до 16:00 в аудиторії 101.', FALSE),
    (get_student_id(1), get_teacher_id(1), get_course_id(1), 'Re: Консультація з програмування', 'Дякую за запрошення! Я обов''язково прийду.', FALSE),
    (get_teacher_id(2), NULL, get_course_id(2), 'Важливе повідомлення для всіх студентів', 'Шановні студенти! Нагадую, що наступного тижня відбудеться контрольна робота. Будь ласка, підготуйтеся належним чином.', FALSE);

-- Створення тестових сповіщень
INSERT INTO notifications (user_id, title, message, notification_type, related_entity_id, related_entity_type)
VALUES
    (get_student_id(1), 'Новий тест доступний', 'Тест "Основи програмування" доступний для проходження', 'TestAvailable', get_test_id(1), 'Test'),
    (get_student_id(2), 'Новий тест доступний', 'Тест "Основи програмування" доступний для проходження', 'TestAvailable', get_test_id(1), 'Test'),
    (get_student_id(3), 'Новий тест доступний', 'Тест "Основи програмування" доступний для проходження', 'TestAvailable', get_test_id(1), 'Test'),
    (get_student_id(1), 'Нове повідомлення', 'У вас нове повідомлення від викладача', 'NewMessage', NULL, 'Message');

-- Очищення тимчасових функцій
DROP FUNCTION IF EXISTS get_admin_id();
DROP FUNCTION IF EXISTS get_teacher_id(INTEGER);
DROP FUNCTION IF EXISTS get_student_id(INTEGER);
DROP FUNCTION IF EXISTS get_course_id(INTEGER);
DROP FUNCTION IF EXISTS get_module_id(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS get_test_id(INTEGER);
DROP FUNCTION IF EXISTS get_question_id(INTEGER, INTEGER);