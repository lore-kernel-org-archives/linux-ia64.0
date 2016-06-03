From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Fri, 03 Jun 2016 08:50:32 +0000
Subject: [PATCH 5/8] kdump: arrange for paddr_vmcoreinfo_note() to return phys_addr_t
Message-Id: <E1b8koK-0004HS-K9@rmk-PC.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On PAE systems (eg, ARM LPAE) the vmcore note may be located above
4GB physical on 32-bit architectures, so we need a wider type than
"unsigned long" here.  Arrange for paddr_vmcoreinfo_note() to return
a phys_addr_t, thereby allowing it to be located above 4GB.

This makes no difference for kexec-tools, as they already assume a
64-bit type when reading from this file.

Acked-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Pratyush Anand <panand@redhat.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/ia64/kernel/machine_kexec.c | 2 +-
 include/linux/kexec.h            | 2 +-
 kernel/kexec_core.c              | 2 +-
 kernel/ksysfs.c                  | 4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index b72cd7a07222..599507bcec91 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -163,7 +163,7 @@ void arch_crash_save_vmcoreinfo(void)
 #endif
 }
 
-unsigned long paddr_vmcoreinfo_note(void)
+phys_addr_t paddr_vmcoreinfo_note(void)
 {
 	return ia64_tpa((unsigned long)(char *)&vmcoreinfo_note);
 }
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 1b32ab587f66..52a3a221bcb2 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -235,7 +235,7 @@ void crash_unmap_reserved_pages(void);
 void arch_crash_save_vmcoreinfo(void);
 __printf(1, 2)
 void vmcoreinfo_append_str(const char *fmt, ...);
-unsigned long paddr_vmcoreinfo_note(void);
+phys_addr_t paddr_vmcoreinfo_note(void);
 
 #define VMCOREINFO_OSRELEASE(value) \
 	vmcoreinfo_append_str("OSRELEASE=%s\n", value)
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d719a4d0ef55..f9847e5822e6 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -1377,7 +1377,7 @@ void vmcoreinfo_append_str(const char *fmt, ...)
 void __weak arch_crash_save_vmcoreinfo(void)
 {}
 
-unsigned long __weak paddr_vmcoreinfo_note(void)
+phys_addr_t __weak paddr_vmcoreinfo_note(void)
 {
 	return __pa((unsigned long)(char *)&vmcoreinfo_note);
 }
diff --git a/kernel/ksysfs.c b/kernel/ksysfs.c
index 152da4a48867..9f1920d2d0c6 100644
--- a/kernel/ksysfs.c
+++ b/kernel/ksysfs.c
@@ -128,8 +128,8 @@ KERNEL_ATTR_RW(kexec_crash_size);
 static ssize_t vmcoreinfo_show(struct kobject *kobj,
 			       struct kobj_attribute *attr, char *buf)
 {
-	return sprintf(buf, "%lx %x\n",
-		       paddr_vmcoreinfo_note(),
+	phys_addr_t vmcore_base = paddr_vmcoreinfo_note();
+	return sprintf(buf, "%pa %x\n", &vmcore_base,
 		       (unsigned int)sizeof(vmcoreinfo_note));
 }
 KERNEL_ATTR_RO(vmcoreinfo);
-- 
2.1.0

