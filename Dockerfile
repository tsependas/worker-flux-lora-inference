# Stage 1: Builder
FROM nvidia/cuda:12.6.2-cudnn-runtime-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install Python 3.12 + compiler + runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    git build-essential libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Create and activate venv
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Install packages
COPY requirements.txt ./
RUN pip install --upgrade pip setuptools wheel && \
    pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu126 && \
    pip install --no-cache-dir -r requirements.txt

# Install ai-toolkit
RUN git clone https://github.com/ostris/ai-toolkit.git /app/ai-toolkit

# Copy app
COPY . /app

# Stage 2: Runtime
FROM nvidia/cuda:12.6.2-cudnn-runtime-ubuntu24.04

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip python3-dev \
    libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /venv /venv
COPY --from=builder /app /app

ENV PATH="/venv/bin:$PATH"

CMD ["python3", "-u", "rp_handler.py"]
