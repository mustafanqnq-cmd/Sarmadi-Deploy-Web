# Cleaned & Powered by Mustafa @CC99V
#!/bin/bash

_get_ziplink () {
    local regex
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "TythonAr" ]]
    then
        echo "aHR0cHM6Ly9naXRodWIuY29tL1RoZVJlcHRob24vUmVwdGhvbkFyL2FyY2hpdmUvd2ViLnppcA==" | base64 -d
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        # تصحيح الرابط وحذف علامة الـ $ واليوزر المكرر
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
        rlink="https://mustafanqnq-cmd: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@github.com/mustafanqnq-cmd/Tython.git"
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        rlink=`echo "${UPSTREAM_REPO}"`
    else
        rlink="https://mustafanqnq-cmd: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@github.com/mustafanqnq-cmd/Tython.git"
    fi
    echo "$rlink"
}

_run_python_code() {
    python3${pVer%.*} -c "$1"
}

_run_catpack_git() {
    # تصحيح الإزاحة والفراغات القاتلة وضبط الرابط المحمي بالتوكن
    $(_run_python_code 'from git import Repo
import sys
OFFICIAL_UPSTREAM_REPO = "https://mustafanqnq-cmd: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@github.com/mustafanqnq-cmd/Tython.git"
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
    wget -q $(_get_ziplink) -O "$zippath"
    echo "⌭ تفريغ البيانات ⌭"
    CATPATH=$(zipinfo -1 "$zippath" | grep -v "/.");
    unzip -qq "$zippath"
    echo "⌭ تـم التفريـغ ⌭"
    echo "⌭ يتم التنظيف ⌭"
    rm -rf "$zippath"
    sleep 5
    _run_catpack_git
    cd $CATPATH
    _run_cat_git
    python3 ../setup/updater.py ../requirements.txt requirements.txt
    chmod -R 755 bin
    echo "⌭ جـاري بـدء تنصيـب تايـثون ⌭"
    echo "
    "
    python3 -m tython
}

_set_bot
