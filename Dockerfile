FROM python:3.10-slim

# تعيين مجلد العمل الأساسي داخل الحاوية
WORKDIR /app

# تحديث النظام وتثبيت حزم النظام الأساسية (مثل ffmpeg ومكتبات التطوير ودعم القواعد)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ffmpeg \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# نسخ ملف المتطلبات أولاً لضمان سرعة الكاش
COPY requirements.txt .

# ترقية pip وتثبيت جميع مكتبات بايثون بدون مشاكل
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# نسخ باقي ملفات السورس والكود إلى داخل الحاوية
COPY . .

# إعطاء صلاحية التنفيذ لملف البداية
RUN chmod +x start.sh

# أمر تشغيل البوت التلقائي
CMD ["bash", "start.sh"]
