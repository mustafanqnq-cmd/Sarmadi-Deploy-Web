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
        if [[ $UPSTREAM_REPO_BRANCH ]]
        then
            echo "$https://github.com/mustafanqnq-cmd/mustafanqnq-cmd/Tython.git/archive/main.zip"
        else
            echo "$https://github.com/mustafanqnq-cmd/mustafanqnq-cmd/Tython.git/archive/main.zip"
        fi
    else
        echo "aHR0cHM6Ly9naXRodWIuY29tL1RoZVJlcHRob24vUmVwdGhvbkFyL2FyY2hpdmUvd2ViLnppcA==" | base64 -d
    fi
}

_get_repolink () {
    local regex
    local rlink
    regex='(https?)://github.com/.+/.+'
    if [[ $UPSTREAM_REPO == "Deploy" ]]
    then
        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL0Fyd2EtQmFxaXIvQXJ3YS1EZXBsb3k=" | base64 -d`
    elif [[ $UPSTREAM_REPO =~ $regex ]]
    then
        rlink=`echo "${UPSTREAM_REPO}"`
    else
        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL0Fyd2EtQmFxaXIvQXJ3YS1EZXBsb3k=" | base64 -d`
    fi
    echo "$rlink"
}


_run_python_code() {
    python3${pVer%.*} -c "$1"
}

_run_catpack_git() {
    $(_run_python_code 'from git import Repo
import sys
    OFFICIAL_UPSTREAM_REPO = "https://mustafanqnq-cmd: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@github.com/mustafanqnq-cmd/mustafanqnq-cmd/Tython.git"
ACTIVE_BRANCH_NAME = "web"
repo = Repo.init()
origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
origin.fetch()
repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')
}

_run_cat_git() {
    local repolink=$(_get_repolink)
    $(_run_python_code 'from git import Repo
import sys
OFFICIAL_UPSTREAM_REPO="'$repolink'"
ACTIVE_BRANCH_NAME = "'$UPSTREAM_REPO_BRANCH'" or "web"
repo = Repo.init()
origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
origin.fetch()
repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')
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
    echo "⌭ جـاري بـدء تنصيـب ريبـــثون ⌭"
    echo "
    "
    python3 -m tython
}

_set_bot
