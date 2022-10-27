from flask import Flask, render_template, request, redirect, url_for
import cv2
import uuid
app = Flask(__name__)
import os, sys
IMAGE_DIR=''
BASE = os.path.dirname(os.path.abspath(__file__))
@app.route('/')
def home():
    return render_template('home.html')

@app.route('/upload', methods = ['POST', 'GET'])
def upload():
    global IMAGE_DIR
    if request.method == 'POST':
        if 'image' not in request.files:
            return "NO IMAGE FOUND"
        else:
            image = request.files['image']
            img_dir = os.path.join(BASE, 'static', str(uuid.uuid1()) + '.png')
            image.save(img_dir)
            tokens = os.path.normpath(img_dir).split(os.path.sep)[-2:]
            IMAGE_DIR = '/'.join(tokens)
            print(IMAGE_DIR)
            return render_template('index.html', image = IMAGE_DIR)# redirect(url_for('show', img_dir = img_dir))
    else:
        print(IMAGE_DIR)
        return render_template('index.html', image = IMAGE_DIR)
    
@app.route('/show', methods = ['POST', 'GET'])
def show():
    print(request.method)
    
    if request.method == 'POST':
        img_dir = request.args.get('img_dir') # request.files['img_dir']

        image = cv2.imread(img_dir)
        return render_template('index.html', image = img_dir)
    else:
        return render_template('home.html')

if __name__ == "__main__":
    app.run(debug = False)