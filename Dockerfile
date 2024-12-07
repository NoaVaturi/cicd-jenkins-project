FROM python:3.12-alpine3.18

WORKDIR /application

# Copy only the requirements file first to leverage Docker cache for dependencies
COPY requirements.txt .


# Install dependencies (and clean up to reduce image size)
RUN python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip && \
    /venv/bin/pip install --no-cache-dir -r requirements.txt\
    rm -rf /root/.cache

# Now copy the entire application
COPY . /application 

# Set the virtual environment as the default for all commands in the container
ENV PATH="/venv/bin:$PATH"

EXPOSE 5000
CMD ["python", "app.py"]
