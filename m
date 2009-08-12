From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 12 Aug 2009 08:16:20 +0000
Subject: [Patch 6/8] powerpc: implement crashkernel=auto
Message-Id: <20090812081843.5757.64083.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
In-Reply-To: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


Since in patch 2/8 we already implement the generic part, this will
add the rest part for powerpc.

Signed-off-by: WANG Cong <amwang@redhat.com>

---

Index: linux-2.6/arch/powerpc/include/asm/kexec.h
=================================--- linux-2.6.orig/arch/powerpc/include/asm/kexec.h
+++ linux-2.6/arch/powerpc/include/asm/kexec.h
@@ -39,6 +39,14 @@ typedef void (*crash_shutdown_t)(void);
 
 #ifdef CONFIG_KEXEC
 
+#ifdef CONFIG_KEXEC_AUTO_RESERVE
+#ifdef KEXEC_AUTO_RESERVED_SIZE
+#undef KEXEC_AUTO_RESERVED_SIZE
+#endif
+#define KEXEC_AUTO_RESERVED_SIZE (1ULL<<28) /* 256M */
+#include <asm-generic/kexec.h>
+#endif
+
 /*
  * This function is responsible for capturing register states if coming
  * via panic or invoking dump using sysrq-trigger.
