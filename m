From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 21 Aug 2009 06:55:04 +0000
Subject: [Patch 5/8] ia64: implement crashkernel=auto
Message-Id: <20090821065729.4855.47860.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, kamezawa.hiroyu@jp.fujitsu.com, Anton Vorontsov <avorontsov@ru.mvista.com>


Since in patch 3/8 we already implement the generic part, this will
add the rest part for ia64.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>

---

Index: linux-2.6/arch/ia64/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/kexec.h
+++ linux-2.6/arch/ia64/include/asm/kexec.h
@@ -19,6 +19,29 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+#define ARCH_HAS_DEFAULT_CRASH_SIZE
+static inline
+unsigned long long arch_default_crash_size(unsigned long long total_size)
+{
+	if (total_size >= 4ULL<<30 && total_size < 12ULL<<30)
+		return 1ULL<<28;
+	else if (total_size >= 12ULL<<30 && total_size < 128ULL<<30)
+		return 1ULL<<29;
+	else if (total_size >= 128ULL<<30 && total_size < 256ULL<<30)
+		return 3ULL<<28;
+	else if (total_size >= 256ULL<<30 && total_size < 378ULL<<30)
+		return 1ULL<<30;
+	else if (total_size >= 318ULL<<30 && total_size < 512ULL<<30)
+		return 3ULL<<29;
+	else if (total_size >= 512ULL<<30 && total_size < 768ULL<<30)
+		return 2ULL<<30;
+	else if (total_size >= 768ULL<<30)
+		return 3ULL<<30;
+}
+#include <asm-generic/kexec.h>
+#endif
+
 extern struct kimage *ia64_kimage;
 extern const unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
