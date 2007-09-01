From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Sat, 01 Sep 2007 07:37:48 +0000
Subject: [PATCH 2/2] Fix kernel hangup in kdump on INIT
Message-Id: <1188632268.3930.10.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188632093.3930.6.camel@kane-linux>
In-Reply-To: <1188632093.3930.6.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64 <linux-ia64@vger.kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, kexec@lists.infradead.org

Fix the problem that kdump on INIT hung up if kdump kernel image is
not configured.

The kdump_init_notifier() on monarch CPU stops its operation at
DIE_INIT_MONARCH_LEAVE time if the kdump kernel image is not
configured. On the other hand, kdump_init_notifier() on non-monarch
CPUs get into spin because they don't know the fact the monarch stops
its operation. This is the cause of this problem. To fix this problem,
we need to check the kdump kernel image at the top of the
kdump_init_notifier() function.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/crash.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6.23-rc4/arch/ia64/kernel/crash.c
=================================--- linux-2.6.23-rc4.orig/arch/ia64/kernel/crash.c
+++ linux-2.6.23-rc4/arch/ia64/kernel/crash.c
@@ -118,11 +118,6 @@ machine_crash_shutdown(struct pt_regs *p
 static void
 machine_kdump_on_init(void)
 {
-	if (!ia64_kimage) {
-		ia64_mca_printk(KERN_NOTICE "machine_kdump_on_init(): "
-				"kdump not configured\n");
-		return;
-	}
 	local_irq_disable();
 	kexec_disable_iosapic();
 	machine_kexec(ia64_kimage);
@@ -156,6 +151,14 @@ kdump_init_notifier(struct notifier_bloc
 	if (!kdump_on_init)
 		return NOTIFY_DONE;
 
+	if (!ia64_kimage) {
+		if (val = DIE_INIT_MONARCH_LEAVE)
+			ia64_mca_printk(KERN_NOTICE
+					"%s: kdump not configured\n",
+					__FUNCTION__);
+		return NOTIFY_DONE;
+	}
+
 	if (val != DIE_INIT_MONARCH_LEAVE &&
 	    val != DIE_INIT_SLAVE_LEAVE &&
 	    val != DIE_INIT_MONARCH_PROCESS &&


