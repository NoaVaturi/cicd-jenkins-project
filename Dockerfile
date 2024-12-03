FROM python:3.12-alpine3.18
COPY . /application
WORKDIR /application
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt  && \
rm -rf /root/.cache
EXPOSE 5000
CMD ["python", "app.py"]