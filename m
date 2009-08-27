From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 27 Aug 2009 03:16:21 +0000
Subject: [Patch 4/8] ia64: implement crashkernel=auto
Message-Id: <20090827031848.4534.40440.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827031800.4534.94868.sendpatchset@localhost.localdomain>
In-Reply-To: <20090827031800.4534.94868.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Michael Ellerman <michael@ellerman.id.au>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Amerigo Wang <amwang@redhat.com>


Since in patch 2/8 we already implement the generic part, this will
add the rest part for ia64.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>

---

Index: linux-2.6/arch/ia64/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/kexec.h
+++ linux-2.6/arch/ia64/include/asm/kexec.h
@@ -1,6 +1,7 @@
 #ifndef _ASM_IA64_KEXEC_H
 #define _ASM_IA64_KEXEC_H
 
+#include <asm-generic/kexec.h>
 
 /* Maximum physical address we can use pages from */
 #define KEXEC_SOURCE_MEMORY_LIMIT (-1UL)
@@ -19,6 +20,49 @@
                 flush_icache_range(page_addr, page_addr + PAGE_SIZE); \
         } while(0)
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+#define MBYTES(n) ((n)*1024*1024ULL)
+#define GBYTES(n) ((n)*1024*1024*1024ULL)
+/*
+       Memory size     Reserved memory
+       ======     =======+       [4G, 12G)       256M
+       [12G, 128G)     512M
+       [128G, 256G)    768M
+       [256G, 378G)    1024M
+       [378G, 512G)    1536M
+       [512G, 768G)    2048M
+       [768G, )        3072M
+ */
+static inline
+unsigned long long arch_default_crash_size(unsigned long long total_size)
+{
+	unsigned long long ret;
+
+	if (total_size >= GBYTES(4) && total_size < GBYTES(12))
+		ret = MBYTES(256);
+	else if (total_size >= GBYTES(12) && total_size < GBYTES(128))
+		ret = MBYTES(512);
+	else if (total_size >= GBYTES(128) && total_size < GBYTES(256))
+		ret = MBYTES(768);
+	else if (total_size >= GBYTES(256) && total_size < GBYTES(378))
+		ret = MBYTES(1024);
+	else if (total_size >= GBYTES(318) && total_size < GBYTES(512))
+		ret = MBYTES(1536);
+	else if (total_size >= GBYTES(512) && total_size < GBYTES(768))
+		ret = MBYTES(2048);
+	else
+		ret = MBYTES(3072);
+	if (!ia64_platform_is("sn2") && !ia64_platform_is("uv"))
+		if (ret > GBYTES(4))
+			ret = ret / GBYTES(4) * MBYTES(256);
+	return ret;
+}
+#undef GBYTES
+#undef MBYTES
+#define arch_default_crash_size arch_default_crash_size
+#endif
+
 extern struct kimage *ia64_kimage;
 extern const unsigned int relocate_new_kernel_size;
 extern void relocate_new_kernel(unsigned long, unsigned long,
