# =========================
# Stage 1: Build Stage
# =========================

FROM python:3.12 AS build

WORKDIR /app

# Create a virtual environment
RUN python -m venv /opt/venv

# Make the virtual environment the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# Copy only requirements first
COPY flask_app/requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Flask application
COPY flask_app/ /app/content/

# Copy ML model
COPY models/vectorizer.pkl /app/models/vectorizer.pkl

# Download required NLTK data
RUN python -m nltk.downloader -d /opt/nltk_data stopwords wordnet


# =========================
# Stage 2: Final Stage
# =========================

FROM python:3.12-slim AS final

WORKDIR /app

# Copy Python dependencies from build stage
COPY --from=build /opt/venv /opt/venv

# Copy NLTK data from build stage
COPY --from=build /opt/nltk_data /opt/nltk_data

# Copy Flask application
COPY --from=build /app/content /app/content

# Copy ML model
COPY --from=build /app/models /app/models

# Use the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Tell NLTK where its data is located
ENV NLTK_DATA="/opt/nltk_data"

# Application listens on port 5000
EXPOSE 5000

# Start Flask application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--timeout", "120", "content.app:app"]