From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 05 Aug 2009 11:20:00 +0000
Subject: [Patch 6/7] powerpc: implement crashkernel=auto
Message-Id: <20090805112221.6552.34447.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Since in patch 2/7 we already implement the generic part, this will
add the rest part for powerpc.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
Index: linux-2.6/arch/powerpc/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/powerpc/include/asm/kexec.h
+++ linux-2.6/arch/powerpc/include/asm/kexec.h
@@ -39,6 +39,29 @@ typedef void (*crash_shutdown_t)(void);
 
 #ifdef CONFIG_KEXEC
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+#ifndef KEXEC_AUTO_RESERVED_SIZE
+#define KEXEC_AUTO_RESERVED_SIZE 1ULL<<28 /* 256M */
+#endif
+#ifndef KEXEC_AUTO_THRESHOLD
+#define KEXEC_AUTO_THRESHOLD 1ULL<<32 /* 4G */
+#endif
+static inline
+unsigned long long arch_default_crash_size(unsigned long long total_size)
+{
+	if (total_size < KEXEC_AUTO_THRESHOLD)
+		return 0;
+	else
+		return KEXEC_AUTO_RESERVED_SIZE;
+}
+static inline
+unsigned long long arch_default_crash_base(void)
+{
+	/* On ppc, 0 means find the base address automatically. */
+	return 0;
+}
+#endif
+
 /*
  * This function is responsible for capturing register states if coming
  * via panic or invoking dump using sysrq-trigger.
