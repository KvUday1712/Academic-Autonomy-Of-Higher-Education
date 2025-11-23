CREATE DATABASE IF NOT EXISTS academic_autonomy;
USE academic_autonomy;

--------------------------------------------------------
-- 1. STAFF TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    course VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role ENUM('Admin', 'Staff') DEFAULT 'Staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------
-- 2. STUDENTS TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    roll_no VARCHAR(100) UNIQUE,
    course VARCHAR(255) NOT NULL,
    session_year VARCHAR(20) NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    dob DATE,
    password VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------
-- 3. COURSE TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------
-- 4. SUBJECT TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(255) NOT NULL,
    course_id INT NOT NULL,
    staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

--------------------------------------------------------
-- 5. SESSION YEAR TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    session_start_year VARCHAR(10) NOT NULL,
    session_end_year VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------
-- 6. ATTENDANCE MASTER TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    session_id INT NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

--------------------------------------------------------
-- 7. ATTENDANCE REPORT TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS attendance_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    attendance_id INT NOT NULL,
    student_id INT NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    FOREIGN KEY (attendance_id) REFERENCES attendance(attendance_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

--------------------------------------------------------
-- 8. STUDENT RESULT TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    internal_marks INT DEFAULT 0,
    external_marks INT DEFAULT 0,
    total_marks INT GENERATED ALWAYS AS (internal_marks + external_marks) STORED,
    result_status ENUM('Pass', 'Fail') DEFAULT 'Pass',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

--------------------------------------------------------
-- 9. LEAVE PERMISSION TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS leave_requests (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT,
    student_id INT,
    reason TEXT NOT NULL,
    leave_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

--------------------------------------------------------
-- 10. REFERENCE BOOK TABLE
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS reference_books (
    ref_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    link VARCHAR(500),
    uploaded_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (uploaded_by) REFERENCES staff(staff_id)
);

--------------------------------------------------------
-- 11. ADMIN LOGIN TABLE (OPTIONAL)
--------------------------------------------------------
CREATE TABLE IF NOT EXISTS admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff
INSERT INTO staff (name, email, course, password, phone, role) VALUES
('Ramesh Kumar', 'ramesh@college.edu', 'CSE', 'ramesh123', '9876543210', 'Admin'),
('Divya Sharma', 'divya@college.edu', 'ECE', 'divya123', '9876543211', 'Staff'),
('Manoj Reddy', 'manoj@college.edu', 'ME', 'manoj123', '9876543212', 'Staff'),
('Priya Saini', 'priya@college.edu', 'CSE', 'priya123', '9876543213', 'Staff'),
('Ashok Patel', 'ashok@college.edu', 'EEE', 'ashok123', '9876543214', 'Staff');

-- Student
INSERT INTO students (name, email, roll_no, course, session_year, gender, dob, password) VALUES
('Arun B', 'arunb@students.edu', 'CSE001', 'CSE', '2023-2024', 'Male', '2004-05-21', 'arun123'),
('Megha R', 'meghar@students.edu', 'ECE012', 'ECE', '2023-2024', 'Female', '2004-11-09', 'megha123'),
('Kiran P', 'kiranp@students.edu', 'ME101', 'ME', '2022-2023', 'Male', '2003-07-02', 'kiran123'),
('Sneha M', 'sneham@students.edu', 'CSE045', 'CSE', '2023-2024', 'Female', '2004-03-14', 'sneha123'),
('Vikas S', 'vikass@students.edu', 'EEE020', 'EEE', '2022-2023', 'Male', '2003-12-30', 'vikas123');

-- Courses
INSERT INTO courses (course_name) VALUES
('Computer Science and Engineering'),
('Electronics and Communication Engineering'),
('Electrical and Electronics Engineering'),
('Mechanical Engineering'),
('Civil Engineering');

-- Subjects
INSERT INTO subjects (subject_name, course_id, staff_id) VALUES
('Data Structures', 1, 1),
('Digital Electronics', 2, 2),
('Thermodynamics', 4, 3),
('Operating Systems', 1, 4),
('Circuit Theory', 3, 5);

-- Sessions
INSERT INTO sessions (session_start_year, session_end_year) VALUES
('2023', '2024'),
('2022', '2023'),
('2021', '2022'),
('2020', '2021'),
('2019', '2020');

