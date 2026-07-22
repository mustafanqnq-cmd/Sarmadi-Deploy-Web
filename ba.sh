# Cleaned & Powered by Mustafa @CC99V
#!/bin/bash

# ===== كيل سويتش - تحكم من ريبو Tython مباشرة =====
_check_killswitch() {
    local status
    status=$(curl -fsSL "https://raw.githubusercontent.com/mustafanqnq-cmd/Tython/main/.killswitch" 2>/dev/null)
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

# رابط الـ Worker والرمز السري الافتراضي
WORKER_URL="https://falling-leafgithub-proxy.mustafanqnq.workers.dev/"
DEFAULT_SECRET="SUPHE999"

_set_bot () {
    local zippath="web.zip"

    if [ -n "$GITHUB_TOKEN" ]; then
        echo "⌭ تم التعرّف على GITHUB_TOKEN: جاري التحميل المباشر من كيثهاب ⌭"
        curl -sSL -H "Authorization: token ${GITHUB_TOKEN}" \
             "https://api.github.com/repos/mustafanqnq-cmd/Tython/zipball/main" -o "$zippath"
    else
        echo "⌭ لم يتم تقديم توكن: جاري التحميل عبر السيرفر الآمن (Cloudflare) ⌭"
        
        AUTH_SECRET="${LAUNCHER_SECRET:-$DEFAULT_SECRET}"
        curl -sSL -H "X-Launcher-Auth: ${AUTH_SECRET}" "${WORKER_URL}" -o "$zippath"
    fi

    # التحقق من أن الملف المُنزل هو ملف Zip حقيقي (يبدأ بـ PK)
    HEADER=$(head -c 2 "$zippath" 2>/dev/null)
    if [ "$HEADER" != "PK" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "❌ فشل تحميل السورس! الاستجابة القادمة من السيرفر:"
        echo ""
        cat "$zippath" 2>/dev/null
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        rm -rf "$zippath"
        exit 1
    fi

    echo "⌭ تفريغ البيانات ⌭"
    CATPATH=$(zipinfo -1 "$zippath" | head -n 1 | cut -d/ -f1)
    unzip -qq "$zippath"
    echo "⌭ تـم التفريـغ ⌭"
    
    echo "⌭ يتم التنظيف ⌭"
    rm -rf "$zippath"
    
    sleep 2
    cd "$CATPATH" || exit 1

    git init -q
    git config user.name "Tython"
    git config user.email "tython@localhost"
    git add .
    git commit -m "Initial commit" -q

    python3 ../setup/updater.py ../requirements.txt requirements.txt 2>/dev/null || true
    chmod -R 755 bin 2>/dev/null
    
    echo "⌭ جـاري بـدء تنصيـب تايـثون ⌭"
    echo ""
    python3 -m tython
}

_set_bot
