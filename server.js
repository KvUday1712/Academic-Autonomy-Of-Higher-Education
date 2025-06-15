const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(cors()); // Allow requests from the frontend
app.use(bodyParser.json()); // Parse JSON request bodies

// MySQL Connection
const db = mysql.createConnection({
  host: 'localhost', // Your MySQL host
  user: 'root',      // Your MySQL username
  password: 'Rakesh@2004', // Your MySQL password
  database: 'All_db', // Your database name
});

// Connect to the Database
db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err);
    process.exit(1); // Exit if the connection fails
  }
  console.log('Connected to the MySQL database.');
});

// Helper function for error handling
const handleDbError = (res, err, message) => {
  console.error(message, err);
  res.status(500).json({ success: false, message });
};

// API Endpoint to Add Staff
app.post('/add-staff', (req, res) => {
  const { name, email, course, password, qualification, specialization, designation, date_of_joining, professor_designation_date, currently_associated, unique_id } = req.body;

  const sql = `
    INSERT INTO staff (
      name, email, course, password, qualification, specialization, designation,
      date_of_joining, professor_designation_date, currently_associated, unique_id
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(sql, [name, email, course, password, qualification, specialization, designation, date_of_joining, professor_designation_date, currently_associated, unique_id], (err, result) => {
    if (err) {
      return handleDbError(res, err, 'Error inserting staff data.');
    }
    res.status(200).json({ success: true, message: 'Staff added successfully' });
  });
});

// API Endpoint to Get Staff
app.get('/get-staff', (req, res) => {
  db.query('SELECT * FROM staff', (err, results) => {
    if (err) {
      return handleDbError(res, err, 'Error fetching staff data.');
    }
    res.status(200).json(results);
  });
});

// API Endpoint to Delete Staff
app.post('/delete-staff', (req, res) => {
  const { unique_id } = req.body;

  if (!unique_id) {
    return res.status(400).json({ success: false, message: 'Unique ID is required' });
  }

  db.query('DELETE FROM staff WHERE unique_id = ?', [unique_id], (err, result) => {
    if (err) {
      return handleDbError(res, err, 'Database error while deleting staff.');
    }
    if (result.affectedRows > 0) {
      res.json({ success: true, message: 'Staff member deleted successfully.' });
    } else {
      res.json({ success: false, message: 'No staff member found with the provided Unique ID.' });
    }
  });
});

// API Endpoint to Add Student
app.post('/add-student', (req, res) => {
  const { usn, name, email, course, password } = req.body;

  const query = 'INSERT INTO students (usn, name, email, course, password) VALUES (?, ?, ?, ?, ?)';
  db.query(query, [usn, name, email, course, password], (err, result) => {
    if (err) {
      return handleDbError(res, err, 'Failed to add student.');
    }
    res.status(200).json({ message: 'Student added successfully' });
  });
});

// API Endpoint to Get All Students
app.get('/get-students', (req, res) => {
  db.query('SELECT usn, name, email, course FROM students', (err, results) => {
    if (err) {
      return handleDbError(res, err, 'Failed to load student data.');
    }
    res.status(200).json(results);
  });
});

// API Endpoint to Delete Student
app.post('/delete-student', (req, res) => {
  const { usn } = req.body;

  if (!usn) {
    return res.status(400).json({ success: false, message: 'USN is required' });
  }

  db.query('DELETE FROM students WHERE usn = ?', [usn], (err, result) => {
    if (err) {
      return handleDbError(res, err, 'Database error while deleting student.');
    }
    if (result.affectedRows > 0) {
      res.json({ success: true, message: 'Student deleted successfully.' });
    } else {
      res.json({ success: false, message: 'No student found with the provided USN.' });
    }
  });
});

// Backend (Node.js + Express) login example
app.post('/login', (req, res) => {
  const { username, password, userType } = req.body;
  let query;

  if (userType === 'admin') {
    if (username === 'admin' && password === 'admin123') {
      return res.json({ success: true, message: 'Admin login successful' });
    } else {
      return res.json({ success: false, message: 'Invalid admin login details.' });
    }
  }

  if (userType === 'staff') {
    query = 'SELECT * FROM staff WHERE email = ? AND password = ?';
  } else if (userType === 'student') {
    query = 'SELECT * FROM students WHERE email = ? AND password = ?';
  }

  db.query(query, [username, password], (err, results) => {
    if (err) {
      return handleDbError(res, err, 'Database error during login.');
    }
    if (results.length > 0) {
      return res.json({ success: true, message: 'Login successful' });
    }
    return res.json({ success: false, message: 'Invalid login details. Please try again.' });
  });
});

// API Endpoint to Add Result
app.post('/add-result', (req, res) => {
  const { student_usn, subject, ia1, ia2, ia3, course } = req.body;

  if (!student_usn || !subject || ia1 == null || ia2 == null || ia3 == null || !course) {
    return res.status(400).send('All fields are required.');
  }

  const fetchStudentQuery = 'SELECT email, password FROM students WHERE usn = ?';
  db.query(fetchStudentQuery, [student_usn], (err, results) => {
    if (err) {
      return handleDbError(res, err, 'Error fetching student details.');
    }
    if (results.length === 0) {
      return res.status(404).send('Student not found.');
    }

    const { email, password } = results[0];
    const insertResultQuery = 'INSERT INTO student_marks (student_usn, subject, ia1, ia2, ia3, course, email, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';

    db.query(insertResultQuery, [student_usn, subject, ia1, ia2, ia3, course, email, password], (err) => {
      if (err) {
        return handleDbError(res, err, 'Failed to add result.');
      }
      res.send('Result added successfully!');
    });
  });
});

// API Endpoint to Get Student Marks
app.get('/get-student-marks', (req, res) => {
  db.query('SELECT * FROM student_marks', (err, results) => {
    if (err) {
      return handleDbError(res, err, 'Error fetching student marks.');
    }
    res.json(results);
  });
});


// Start the Server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
