FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
COPY locustfile.py .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8089
CMD [ "locust", "-f", "locustfile.py"]