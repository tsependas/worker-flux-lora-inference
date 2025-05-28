FROM python:3.12-slim

WORKDIR /app

# Install git (required for pip install from GitHub)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
COPY requirements.txt ./

RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

RUN pip install -r requirements.txt

# Clone ai-toolkit repo
RUN git clone https://github.com/ostris/ai-toolkit.git /app/ai-toolkit


# install torch first
RUN pip install --no-cache-dir torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu126


# Install ai-toolkit requirements
RUN pip install --no-cache-dir -r /app/ai-toolkit/requirements.txt

# download flux1-dev model at build
RUN python3 -c "from ai_toolkit.models import download_model; download_model('black-forest-labs/FLUX.1-dev', save_dir='/app/flux1-dev')"


COPY rp_handler.py ./

# Start the container
CMD ["python3", "-u", "rp_handler.py"]
