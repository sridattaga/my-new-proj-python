# -------- Stage 1 : Builder --------
FROM python:3.10-slim AS builder

WORKDIR /build

COPY dist/*.whl .

RUN pip install --prefix=/install *.whl


# -------- Stage 2 : Runtime --------
FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /install /usr/local

RUN pip install --no-cache-dir prometheus_client

# Copy application files
COPY app.py .
COPY templates ./templates

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
