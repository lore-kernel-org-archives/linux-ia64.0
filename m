From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:35:00 +0000
Subject: [PATCH 2/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BE04.5090301@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7ilnji9k.fsf@sykes.suse.de>
In-Reply-To: <je7ilnji9k.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [2/9] ia64_expand_ia64_cputime_h.patch

To check and gather well-grained time, a problem comes
first. It is unit of cpu time, i.e. type of cputime_t.

  [include/linux/sched.h]
    struct task_struct {
       cputime_t utime, stime;

On ia64, this cputime_t is defined quite simply.

  [include/asm-ia64/cputime.h]
   1 #ifndef __IA64_CPUTIME_H
   2 #define __IA64_CPUTIME_H
   3
   4 #include <asm-generic/cputime.h>
   5
   6 #endif /* __IA64_CPUTIME_H */

The unit of generic cputime_t is:

  [include/asm-generic/cputime.h]
     #define jiffies_to_cputime(__jif)	(__jif)

tick, equal to jiffies, msec in HZ00.

Therefore, no matter how good grained time we can gather,
we need to round the time value into tick when it save to
stime/utime. Even if we can distinguish 0.6ms and 1.4ms,
we cannot do it after rounding both to 1ms.

To keep accurate time value, we need to define ia64 specific
cputime_t. As the first step to do it, this patch just copy
definitions in asm-generic/cputime.h to asm-ia64/cputime.h.

Required change will be done in next patch[3/9].

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 include/asm-ia64/cputime.h |   76 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+)

Index: linux-2.6.23/include/asm-ia64/cputime.h
=================================--- linux-2.6.23.orig/include/asm-ia64/cputime.h
+++ linux-2.6.23/include/asm-ia64/cputime.h
@@ -1,6 +1,82 @@
+/*
+ *  include/asm-ia64/cputime.h
+ *
+ *  (C) Copyright FUJITSU LIMITED 2007
+ */
+
 #ifndef __IA64_CPUTIME_H
 #define __IA64_CPUTIME_H

+#ifndef CONFIG_VIRT_CPU_ACCOUNTING
 #include <asm-generic/cputime.h>
+#else
+
+#include <linux/time.h>
+#include <linux/jiffies.h>
+#include <asm/processor.h>
+
+typedef u64 cputime_t;
+typedef u64 cputime64_t;
+
+#define cputime_zero			((cputime_t)0)
+#define cputime_max			((~((cputime_t)0) >> 1) - 1)
+#define cputime_add(__a, __b)		((__a) +  (__b))
+#define cputime_sub(__a, __b)		((__a) -  (__b))
+#define cputime_div(__a, __n)		((__a) /  (__n))
+#define cputime_halve(__a)		((__a) >> 1)
+#define cputime_eq(__a, __b)		((__a) = (__b))
+#define cputime_gt(__a, __b)		((__a) >  (__b))
+#define cputime_ge(__a, __b)		((__a) >= (__b))
+#define cputime_lt(__a, __b)		((__a) <  (__b))
+#define cputime_le(__a, __b)		((__a) <= (__b))
+
+#define cputime64_zero			((cputime64_t)0)
+#define cputime64_add(__a, __b)		((__a) + (__b))
+#define cputime64_sub(__a, __b)		((__a) - (__b))
+#define cputime_to_cputime64(__ct)	(__ct)
+
+/*
+ * Convert cputime <-> jiffies
+ */
+#define cputime_to_jiffies(__ct)	(__ct)
+#define jiffies_to_cputime(__jif)	(__jif)
+#define cputime64_to_jiffies64(__ct)	(__ct)
+#define jiffies64_to_cputime64(__jif)	(__jif)
+
+/*
+ * Convert cputime <-> milliseconds
+ */
+#define cputime_to_msecs(__ct)		jiffies_to_msecs(__ct)
+#define msecs_to_cputime(__msecs)	msecs_to_jiffies(__msecs)
+
+/*
+ * Convert cputime <-> seconds
+ */
+#define cputime_to_secs(__ct)		((__ct) / HZ)
+#define secs_to_cputime(__secs)		((__secs) * HZ)
+
+/*
+ * Convert cputime <-> timespec
+ */
+#define timespec_to_cputime(__val)	timespec_to_jiffies(__val)
+#define cputime_to_timespec(__ct,__val)	jiffies_to_timespec(__ct,__val)
+
+/*
+ * Convert cputime <-> timeval
+ */
+#define timeval_to_cputime(__val)	timeval_to_jiffies(__val)
+#define cputime_to_timeval(__ct,__val)	jiffies_to_timeval(__ct,__val)
+
+/*
+ * Convert cputime <-> clock
+ */
+#define cputime_to_clock_t(__ct)	jiffies_to_clock_t(__ct)
+#define clock_t_to_cputime(__x)		clock_t_to_jiffies(__x)
+
+/*
+ * Convert cputime64 to clock.
+ */
+#define cputime64_to_clock_t(__ct)      jiffies_64_to_clock_t(__ct)

+#endif /* CONFIG_VIRT_CPU_ACCOUNTING */
 #endif /* __IA64_CPUTIME_H */


