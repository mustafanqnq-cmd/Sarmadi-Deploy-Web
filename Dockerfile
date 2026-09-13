FROM python:3.12
WORKDIR /app
COPY . /app
RUN apt-get -qq update && apt-get -qq install -y git wget ffmpeg mediainfo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs
RUN pip install --no-cache-dir -r requirements.txt

# تحديد البورت الافتراضي لـ Hugging Face (رايلوي سيتجاهله ويضع البورت الخاص به)
ENV PORT=7860
EXPOSE 7860

ENV PATH=/app:$PATH

# تشغيل خادم الويب والسورس معاً
CMD ["bash", "start.sh"]
