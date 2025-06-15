from flask import Flask, render_template, request, redirect, url_for, jsonify

app = Flask(__name__)

# Dummy database (in-memory list)
staff_members = []

@app.route('/')
def index():
    return render_template('add_staff.html')

@app.route('/add-staff', methods=['POST'])
def add_staff():
    staff_name = request.form.get('staffName')
    staff_email = request.form.get('staffEmail')
    staff_course = request.form.get('staffCourse')
    staff_password = request.form.get('staffPassword')

    # Add the new staff member to the list (simulating a database)
    staff_members.append({
        'name': staff_name,
        'email': staff_email,
        'course': staff_course,
        'password': staff_password
    })

    # Redirect back to the form or send a success response
    return jsonify({'success': True, 'message': 'Staff added successfully!'})

if __name__ == '__main__':
    app.run(debug=True)
