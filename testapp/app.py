from flask import Flask, render_template, request, redirect, url_for
import cv2
import uuid
app = Flask(__name__)
import os, sys

BASE = os.path.dirname(os.path.abspath(__file__))
@app.route('/')
def home():
    return render_template('home.html')

@app.route('/upload', methods = ['POST'])
def upload():
    if request.method == 'POST':
        if 'image' not in request.files:
            return "NO IMAGE FOUND"
        
    image = request.files['image']
    img_dir = os.path.join(BASE, 'static', str(uuid.uuid1()) + '.png')
    image.save(img_dir)
    
    return redirect(url_for('show', img_dir = img_dir))
    
@app.route('/show', methods = ['POST', 'GET'])
def show():
    print(request.method)
    if request.method == 'POST':
        img_dir = request.files['img_dir']
        image = cv2.imread(img_dir)
        return render_template('index.html', image = image)
    else:
        return render_template('home.html')

if __name__ == "__main__":
    app.run(debug = False)