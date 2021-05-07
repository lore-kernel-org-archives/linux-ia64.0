From: Randy Dunlap <rdunlap@infradead.org>
Date: Fri, 07 May 2021 18:48:37 +0000
Subject: [PATCH v2] ia64: headers: drop duplicated words
Message-Id: <20210507184837.10754-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Delete the repeated words "to" and "the".

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
v2: combine 3 patches; drop previous perfmon patches (files have been
    removed); rebase & resend

 arch/ia64/include/asm/pal.h       |    2 +-
 arch/ia64/include/asm/spinlock.h  |    2 +-
 arch/ia64/include/asm/uv/uv_hub.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--- linux-next-20210507.orig/arch/ia64/include/asm/pal.h
+++ linux-next-20210507/arch/ia64/include/asm/pal.h
@@ -1086,7 +1086,7 @@ static inline long ia64_pal_freq_base(un
 
 /*
  * Get the ratios for processor frequency, bus frequency and interval timer to
- * to base frequency of the platform
+ * the base frequency of the platform
  */
 static inline s64
 ia64_pal_freq_ratios (struct pal_freq_ratio *proc_ratio, struct pal_freq_ratio *bus_ratio,
--- linux-next-20210507.orig/arch/ia64/include/asm/spinlock.h
+++ linux-next-20210507/arch/ia64/include/asm/spinlock.h
@@ -26,7 +26,7 @@
  * the queue, and the other indicating the current tail. The lock is acquired
  * by atomically noting the tail and incrementing it by one (thus adding
  * ourself to the queue and noting our position), then waiting until the head
- * becomes equal to the the initial value of the tail.
+ * becomes equal to the initial value of the tail.
  * The pad bits in the middle are used to prevent the next_ticket number
  * overflowing into the now_serving number.
  *
--- linux-next-20210507.orig/arch/ia64/include/asm/uv/uv_hub.h
+++ linux-next-20210507/arch/ia64/include/asm/uv/uv_hub.h
@@ -257,7 +257,7 @@ static inline int uv_numa_blade_id(void)
 	return 0;
 }
 
-/* Convert a cpu number to the the UV blade number */
+/* Convert a cpu number to the UV blade number */
 static inline int uv_cpu_to_blade_id(int cpu)
 {
 	return 0;
