from flask import Flask, request, jsonify, render_template_string
import json
import os

app = Flask(__name__)

DATA_FILE = "names.json"

# Create JSON file if not exists
if not os.path.exists(DATA_FILE):
    with open(DATA_FILE, 'w') as f:
        json.dump([], f)

# HTML Templates
home_page = """
<!DOCTYPE html>
<html>
<head>
  <title>Name of Hope</title>
  <style>
    body {
      margin: 0;
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #a1c4fd, #c2e9fb);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      overflow: hidden;
      text-align: center;
    }
    h1 {
      color: #ffffff;
      font-size: 2em;
      margin-bottom: 10px;
      text-shadow: 1px 1px 3px #000;
    }
    input {
      padding: 10px;
      font-size: 1em;
      border: none;
      border-radius: 8px;
      width: 70%;
      max-width: 300px;
    }
    button {
      margin-top: 15px;
      padding: 10px 20px;
      font-size: 1em;
      border: none;
      border-radius: 20px;
      background: #5cdb95;
      color: white;
      cursor: pointer;
      transition: 0.3s;
    }
    button:hover {
      background: #379683;
    }
  </style>
</head>
<body>
  <h1>🌱 Add Your Name to the Tree of Hope</h1>
  <input type="text" id="nameInput" placeholder="Enter your name" />
  <button onclick="shareAndSave()">Share & Add Name</button>

  <script>
    function shareAndSave() {
      const name = document.getElementById('nameInput').value.trim();
      if (!name) {
        alert("Please enter your name.");
        return;
      }

      if (navigator.share) {
        navigator.share({
          title: "Name of Hope",
          text: "I just added my name to the Tree of Hope! 🌱",
          url: window.location.href
        }).then(() => {
          sendName(name);
        }).catch(() => {
          sendName(name);
        });
      } else {
        sendName(name);
      }
    }

    function sendName(name) {
      fetch("/api/add_name", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ name: name })
      })
      .then(res => res.json())
      .then(data => {
        if (data.status === "success") {
          window.location.href = "/names";
        } else {
          alert("Something went wrong!");
        }
      });
    }
  </script>
</body>
</html>
"""

names_page = """
<!DOCTYPE html>
<html>
<head>
  <title>Tree of Hope – Names</title>
  <style>
    body {
      margin: 0;
      font-family: 'Segoe UI', sans-serif;
      background: #e6f7ff;
      padding: 20px;
      text-align: center;
    }
    h1 {
      color: #00796b;
      margin-bottom: 20px;
    }
    .names-container {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 10px;
    }
    .name-box {
      background: #ffffff;
      padding: 10px 20px;
      border-radius: 12px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      font-weight: bold;
      color: #333;
    }
    .back-btn {
      display: inline-block;
      margin-top: 20px;
      padding: 10px 20px;
      background: #ffb347;
      color: #fff;
      border: none;
      border-radius: 20px;
      cursor: pointer;
      text-decoration: none;
    }
    .back-btn:hover {
      background: #ff9800;
    }
  </style>
</head>
<body>
  <h1>🌳 Tree of Hope</h1>
  <div class="names-container" id="namesContainer"></div>
  <a href="/" class="back-btn">Add Another Name</a>

  <script>
    fetch("/api/get_names")
      .then(res => res.json())
      .then(names => {
        const container = document.getElementById('namesContainer');
        names.forEach(name => {
          const div = document.createElement('div');
          div.className = 'name-box';
          div.textContent = name;
          container.appendChild(div);
        });
      });
  </script>
</body>
</html>
"""

# Routes
@app.route("/")
def home():
    return render_template_string(home_page)

@app.route("/names")
def names():
    return render_template_string(names_page)

@app.route("/api/add_name", methods=["POST"])
def add_name():
    data = request.json
    name = data.get("name", "").strip()

    if not name:
        return jsonify({"status": "error", "message": "Name required"}), 400

    with open(DATA_FILE, 'r') as f:
        names = json.load(f)

    names.append(name)

    with open(DATA_FILE, 'w') as f:
        json.dump(names, f)

    return jsonify({"status": "success"})

@app.route("/api/get_names", methods=["GET"])
def get_names():
    with open(DATA_FILE, 'r') as f:
        names = json.load(f)
    return jsonify(names)

if __name__ == "__main__":
    app.run(debug=True)
