#!/usr/bin/env python3
"""
setup/updater.py  --  سكربت مستقل (مو أمر بوت)

يشتغل قبل تشغيل البوت. ما يستورد telethon ولا tython.
الاستخدام:
    python3 setup/updater.py <requirements_قديم> <requirements_جديد>
    python3 setup/updater.py <requirements>
الأول: ينصّب بس المكتبات الموجودة بالجديد وناقصة من القديم.
الثاني: ينصّب كل شي بالملف.
مهم: يطلع دائماً بكود 0 حتى لو صار خطأ، حتى ما يوقف التنصيب.
"""
import os
import re
import subprocess
import sys


def pkg_name(line: str) -> str:
    line = line.split("#", 1)[0].strip()
    if not line or line.startswith("-"):
        return ""
    return re.split(r"[<>=!~\[;\s@]", line, maxsplit=1)[0].lower().replace("_", "-")


def read_reqs(path: str) -> dict:
    out = {}
    if not os.path.isfile(path):
        return out
    with open(path, encoding="utf-8", errors="ignore") as f:
        for raw in f:
            name = pkg_name(raw)
            if name:
                out[name] = raw.split("#", 1)[0].strip()
    return out


def pip_install(specs: list) -> None:
    for spec in specs:
        cmd = [sys.executable, "-m", "pip", "install", "--no-cache-dir", spec]
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            print(("OK   " if r.returncode == 0 else "FAIL ") + spec)
        except Exception as e:  # noqa: BLE001
            print(f"FAIL {spec} ({e})")


def main() -> None:
    args = sys.argv[1:]
    if not args:
        print("updater: لا توجد ملفات requirements .. تخطي")
        return
    if len(args) == 1:
        new = read_reqs(args[0])
        todo = list(new.values())
    else:
        old, new = read_reqs(args[0]), read_reqs(args[1])
        todo = [spec for name, spec in new.items() if name not in old]
    if not todo:
        print("updater: لا توجد مكتبات جديدة .. تخطي")
        return
    print(f"updater: تنصيب {len(todo)} مكتبة ناقصة")
    pip_install(todo)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # noqa: BLE001
        print(f"updater: خطأ تم تجاهله: {e}")
    sys.exit(0)
