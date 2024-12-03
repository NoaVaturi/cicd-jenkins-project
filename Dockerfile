FROM python:3.12-alpine3.18

# Set working directory
WORKDIR /application

# Copy the application files
COPY . /application

# Install dependencies (including pytest)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache

# Expose port for the application
EXPOSE 5000

# Start the Flask application
CMD ["python", "app.py"]
