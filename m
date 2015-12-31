From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:06:13 +0000
Subject: [PATCH v2 04/32] ia64: reuse asm-generic/barrier.h
Message-Id: <1451572003-2440-5-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@kernel.org>, D

On ia64 smp_rmb, smp_wmb, read_barrier_depends, smp_read_barrier_depends
and smp_store_mb() match the asm-generic variants exactly. Drop the
local definitions and pull in asm-generic/barrier.h instead.

This is in preparation to refactoring this code area.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/ia64/include/asm/barrier.h | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index 209c4b8..2f93348 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -48,12 +48,6 @@
 # define smp_mb()	barrier()
 #endif
 
-#define smp_rmb()	smp_mb()
-#define smp_wmb()	smp_mb()
-
-#define read_barrier_depends()		do { } while (0)
-#define smp_read_barrier_depends()	do { } while (0)
-
 #define smp_mb__before_atomic()	barrier()
 #define smp_mb__after_atomic()	barrier()
 
@@ -77,12 +71,12 @@ do {									\
 	___p1;								\
 })
 
-#define smp_store_mb(var, value) do { WRITE_ONCE(var, value); smp_mb(); } while (0)
-
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure
  * that none of the previous instructions in the same group are
  * affected by the rsm/ssm.
  */
 
+#include <asm-generic/barrier.h>
+
 #endif /* _ASM_IA64_BARRIER_H */
-- 
MST

