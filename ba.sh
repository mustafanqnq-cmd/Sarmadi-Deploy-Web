_run_catpack_git() {
    $(_run_python_code 'from git import Repo
import sys

OFFICIAL_UPSTREAM_REPO = "https://github.com/mustafanqnq-cmd/Tython.git"
ACTIVE_BRANCH_NAME = "web"

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

repo.heads[ACTIVE_BRANCH_NAME].checkout(True)
')
}
