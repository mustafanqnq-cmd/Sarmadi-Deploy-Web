FROM python:3.11.18-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    TZ=Asia/Baghdad

ARG UPSTREAM_REPO=https://github.com/mustafanqnq-cmd/Tython.git
ARG UPSTREAM_BRANCH=main

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    wget \
    unzip \
    zip \
    ffmpeg \
    libpq-dev \
    gcc \
    g++ \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" /opt/Tython

COPY requirements.txt ./requirements.txt

RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir -r /opt/Tython/requirements.txt

COPY . .

RUN python -c "import sys; print(sys.version); assert sys.version_info[:3] == (3, 11, 18)" \
    && chmod +x start.sh ba.sh

CMD ["bash", "start.sh"]
