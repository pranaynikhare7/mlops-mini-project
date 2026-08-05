from flask import Flask, render_template, request
import mlflow
import dagshub
from preprocessing_utility import normalize_text
import pickle

mlflow.set_tracking_uri('https://dagshub.com/pranaynikhare7/mlops-mini-project.mlflow')
dagshub.init(repo_owner='pranaynikhare7', repo_name='mlops-mini-project', mlflow=True)

app = Flask(__name__)

# load model from model registry
model_name = 'logreg-hp-model'
model_version = 2

model_uri = f"models:/{model_name}/{model_version}"
model = mlflow.pyfunc.load_model(model_uri)

@app.route('/')
def home():
    return render_template('index.html', result=None)

@app.route('/predict', methods=['POST'])
def predict():
    text = request.form['text']

    # Clean
    text = normalize_text(text)

    # Apply BoW
    vectorizer = pickle.load(open('models/vectorizer.pkl', 'rb'))
    text_vectorized = vectorizer.transform([text])

    # Prediction
    prediction = model.predict(text_vectorized)

    return render_template('index.html', text=text, result=prediction[0])
    # return str(prediction[0])

app.run(debug=True) 