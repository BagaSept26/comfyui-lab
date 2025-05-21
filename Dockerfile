# --- Frontend Builder Stage ---
FROM node:18-slim AS frontend-builder
WORKDIR /app_frontend
COPY frontend/package.json frontend/package-lock.json* frontend/yarn.lock* ./
RUN if [ -f "package-lock.json" ]; then npm ci; \
    elif [ -f "yarn.lock" ]; then yarn install --frozen-lockfile; \
    else npm install; fi # Sesuaikan jika frontend Anda menggunakan yarn
COPY frontend/ ./
RUN npm run build # Pastikan ini adalah perintah build yang benar untuk frontend Anda

# --- Backend Stage ---
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*
COPY . .
RUN git submodule update --init --recursive # Mengambil kode dari submodule fork Anda
RUN pip install --no-cache-dir -r backend/requirements.txt
RUN mkdir -p backend/web # Pastikan direktori web ada
RUN rm -rf backend/web/*
COPY --from=frontend-builder /app_frontend/dist/ backend/web/ 
# Pastikan /dist/ adalah output build frontend
EXPOSE 7860
CMD ["python", "backend/main.py", "--listen", "0.0.0.0", "--port", "7860", "--preview-method", "none"]