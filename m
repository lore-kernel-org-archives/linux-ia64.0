From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 15 Oct 2008 03:18:26 +0000
Subject: Re: [PATCH 09/32] ia64/xen: add a necessary header file to compile include/xen/interface/xen.h
Message-Id: <20081015031826.GC6061%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1223963507-28056-10-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2008 at 02:46:41PM -0700, Luck, Tony wrote:
> +++ b/arch/ia64/include/asm/pvclock-abi.h
> @@ -0,0 +1,5 @@
> +/*
> + * use same structure to x86's
> + * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
> + */
> +#include <asm-x86/pvclock-abi.h>
> 
> 
> I will trade out this patch for one that just makes
> a copy of the x86 include file.  This #include will
> break if/when x86 moves their include files to
> arch/x86/include/asm

I see. Then the first version is preferable.
Here is the one.

From 0dc1a5610d4ea94b535a3a48b25e9b42cd6da5d4 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 4 Jul 2008 11:29:33 +0900
Subject: [PATCH]  ia64/xen: add a necessary header file to compile include/xen/interface/xen.h

Create include/asm-ia64/pvclock-abi.h to compile which contains
the same definitions of include/asm-x86/pvclock-abi.h because ia64/xen
uses same structure.
Hopefully include/asm-x86/pvclock-abi.h would be moved to somewhere
more generic.

Another approach is to include include/asm-x86/pvclock-abi.h
from include/asm-ia64/pvclock-abi.h. But this would break
if x86 header files are moved under arch/x86.
So for now, same definitions are duplicated as suggested by Tony.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/include/asm/pvclock-abi.h |   48 +++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/pvclock-abi.h

diff --git a/arch/ia64/include/asm/pvclock-abi.h b/arch/ia64/include/asm/pvclock-abi.h
new file mode 100644
index 0000000..38a7a9e
--- /dev/null
+++ b/arch/ia64/include/asm/pvclock-abi.h
@@ -0,0 +1,48 @@
+/*
+ * same structure to x86's
+ * Hopefully asm-x86/pvclock-abi.h would be moved to somewhere more generic.
+ * For now, define same duplicated definitions.
+ */
+
+#ifndef ASM_IA64__PVCLOCK_ABI_H
+#define ASM_IA64__PVCLOCK_ABI_H
+#ifndef __ASSEMBLY__
+
+/*
+ * These structs MUST NOT be changed.
+ * They are the ABI between hypervisor and guest OS.
+ * Both Xen and KVM are using this.
+ *
+ * pvclock_vcpu_time_info holds the system time and the tsc timestamp
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
+#endif /* ASM_IA64__PVCLOCK_ABI_H */
-- 
1.6.0.2



-- 
yamahata
