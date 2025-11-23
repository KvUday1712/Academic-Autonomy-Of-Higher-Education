from flask import Flask, render_template, request, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(_name_)

# ----------------------------------------------
# DATABASE CONFIG
# ----------------------------------------------
DB_CONFIG = {
    "host": "localhost",        # change if needed
    "user": "root",             # <-- put your MySQL username
    "password": "your_password",# <-- put your MySQL password
    "database": "academic_autonomy"
}

def get_db_connection():
    conn = mysql.connector.connect(**DB_CONFIG)
    return conn

# Optional: ensure table exists (safe to leave here)
def init_db():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS staff (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL UNIQUE,
                course VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL
            );
        """)
        conn.commit()
    except Error as e:
        print("Error while initializing DB:", e)
    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

init_db()

# ----------------------------------------------
# ROUTES
# ----------------------------------------------
@app.route('/')
def index():
    return render_template('add_staff.html')

@app.route('/add-staff', methods=['POST'])
def add_staff():
    staff_name = request.form.get('staffName')
    staff_email = request.form.get('staffEmail')
    staff_course = request.form.get('staffCourse')
    staff_password = request.form.get('staffPassword')

    conn = None
    cursor = None
    success = False
    message = "Something went wrong"

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        insert_query = """
            INSERT INTO staff (name, email, course, password)
            VALUES (%s, %s, %s, %s)
        """

        cursor.execute(insert_query, (staff_name, staff_email, staff_course, staff_password))
        conn.commit()
        success = True
        message = "Staff added successfully!"

    except Error as e:
        # Handle duplicate email or other DB errors
        print("MySQL Error:", e)
        if "Duplicate entry" in str(e):
            message = "Email already exists!"
        else:
            message = "Database error occurred."

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

    return jsonify({"success": success, "message": message})

@app.route('/staff-list')
def staff_list():
    conn = None
    cursor = None
    staff_data = []

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)  # rows as dicts

        cursor.execute("SELECT id, name, email, course FROM staff")
        rows = cursor.fetchall()

        staff_data = rows  # already list of dicts because of dictionary=True

    except Error as e:
        print("MySQL Error:", e)

    finally:
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()

    return jsonify(staff_data)

# ----------------------------------------------
# RUN
# ----------------------------------------------
if _name_ == '_main_':
    app.run(debug=True)
