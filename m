From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 23 Sep 2000 06:25:03 +0000
Subject: [Linux-ia64] fix for slow running time-of-day
Message-Id: <marc-linux-ia64-105590678205517@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes the time drift problem that has been plaguing us for
a while.  It turns out that without it, time was running behind by
about 0.3%.  Doesn't sound like a lot, but amounts to about 5 min/day.
Linus already accepted this patch for test9-pre6.

Enjoy,

	--david

--- include/linux/timex.h~	Mon Jul 31 14:01:22 2000
+++ include/linux/timex.h	Thu Sep 21 23:45:26 2000
@@ -51,6 +51,8 @@
 #ifndef _LINUX_TIMEX_H
 #define _LINUX_TIMEX_H
 
+#include <asm/param.h>
+
 /*
  * The following defines establish the engineering parameters of the PLL
  * model. The HZ variable establishes the timer interrupt frequency, 100 Hz
@@ -58,10 +60,20 @@
  * OSF/1 kernel. The SHIFT_HZ define expresses the same value as the
  * nearest power of two in order to avoid hardware multiply operations.
  */
-#ifdef __alpha__
-# define SHIFT_HZ 10		/* log2(HZ) */
+#if HZ >= 24 && HZ < 48
+# define SHIFT_HZ	5
+#elif HZ >= 48 && HZ < 96
+# define SHIFT_HZ	6
+#elif HZ >= 96 && HZ < 192
+# define SHIFT_HZ	7
+#elif HZ >= 192 && HZ < 384
+# define SHIFT_HZ	8
+#elif HZ >= 384 && HZ < 768
+# define SHIFT_HZ	9
+#elif HZ >= 768 && HZ < 1536
+# define SHIFT_HZ	10
 #else
-# define SHIFT_HZ 7		/* log2(HZ) */
+# error You lose.
 #endif
 
 /*

