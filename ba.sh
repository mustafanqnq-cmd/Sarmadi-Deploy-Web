# Cleaned & Powered by Mustafa @CC99V
#!/bin/bash

# ===== كيل سويتش - ريبو منفصل عام مخصص فقط لهذا الغرض (ما إله علاقة بريبو الكود الحقيقي) =====
_check_killswitch() {
    local status
    status=$(curl -fsSL "https://raw.githubusercontent.com/mustafanqnq-cmd/killswitch/main/.killswitch" 2>/dev/null)
    if [ "$status" = "stop" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "❌ هذا الإصدار لم يعد مدعوماً."
        echo "🔄 يرجى إعادة التنصيب من جديد."
        echo "📢 للتواصل: t.me/Tython"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit 1
    fi
}
_check_killswitch
# ====================================================

_get_ziplink () {
    local regex
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "TythonAr" ]]
    then
        echo "aHR0cHM6Ly9naXRodWIuY29tL1RoZVJlcHRob24vUmVwdGhvbkFyL2FyY2hpdmUvd2ViLnppcA==" | base64 -d
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        echo "https://github.com/mustafanqnq-cmd/Tython/archive/main.zip"
    else
        echo "https://github.com/mustafanqnq-cmd/Tython/archive/main.zip"
    fi
}

_get_repolink () {
    local regex
    local rlink
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "Deploy" ]]
    then
        rlink="https://mustafanqnq-cmd:${GITHUB_TOKEN}@github.com/mustafanqnq-cmd/Tython.git"
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        rlink=`echo "${UPSTREAM_REPO}"`
    else
        rlink="https://mustafanqnq-cmd:${GITHUB_TOKEN}@github.com/mustafanqnq-cmd/Tython.git"
    fi
    echo "$rlink"
}

_run_python_code() {
    python3${pVer%.*} -c "$1"
}

_run_catpack_git() {
    $(_run_python_code 'from git import Repo
import os
import sys
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
if GITHUB_TOKEN:
    OFFICIAL_UPSTREAM_REPO = f"https://mustafanqnq-cmd:{GITHUB_TOKEN}@github.com/mustafanqnq-cmd/Tython.git"
else:
    OFFICIAL_UPSTREAM_REPO = "https://github.com/mustafanqnq-cmd/Tython.git"
ACTIVE_BRANCH_NAME = "main"
repo = Repo.init()
try:
    origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
except:
    origin = repo.remote("temponame")
origin.fetch()
try:
    repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
except:
    pass
repo.heads[ACTIVE_BRANCH_NAME].checkout(True)')
}

_run_cat_git() {
    local repolink=$(_get_repolink)
    $(_run_python_code 'from git import Repo
import sys
OFFICIAL_UPSTREAM_REPO="'$repolink'"
ACTIVE_BRANCH_NAME = "main"
repo = Repo.init()
try:
    origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
except:
    origin = repo.remote("temponame")
origin.fetch()
try:
    repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
except:
    pass
repo.heads[ACTIVE_BRANCH_NAME].checkout(True)')
}

_set_bot () {
    local zippath
    zippath="web.zip"
    echo "⌭ جاري تنزيل اكواد السورس ⌭"
    if ! wget -q $(_get_ziplink) -O "$zippath"; then
        echo "❌ فشل تنزيل السورس، توقف التنصيب. حاول مرة ثانية أو تواصل مع الدعم."
        exit 1
    fi
    echo "⌭ تفريغ البيانات ⌭"
    CATPATH=$(zipinfo -1 "$zippath" | grep -v "/.");
    # نضمن نسخة نظيفة تمامًا كل مرة (لا يبقى أي أثر من نسخة قديمة محليًا)
    if [ -d "$CATPATH" ]; then
        rm -rf "$CATPATH"
    fi
    if ! unzip -qq "$zippath"; then
        echo "❌ فشل تفريغ الملفات، توقف التنصيب."
        exit 1
    fi
    echo "⌭ تـم التفريـغ ⌭"
    echo "⌭ يتم التنظيف ⌭"
    rm -rf "$zippath"
    sleep 5
    if ! _run_catpack_git; then
        echo "❌ فشل تجهيز git، توقف التنصيب."
        exit 1
    fi
    cd "$CATPATH" || { echo "❌ فشل الدخول لمجلد السورس، توقف التنصيب."; exit 1; }
    if ! _run_cat_git; then
        echo "❌ فشل سحب آخر تحديث، توقف التنصيب."
        exit 1
    fi
    if ! python3 ../setup/updater.py ../requirements.txt requirements.txt; then
        echo "❌ فشل تحديث المتطلبات (requirements)، توقف التنصيب."
        exit 1
    fi
    chmod -R 755 bin
    echo "✅ تم التحديث بنجاح، جـاري بـدء تنصيـب تايـثون ⌭"
    echo "
    "
    python3 -m tython
}

_set_bot
