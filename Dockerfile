# Stage 1: Build Stage (optional for size optimization)
FROM python:3.12.0b3-alpine3.18 as build

# Set the working directory for the build stage
WORKDIR /application

# Copy the requirements.txt first to leverage caching
COPY requirements.txt .

# Install dependencies in the build stage
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime Stage
FROM python:3.12.0b3-alpine3.18

# Set the working directory for the runtime stage
WORKDIR /application

# Copy only the necessary files from the build stage
COPY --from=build /application /application

# Expose the port your app will run on
EXPOSE 5000

# Set the command to run the Flask app
CMD ["python", "app.py"]
