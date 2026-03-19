# Use 3.12: numpy<2 (required by langchain-experimental) has no 3.13 wheel, so 3.13 would need build deps.
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e .

# Olares entrance: minimal HTTP server on 8080
ENV PORT=8080
EXPOSE 8080
CMD ["python", "serve.py"]
