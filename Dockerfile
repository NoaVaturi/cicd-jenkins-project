FROM python:3.12-alpine3.18

WORKDIR /application

# Copy only the requirements file first to leverage Docker cache for dependencies
COPY requirements.txt .


# Install dependencies (and clean up to reduce image size)
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache

# Now copy the entire application
COPY . /application 

EXPOSE 5000
CMD ["python", "app.py"]
