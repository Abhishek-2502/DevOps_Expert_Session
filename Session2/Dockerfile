# Use slim Python base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for caching)
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./

# Expose port
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]



# docker build -t flask-lab .
# docker run -d --name flask-lab -p 5000:5000 flask-lab

# docker stop flask-lab
# docker rm flask-lab

# docker tag flask-lab:latest abhi25022004/flask-lab:latest
# docker push abhi25022004/flask-lab:latest