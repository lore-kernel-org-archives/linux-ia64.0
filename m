From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 25 Jan 2007 18:06:40 +0000
Subject: [PATCH] Fix NULL-pointer dereference in ia64_machine_kexec()
Message-Id: <eparjg$nhq$1@sea.gmane.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes a NULL-pointer dereference in ia64_machine_kexec().

The variable ia64_kimage is set in machine_kexec_prepare() which is called
from sys_kexec_load(). If kdump wasn't configured before, ia64_kimage is NULL.
machine_kdump_on_init() passes ia64_kimage() to machine_kexec() which assumes
a valid value.

The patch also adds a few sanity checks for the image to simplify debugging of
similar problems in future.

Signed-off-by: Bernhard Walle <bwalle@suse.de>
Acked-by: Raymund Will <rw@suse.de>

---
 arch/ia64/kernel/crash.c         |    4 ++++
 arch/ia64/kernel/machine_kexec.c |    2 ++
 2 files changed, 6 insertions(+)

Index: current-kernel/arch/ia64/kernel/crash.c
=================================--- current-kernel.orig/arch/ia64/kernel/crash.c
+++ current-kernel/arch/ia64/kernel/crash.c
@@ -116,6 +116,10 @@ machine_crash_shutdown(struct pt_regs *p
 static void
 machine_kdump_on_init(void)
 {
+       if (!ia64_kimage) {
+               printk(KERN_NOTICE "Kdump not configured\n");
+               return;
+       }
        local_irq_disable();
        kexec_disable_iosapic();
        machine_kexec(ia64_kimage);
Index: current-kernel/arch/ia64/kernel/machine_kexec.c
=================================--- current-kernel.orig/arch/ia64/kernel/machine_kexec.c
+++ current-kernel/arch/ia64/kernel/machine_kexec.c
@@ -93,6 +93,7 @@ static void ia64_machine_kexec(struct un
        unsigned long vector;
        int ii;
 
+       BUG_ON(!image);
        if (image->type = KEXEC_TYPE_CRASH) {
                crash_save_this_cpu();
                current->thread.ksp = (__u64)info->sw - 16;
@@ -131,6 +132,7 @@ static void ia64_machine_kexec(struct un
 
 void machine_kexec(struct kimage *image)
 {
+       BUG_ON(!image);
        unw_init_running(ia64_machine_kexec, image);
        for(;;);
 }

