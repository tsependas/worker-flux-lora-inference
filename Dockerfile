# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc libgl1 libglib2.0-0 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

RUN git clone https://github.com/ostris/ai-toolkit.git /app/ai-toolkit && \
    pip install --no-cache-dir -r /app/ai-toolkit/requirements.txt && \
    pip install --no-cache-dir torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu126

COPY rp_handler.py /app/

# Stage 2: Minimal runtime
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /venv /venv

ENV PATH="/venv/bin:$PATH"

CMD ["python3", "-u", "rp_handler.py"]
