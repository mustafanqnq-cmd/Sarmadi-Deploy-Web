import sys
import os
import asyncio
from git import Repo
from git.exc import InvalidGitRepositoryError, GitCommandError

UPSTREAM_REPO = "https://github.com/Sarmadi-Deploy-Web/Sarmadi-Deploy-Web"
REQUIREMENTS_FILE = "requirements.txt"
# إذا كان لديك ملف متطلبات خاص باللانجر في مسار آخر، يمكنك تعريفه هنا لتحديثه أيضاً:
# LAUNCHER_REQ_FILE = "launcher/requirements.txt"

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
    1. أولاً: فحص وتحديث مكاتب Python (للسورس وأي إضافات مرتبطة).
    المكتبات المثبتة مسبقاً وعلى أحدث إصدار يتم تجاوزها فوراً.
    """
    pip_executable = sys.executable
    logs = []

    # فحص ملف متطلبات السورس الرئيسي
    if os.path.exists(REQUIREMENTS_FILE):
        cmd = f'"{pip_executable}" -m pip install --upgrade -r {REQUIREMENTS_FILE}'
        code, stdout, stderr = await run_cmd(cmd)
        if code != 0:
            return False, f"خطأ في مكاتب السورس:\n{stderr}"
        logs.append("تم فحص وتحديث مكاتب السورس بنجاح.")
    
    # (اختياري) إذا كان لديك ملف متطلبات خاص باللانجر والإضافات الخارجية:
    # launcher_req = "launcher/requirements.txt"
    # if os.path.exists(launcher_req):
    #     cmd_l = f'"{pip_executable}" -m pip install --upgrade -r {launcher_req}'
    #     code_l, out_l, err_l = await run_cmd(cmd_l)
    #     if code_l != 0:
    #         return False, f"خطأ في مكاتب اللانجر والإضافات:\n{err_l}"
    #     logs.append("تم فحص وتحديث مكاتب اللانجر بنجاح.")

    return True, "\n".join(logs) if logs else "لا توجد ملفات متطلبات لتحديثها."

async def pull_git_updates() -> tuple[bool, str]:
    """
    2. ثانياً: سحب وتحديث ملفات السورس والإضافات والمجلدات من Git.
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
        return True, f"تم سحب وتحديث السورس والإضافات بنجاح من الفرع {active_branch}."
    except GitCommandError as e:
        return False, f"خطأ في تنفيذ أمر Git:\n{str(e)}"
    except Exception as e:
        return False, f"خطأ غير متوقع أثناء سحب التحديثات:\n{str(e)}"

async def update_bot_full(event=None):
    """
    أمر (تحديث البوت) الشامل:
    - يبدأ أولاً بفحص وتحديث المكاتب (للسورس والإضافات).
    - ثانياً يقوم بسحب وتحديث ملفات السورس والمجلدات والإضافات.
    - أخيراً يعيد تشغيل البوت تلقائياً.
    (أمر .تحديث الخاص بالبلوغينات يظل يعمل بشكل منفصل تماماً).
    """
    status_message = None
    if event:
        status_message = await event.respond("⏳ جاري بدء التحديث الشامل: فحص المكاتب والإضافات أولاً...")

    # الخطوة 1: فحص وتحديث المكاتب أولاً
    pip_success, pip_log = await upgrade_pip_requirements()
    if not pip_success:
        if status_message:
            await status_message.edit(f"⚠️ فشل تحديث المكاتب:\n{pip_log}")
        return

    if status_message:
        await status_message.edit("🔄 تم فحص المكاتب بنجاح. جاري الآن سحب وتحديث السورس والإضافات...")

    # الخطوة 2: سحب وتحديث السورس والإضافات ثانياً
    git_success, git_log = await pull_git_updates()
    if not git_success:
        if status_message:
            await status_message.edit(f"❌ تم تحديث المكاتب ولكن فشل سحب السورس:\n{git_log}")
        return

    if status_message:
        await status_message.edit("✅ اكتمل التحديث الشامل (المكاتب + السورس + الإضافات) بنجاح! جاري إعادة التشغيل...")

    # الخطوة 3: إعادة التشغيل المباشر للبوت
    os.execl(sys.executable, sys.executable, "-m", "app")
