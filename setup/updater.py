import sys
import os
import asyncio
from git import Repo
from git.exc import InvalidGitRepositoryError, GitCommandError

UPSTREAM_REPO = "https://github.com/Sarmadi-Deploy-Web/Sarmadi-Deploy-Web"
REQUIREMENTS_FILE = "requirements.txt"

async def run_cmd(command: str) -> tuple[int, str, str]:
    """
    تنفيذ الأوامر الطرفية بشكل غير متزامن لتفادي تجميد البوت.
    """
    process = await asyncio.create_subprocess_shell(
        command,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await process.communicate()
    return process.returncode, stdout.decode().strip(), stderr.decode().strip()

async def upgrade_pip_requirements() -> tuple[bool, str]:
    """
    فحص وتحديث مكاتب Python المعرفة في requirements.txt.
    المكتبات المثبتة والمحدثة مسبقاً يتم تجاوزها فوراً بدون إعادة تنزيل.
    """
    if not os.path.exists(REQUIREMENTS_FILE):
        return False, "ملف requirements.txt غير موجود في المسار الرئيسي."

    pip_executable = sys.executable
    cmd = f'"{pip_executable}" -m pip install --upgrade -r {REQUIREMENTS_FILE}'
    code, stdout, stderr = await run_cmd(cmd)
    
    if code == 0:
        return True, "تم فحص وتحديث جميع المكتبات بنجاح."
    else:
        return False, f"حدث خطأ أثناء فحص المكتبات:\n{stderr}"

async def pull_git_updates() -> tuple[bool, str]:
    """
    سحب أحدث الملفات والمجلدات وتحديث الشفرة المصدرية من Git.
    """
    try:
        repo = Repo(os.getcwd())
    except InvalidGitRepositoryError:
        repo = Repo.init(os.getcwd())

    try:
        if "origin" in repo.remotes:
            origin = repo.remote("origin")
        else:
            origin = repo.create_remote("origin", UPSTREAM_REPO)
            
        origin.fetch()
        active_branch = repo.active_branch.name if not repo.head.is_detached else "main"
        
        repo.git.reset("--hard", f"origin/{active_branch}")
        repo.git.pull("origin", active_branch)
        return True, f"تم سحب وتحديث جميع مجلدات السورس بنجاح من الفرع {active_branch}."
    except GitCommandError as e:
        return False, f"خطأ في تنفيذ أمر Git:\n{str(e)}"
    except Exception as e:
        return False, f"خطأ غير متوقع أثناء سحب التحديثات:\n{str(e)}"

async def update_bot_full(event=None):
    """
    الدالة المخصصة لأمر (تحديث البوت) أو زر التحديث الشامل:
    - تحدث السورس والمجلدات.
    - تفحص وتحدث المكتبات الجديدة/الناقصة فقط وتترك المحدث على وضعه.
    - تعيد تشغيل البوت تلقائياً.
    (ملاحظة: أمر .تحديث الخاص بالبلوغينات يظل يعمل بشكل منفصل كما هو).
    """
    status_message = None
    if event:
        status_message = await event.respond("⏳ جاري بدء التحديث الشامل للبوت (السورس + المكتبات)...")

    # 1. تحديث السورس والمجلدات
    git_success, git_log = await pull_git_updates()
    if not git_success:
        if status_message:
            await status_message.edit(f"❌ فشل تحديث السورس:\n{git_log}")
        return

    if status_message:
        await status_message.edit("🔄 تم تحديث المجلدات والسورس. جاري فحص مكتبات بايثون...")

    # 2. فحص وتحديث المكتبات (تجاوز المثبت وتحديث الجديد فقط)
    pip_success, pip_log = await upgrade_pip_requirements()
    if not pip_success:
        if status_message:
            await status_message.edit(f"⚠️ تم تحديث السورس ولكن حدث خطأ في المكتبات:\n{pip_log}")
        return

    if status_message:
        await status_message.edit("✅ اكتمل التحديث الشامل بنجاح! جاري إعادة تشغيل البوت لتطبيق التغيرات...")

    # 3. إعادة التشغيل المباشر للبوت
    os.execl(sys.executable, sys.executable, "-m", "app")
