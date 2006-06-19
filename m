From: Horms <horms@verge.net.au>
Date: Mon, 19 Jun 2006 06:48:00 +0000
Subject: [PATCH] ia64,kexec: Move copy_oldmem_page into crash_dump.c
Message-Id: <20060619064758.GB11262@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move copy_oldmem_page() from crash.c to crash_dump.c in keeping with
other architectures. As part of this change, copy_oldmem_page() is
no longer complied if CONFIG_CRASH_DUMP is not configured

This patch is relative to Zou Nan hai's kdump patch which I rediffed
and sent to linux-ia64 and fastboot on the 8th of June
http://permalink.gmane.org/gmane.linux.ports.ia64/14320

Signed-off-by: Horms <horms@verge.net.au>

 arch/ia64/kernel/Makefile     |    1 +
 arch/ia64/kernel/crash.c      |   19 -------------------
 arch/ia64/kernel/crash_dump.c |   28 ++++++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 19 deletions(-)

b1d8efcb99218a8473dc310b5346de7cc7362685
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index b433b58..6b2ff12 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_KEXEC)		+= machine_kexec.o relocate_kernel.o crash.o
+obj-$(CONFIG_CRASH_DUMP)	+= crash_dump.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index 03c3118..6623bfc 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -21,25 +21,6 @@ #include <linux/delay.h>
 #include <linux/elf.h>
 #include <linux/elfcore.h>
 #include <linux/device.h>
-#include <asm/uaccess.h>
-
-size_t copy_oldmem_page(unsigned long pfn, char *buf,
-                               size_t csize, unsigned long offset, int userbuf)
-{
-        void  *vaddr;
-
-        if (!csize)
-                return 0;
-        vaddr = page_address(pfn_to_page(pfn));
-
-        if (userbuf) {
-                if (copy_to_user(buf, (vaddr + offset), csize)) {
-                        return -EFAULT;
-                }
-        } else
-                memcpy(buf, (vaddr + offset), csize);
-        return csize;
-}
 
 static void device_shootdown(void)
 {
diff --git a/arch/ia64/kernel/crash_dump.c b/arch/ia64/kernel/crash_dump.c
new file mode 100644
index 0000000..f22ad7b
--- /dev/null
+++ b/arch/ia64/kernel/crash_dump.c
@@ -0,0 +1,28 @@
+/*
+ * arch/ia64/kernel/crash_dump.c
+ *
+ * Memory preserving reboot related code.
+ *
+ */
+
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <asm/uaccess.h>
+
+size_t copy_oldmem_page(unsigned long pfn, char *buf,
+                               size_t csize, unsigned long offset, int userbuf)
+{
+        void  *vaddr;
+
+        if (!csize)
+                return 0;
+        vaddr = page_address(pfn_to_page(pfn));
+
+        if (userbuf) {
+                if (copy_to_user(buf, (vaddr + offset), csize)) {
+                        return -EFAULT;
+                }
+        } else
+                memcpy(buf, (vaddr + offset), csize);
+        return csize;
+}
