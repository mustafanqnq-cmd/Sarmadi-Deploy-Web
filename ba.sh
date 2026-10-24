set -Eeuo pipefail

SOURCE_REPOSITORY="mustafanqnq-cmd/Tython"
SOURCE_URL="https://github.com/${SOURCE_REPOSITORY}.git"
SOURCE_DIR="/app/Tython"
AUTH_FILE=""
REPO_INFO_FILE=""

cleanup() {
    if [[ -n "${AUTH_FILE}" && -f "${AUTH_FILE}" ]]; then
        rm -f "${AUTH_FILE}"
    fi
    if [[ -n "${REPO_INFO_FILE}" && -f "${REPO_INFO_FILE}" ]]; then
        rm -f "${REPO_INFO_FILE}"
    fi
}
trap cleanup EXIT

if [[ -z "${GITHUB_TOKEN:-}" || -z "${GITHUB_TOKEN//[[:space:]]/}" ]]; then
    printf '%s\n' 'فشل التشغيل: أدخل GITHUB_TOKEN في متغيرات البيئة أولاً.'
    printf '%s\n' 'يجب أن يكون التوكن مخولاً لقراءة المستودع الخاص.'
    exit 10
fi

AUTH_FILE="$(mktemp)"
REPO_INFO_FILE="$(mktemp)"
chmod 600 "${AUTH_FILE}" "${REPO_INFO_FILE}"
printf 'Authorization: Bearer %s\n' "${GITHUB_TOKEN}" > "${AUTH_FILE}"

printf '%s\n' 'المرحلة 1 من 4: التحقق من توكن GitHub وصلاحية الوصول.'
HTTP_STATUS="$(curl --silent --show-error --location --output "${REPO_INFO_FILE}" --write-out '%{http_code}' \
    --header "@${AUTH_FILE}" \
    --header 'Accept: application/vnd.github+json' \
    --header 'X-GitHub-Api-Version: 2022-11-28' \
    "https://api.github.com/repos/${SOURCE_REPOSITORY}" || true)"

if [[ "${HTTP_STATUS}" != "200" ]]; then
    printf '%s\n' 'فشل التحقق من GitHub. تأكد من صحة GITHUB_TOKEN وأن الحساب يملك صلاحية قراءة المستودع الخاص.'
    printf 'رمز استجابة GitHub: %s\n' "${HTTP_STATUS:-غير معروف}"
    printf '%s\n' 'للتوكن المحدد استخدم صلاحية Contents: Read-only وMetadata: Read-only على مستودع Tython.'
    exit 11
fi

DEFAULT_BRANCH="$(python3 - "${REPO_INFO_FILE}" "${SOURCE_REPOSITORY}" <<'PY'
import json
import sys

path, expected = sys.argv[1:]
try:
    with open(path, encoding="utf-8") as source:
        repository = json.load(source)
except Exception:
    raise SystemExit("تعذر قراءة معلومات المستودع من GitHub.")

if str(repository.get("full_name", "")).lower() != expected.lower():
    raise SystemExit("المستودع الذي أعاده GitHub لا يطابق المستودع المطلوب.")
if repository.get("archived") or repository.get("disabled"):
    raise SystemExit("المستودع مؤرشف أو معطّل على GitHub.")

branch = repository.get("default_branch") or "main"
if not branch or branch.startswith("-"):
    raise SystemExit("اسم الفرع الافتراضي غير صالح.")
print(branch)
PY
)" || {
    printf '%s\n' 'فشل التحقق من بيانات المستودع الخاص.'
    exit 12
}

printf '%s\n' 'المرحلة 2 من 4: تنزيل السورس الخاص باستخدام التوكن المتحقق منه.'
rm -rf "${SOURCE_DIR}"
mkdir -p "$(dirname "${SOURCE_DIR}")"

# دمج التوكن مباشرة داخل الرابط لتجاوز أخطاء المصادقة في الحاويات
SECURE_URL="https://${GITHUB_TOKEN}@github.com/${SOURCE_REPOSITORY}.git"

if ! git clone --depth 1 --single-branch --branch "${DEFAULT_BRANCH}" "${SECURE_URL}" "${SOURCE_DIR}"; then
    printf '%s\n' 'فشل تنزيل السورس. تحقق من صلاحية Contents: Read-only ومن وجود الفرع الافتراضي.'
    exit 13
fi

if [[ -f "${SOURCE_DIR}/.killswitch" ]] && grep -qx 'stop' "${SOURCE_DIR}/.killswitch"; then
    printf '%s\n' 'هذا الإصدار لم يعد مدعوماً. أوقف المطور تشغيله من المستودع.'
    exit 14
fi

if [[ ! -f "${SOURCE_DIR}/requirements.txt" ]]; then
    printf '%s\n' 'تنبيه: لم يوجد requirements.txt داخل السورس؛ سيتم تجاوز تحديث المكتبات الإضافية.'
else
    printf '%s\n' 'المرحلة 3 من 4: فحص مكتبات السورس وتثبيت المكتبات الناقصة.'
    python3 /app/setup/updater.py /app/requirements.txt "${SOURCE_DIR}/requirements.txt"
fi

if [[ ! -d "${SOURCE_DIR}/tython" ]]; then
    printf '%s\n' 'فشل التشغيل: لم يتم العثور على مجلد tython داخل السورس الذي تم تنزيله.'
    exit 15
fi

if [[ -d "${SOURCE_DIR}/bin" ]]; then
    chmod -R 755 "${SOURCE_DIR}/bin"
fi

printf '%s\n' 'المرحلة 4 من 4: بدء تشغيل Tython.'
cd "${SOURCE_DIR}"
exec python3 -m tython
