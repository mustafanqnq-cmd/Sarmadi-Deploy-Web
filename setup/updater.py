async def update_(event):
    # إرسال رسالة للمستخدم لبدء عملية التحديث
    msg = await event.edit("⌭ جـارِ فحـص التحديـثات.. انتظر قليلاً ⌭")
    
    # تنفيذ أمر سحب التحديثات من مستودع الكود (Git Pull)
    stdout, stderr, returncode, pid = await runcmd("git pull")
    
    # التحقق من نجاح العملية
    if returncode != 0:
        await msg.edit(f"⌭ فشـل التحـديث: {stderr} ⌭")
        return


    if "Already up to date." in stdout:
        await msg.edit("⌭ لا توجد تحديثات جديدة، البوت محدث بالفعل ⌭")
    else:
        await msg.edit("⌭ تـم التحديـث بنجـاح! جـاري إعـادة التشغيـل ⌭")
        # إعادة تشغيل البوت لتطبيق التغييرات
        import os
        os.execl(sys.executable, sys.executable, *sys.argv)
 
