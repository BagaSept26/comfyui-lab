# --- Frontend Builder Stage ---
FROM node:18-slim AS frontend-builder
WORKDIR /app_frontend
#install git
RUN apt-get update && apt-get install -y git
#cloning github
RUN git clone --depth 1 https://github.com/BagaSept26/ComfyUI_frontend .
RUN if [ -f "package-lock.json" ]; then npm ci; \
    elif [ -f "yarn.lock" ]; then yarn install --frozen-lockfile; \
    else npm install; fi
#BUILD FRONTEND
RUN npm run build

# --- Backend Stage ---
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

#clonong github backend
RUN git clone --depth 1 https://github.com/BagaSept26/ComfyUI backend
RUN pip install --no-cache-dir -r backend/requirements.txt

RUN mkdir -p backend/web
RUN rm -rf backend/web/*
COPY --from=frontend-builder /app_frontend/dist/ backend/web/ 
# Pastikan /dist/ adalah output build frontend
EXPOSE 7860
CMD ["python", "backend/main.py", "--listen", "0.0.0.0", "--port", "7860", "--preview-method", "none"]