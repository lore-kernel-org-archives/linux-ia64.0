From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 04 Sep 2009 10:09:26 +0000
Subject: [Patch 6/8] powerpc: implement crashkernel=auto
Message-Id: <20090904101153.5220.97139.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
In-Reply-To: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Michael Ellerman <michael@ellerman.id.au>, Amerigo Wang <amwang@redhat.com>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Since in patch 2/8 we already implement the generic part, this will
add the rest part for powerpc.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>
Cc: M. Mohan Kumar <mohan@in.ibm.com>
Cc: Michael Ellerman <michael@ellerman.id.au>

---

Index: linux-2.6/arch/powerpc/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/powerpc/include/asm/kexec.h
+++ linux-2.6/arch/powerpc/include/asm/kexec.h
@@ -39,6 +39,28 @@ typedef void (*crash_shutdown_t)(void);
 
 #ifdef CONFIG_KEXEC
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+
+#ifndef KEXEC_AUTO_THRESHOLD
+#define KEXEC_AUTO_THRESHOLD (1ULL<<31) /* 2G */
+#endif
+
+#ifndef arch_default_crash_base
+extern
+unsigned long long __init arch_default_crash_base(void);
+#define arch_default_crash_base arch_default_crash_base
+#endif
+
+#ifndef arch_default_crash_size
+extern
+unsigned long long __init arch_default_crash_size(unsigned long long);
+#define arch_default_crash_size arch_default_crash_size
+#endif
+
+#endif
+
+#include <asm-generic/kexec.h>
+
 /*
  * This function is responsible for capturing register states if coming
  * via panic or invoking dump using sysrq-trigger.
Index: linux-2.6/arch/powerpc/kernel/machine_kexec.c
=================================--- linux-2.6.orig/arch/powerpc/kernel/machine_kexec.c
+++ linux-2.6/arch/powerpc/kernel/machine_kexec.c
@@ -61,6 +61,30 @@ void machine_kexec(struct kimage *image)
 	for(;;);
 }
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+unsigned long long __init arch_default_crash_base(void)
+{
+	return KDUMP_KERNELBASE;
+}
+
+unsigned long long __init arch_default_crash_size(unsigned long long total_size)
+{
+	if (total_size < KEXEC_AUTO_THRESHOLD)
+		return 0;
+	if (total_size < (1ULL<<32))
+		return 1ULL<<27;
+	else {
+#ifdef CONFIG_64BIT
+		if (total_size > (1ULL<<37)) /* 128G */
+			return 1ULL<<32; /* 4G */
+		return 1ULL<<ilog2(roundup(total_size/32, 1ULL<<21));
+#else
+		return 1ULL<<28;
+#endif
+	}
+}
+#endif
+
 void __init reserve_crashkernel(void)
 {
 	unsigned long long crash_size, crash_base;
