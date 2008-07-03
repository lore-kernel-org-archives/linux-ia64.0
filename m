From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 06:54:43 +0000
Subject: [PATCH] ia64/xen: add a neccessary header file to copmle include/xen/interface/xen.h
Message-Id: <12150681052496-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Create include/asm-ia64/xen/pvclock-abi.h to compile.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/xen/pvclock-abi.h |   44 ++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/pvclock-abi.h

diff --git a/include/asm-ia64/xen/pvclock-abi.h b/include/asm-ia64/xen/pvclock-abi.h
new file mode 100644
index 0000000..0dcf3b4
--- /dev/null
+++ b/include/asm-ia64/xen/pvclock-abi.h
@@ -0,0 +1,44 @@
+/* This file is stolen from include/asm-x86/pvclock-abi.h */
+
+#ifndef _ASM_IA64_XEN_PVCLOCK_ABI_H_
+#define _ASM_IA64_XEN_PVCLOCK_ABI_H_
+#ifndef __ASSEMBLY__
+
+/*
+ * These structs MUST NOT be changed.
+ * They are the ABI between hypervisor and guest OS.
+ * Both Xen and KVM are using this.
+ *
+* pvclock_vcpu_time_info holds the system time and the tsc timestamp
+ * of the last update. So the guest can use the tsc delta to get a
+ * more precise system time.  There is one per virtual cpu.
+ *
+ * pvclock_wall_clock references the point in time when the system
+ * time was zero (usually boot time), thus the guest calculates the
+ * current wall clock by adding the system time.
+ *
+ * Protocol for the "version" fields is: hypervisor raises it (making
+ * it uneven) before it starts updating the fields and raises it again
+ * (making it even) when it is done.  Thus the guest can make sure the
+ * time values it got are consistent by checking the version before
+ * and after reading them.
+ */
+
+struct pvclock_vcpu_time_info {
+	u32   version;
+	u32   pad0;
+	u64   tsc_timestamp;
+	u64   system_time;
+	u32   tsc_to_system_mul;
+	s8    tsc_shift;
+	u8    pad[3];
+} __attribute__((__packed__)); /* 32 bytes */
+
+struct pvclock_wall_clock {
+	u32   version;
+	u32   sec;
+	u32   nsec;
+} __attribute__((__packed__));
+
+#endif /* __ASSEMBLY__ */
+#endif /* _ASM_IA64_XEN_PVCLOCK_ABI_H_ */
-- 
1.5.3

