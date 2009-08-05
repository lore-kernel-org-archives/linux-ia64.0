From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 05 Aug 2009 11:19:41 +0000
Subject: [Patch 4/7] ia64: implement crashkernel=auto
Message-Id: <20090805112201.6552.13193.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
In-Reply-To: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Since in patch 2/7 we already implement the generic part, this will
add the rest part for ia64.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
Index: linux-2.6/arch/ia64/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/kexec.h
+++ linux-2.6/arch/ia64/include/asm/kexec.h
@@ -19,6 +19,29 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
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
+	/* On ia64, 0 means find the base address automatically. */
+	return 0;
+}
+#endif
+
 extern struct kimage *ia64_kimage;
 extern const unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
