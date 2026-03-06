FROM python:3.13-slim AS build

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

copy . .

FROM python:3.13-slim

WORKDIR /app

COPY --from=build /install /usr/local

COPY --from=build /app /app

USER 65532:65532

EXPOSE 8080

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]

