From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 06 Feb 2007 11:40:50 +0000
Subject: [PATCH] Fix NULL-pointer dereference in ia64_machine_kexec()
Message-Id: <20070206114050.GA3648@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <eparjg$nhq$1@sea.gmane.org> <yq0odolq8zg.fsf@jaguar.mkp.net> <20070127131514.GA30463@strauss.suse.de> <45BBD6F5.6040801@sgi.com>
In-Reply-To: <45BBD6F5.6040801@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org

[I got no response after my corrected patch, so I try it again.
I request it to appear in -mm tree. Patch is against 2.6.20-rc6-mm3.]

This patch fixes a NULL-pointer dereference in ia64_machine_kexec().

The variable ia64_kimage is set in machine_kexec_prepare() which is
called from sys_kexec_load(). If kdump wasn't configured before,
ia64_kimage is NULL.  machine_kdump_on_init() passes ia64_kimage() to
machine_kexec() which assumes a valid value.

The patch also adds a few sanity checks for the image to simplify
debugging of similar problems in future.

Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/kernel/crash.c         |    5 +++++
 arch/ia64/kernel/machine_kexec.c |    2 ++
 2 files changed, 7 insertions(+)

Index: b/arch/ia64/kernel/crash.c
=================================--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -116,6 +116,11 @@ machine_crash_shutdown(struct pt_regs *p
 static void
 machine_kdump_on_init(void)
 {
+	if (!ia64_kimage) {
+		printk(KERN_NOTICE "machine_kdump_on_init(): "
+				"kdump not configured\n");
+		return;
+	}
 	local_irq_disable();
 	kexec_disable_iosapic();
 	machine_kexec(ia64_kimage);
Index: b/arch/ia64/kernel/machine_kexec.c
=================================--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -93,6 +93,7 @@ static void ia64_machine_kexec(struct un
 	unsigned long vector;
 	int ii;
 
+	BUG_ON(!image);
 	if (image->type = KEXEC_TYPE_CRASH) {
 		crash_save_this_cpu();
 		current->thread.ksp = (__u64)info->sw - 16;
@@ -131,6 +132,7 @@ static void ia64_machine_kexec(struct un
 
 void machine_kexec(struct kimage *image)
 {
+	BUG_ON(!image);
 	unw_init_running(ia64_machine_kexec, image);
 	for(;;);
 }
