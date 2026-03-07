# -------- Stage 1 : Builder --------
FROM python:3.10-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --user -r requirements.txt


# -------- Stage 2 : Final Image --------
FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /root/.local /root/.local

COPY . .

ENV PATH=/root/.local/bin:$PATH

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
