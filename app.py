import os
import subprocess
import threading
import gradio as gr

def start_bot_process():
    """تشغيل ملف التشكيل والبوت الأساسي في الخلفية"""
    try:
        # التأكد من صلاحية التنفيذ لملف start.sh
        subprocess.run(["chmod", "+x", "start.sh"], check=False)
        # تشغيل السكريبت بشكل مستمر في الخلفية
        subprocess.Popen(["bash", "start.sh"])
    except Exception as e:
        print(f"Error starting background process: {e}")

# تشغيل البوت في خيط (Thread) منفصل فور تشغيل الخادم لضمان عدم تعطل الويب
threading.Thread(target=start_bot_process, daemon=True).start()

# التقاط رقم المنفذ (Port) تلقائياً من أي بيئة (Railway, Render, Hugging Face)
PORT = int(os.environ.get("PORT", 7860))

# بناء واجهة ويب بسيطة ومتوافقة مع متطلبات الاستضافات لمنع وضع النوم
with gr.Blocks(title="Sarmadi Userbot Dashboard") as demo:
    gr.Markdown("# 🚀 Sarmadi Userbot is Running 24/7!")
    gr.Markdown("### الحالة: النظام يعمل بنجاح وقاعدة البيانات المحلية وملفات الجلسة آمنة.")
    gr.Info("هذه الواجهة مخصصة لإبقاء الخادم نشطاً ومستيقظاً طوال الوقت.")

if __name__ == "__main__":
    # تشغيل السيرفر على العنوان والمنفذ المناسب لأي منصة
    demo.launch(server_name="0.0.0.0", server_port=PORT, share=False)
