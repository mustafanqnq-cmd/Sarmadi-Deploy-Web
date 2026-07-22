import os
import sys
import shutil
import zipfile
import tempfile

async def update_(event):
    msg = await event.edit("⌭ جـارِ فحـص التحديـثات.. انتظر قليلاً ⌭")

    github_token = os.environ.get("GITHUB_TOKEN")

    # =========================================================
    # الحالة الأولى: إذا كان GITHUB_TOKEN موجوداً ومجلد .git مهيأ
    # =========================================================
    if github_token and os.path.exists(".git"):
        git_cmd = f'git -c http.extraheader="AUTHORIZATION: bearer {github_token}" pull'
        stdout, stderr, returncode, pid = await runcmd(git_cmd)

        if returncode == 0:
            if "Already up to date." in stdout:
                await msg.edit("⌭ لا توجد تحديثات جديدة، البوت محدث بالفعل ⌭")
                return
            else:
                await msg.edit("⌭ تـم التحديـث بنجـاح عبر Git! جـاري إعـادة التشغيـل ⌭")
                os.execl(sys.executable, sys.executable, *sys.argv)
                return

    # =========================================================
    # الحالة الثانية: بدون توكن أو بدون .git (الاعتماد على Cloudflare Worker)
    # =========================================================
    try:
        worker_url = "https://falling-leafgithub-proxy.mustafanqnq.workers.dev/"
        auth_secret = os.environ.get("LAUNCHER_SECRET", "SUPHE999")
        zip_path = "update_temp.zip"

        await msg.edit("⌭ جاري تنزيل التحديث من السيرفر الآمن (Cloudflare).. ⌭")

        # تنزيل ملف التحديث كـ Zip
        download_cmd = f'curl -sSL -H "X-Launcher-Auth: {auth_secret}" "{worker_url}" -o "{zip_path}"'
        stdout, stderr, returncode, pid = await runcmd(download_cmd)

        if returncode != 0 or not os.path.exists(zip_path):
            await msg.edit("⌭ فشل تحميل ملف التحديث من السيرفر ⌭")
            return

        # التحقق من صحة الملف
        with open(zip_path, "rb") as f:
            header = f.read(2)
        if header != b"PK":
            await msg.edit("⌭ فشل التحديث: الاستجابة القادمة من السيرفر غير صالحة ⌭")
            if os.path.exists(zip_path):
                os.remove(zip_path)
            return

        await msg.edit("⌭ جاري استخراج وتطبيق التحديثات.. ⌭")

        # استبدال الملفات القديمة
        temp_dir = tempfile.mkdtemp()
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)

        extracted_items = os.listdir(temp_dir)
        if extracted_items:
            root_folder = os.path.join(temp_dir, extracted_items[0])
            if os.path.isdir(root_folder):
                for item in os.listdir(root_folder):
                    if item == ".git":
                        continue
                    s = os.path.join(root_folder, item)
                    d = os.path.join(os.getcwd(), item)
                    if os.path.isdir(s):
                        if os.path.exists(d):
                            shutil.rmtree(d)
                        shutil.copytree(s, d)
                    else:
                        shutil.copy2(s, d)

        # تنظيف الملفات المؤقتة
        if os.path.exists(zip_path):
            os.remove(zip_path)
        shutil.rmtree(temp_dir, ignore_errors=True)

        await msg.edit("⌭ تـم التحديـث بنجـاح! جـاري إعـادة التشغيـل ⌭")
        os.execl(sys.executable, sys.executable, *sys.argv)

    except Exception as e:
        await msg.edit(f"⌭ حدث خطأ أثناء تطبيق التحديث: {str(e)} ⌭")
