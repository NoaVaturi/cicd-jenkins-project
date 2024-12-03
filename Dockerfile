FROM python:3.12-alpine3.18

# Copy the entire application and requirements.txt
COPY . /application

# Set the working directory
WORKDIR /application

# Upgrade pip and install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache

# Expose the port that the Flask app will run on
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "app.py"]
