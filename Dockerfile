FROM python:3.12-slim

WORKDIR /app

COPY flask_app/ /app/content

COPY models/vectorizer.pkl /app/models/vectorizer.pkl

RUN pip install -r content/requirements.txt

RUN python -m nltk.downloader stopwords wordnet

EXPOSE 5000 

# CMD ["python", "content/app.py"]
CMD ["gunicorn", "-b", "0.0.0.0:5000", "content.app:app"]

