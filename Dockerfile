FROM python:3.10-slim

# تعيين مجلد العمل الأساسي داخل الحاوية
WORKDIR /app

# تحديث النظام وتثبيت الحزم الأساسية المطلوبة (مثل ffmpeg الموجودة في ملف apt.txt و git)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# نسخ ملف المتطلبات أولاً لضمان سرعة بناء الكاش (Cache)
COPY requirements.txt .

# ترقية pip وتثبيت جميع مكتبات البايثون المطلوبة
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# نسخ باقي ملفات السورس والكود إلى داخل الحاوية
COPY . .

# إعطاء صلاحية التنفيذ لملف البداية
RUN chmod +x start.sh

# أمر تشغيل البوت التلقائي
CMD ["bash", "start.sh"]
