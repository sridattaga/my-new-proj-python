# -------- Stage 1 : Builder --------
FROM python:3.10-slim AS builder

WORKDIR /build

COPY dist/*.whl .

RUN pip install --prefix=/install *.whl


# -------- Stage 2 : Runtime --------
FROM python:3.10-slim

WORKDIR /app

COPY --from=builder /install /usr/local

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
