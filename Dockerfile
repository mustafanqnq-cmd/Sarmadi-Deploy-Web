FROM python:3.10-slim

WORKDIR /app

# تثبيت حزم النظام الأساسية بما فيها ImageMagick المطلوب لمكتبة wand وأدوات الضغط
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    zip \
    ffmpeg \
    libpq-dev \
    gcc \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x start.sh

CMD ["bash", "start.sh"]
