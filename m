From: Joel GUILLET <Joel.Guillet@bull.net>
Date: Tue, 17 Dec 2002 16:26:10 +0000
Subject: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105590709805600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is a patch to use the Real Time Clock (RTC) on ia64.
It works on a tiger. It doesn't on early lion machines. (Why ?)
I don't know about others ia64 machines. Please report me - if you test
it.
To see if it works, please check the /var/log/messages. The driver reports
sometimes that "rtc losts some interrupts..." It usually means that the
rtc doesn't work, and the interruptions that arrived were coming from a
software-timer (see the driver code).


This patch is very simple.
I changed the irq affected for the rtc as it is an "ex-i386" interruption.
(an Ox20 offset)
And copied some files from the asm-i386 to asm-ia64...
The duplication of these files is a waste of disk space, but it's coherent
with the way it has been made on i386.

You may want to try this patch and test it.
There is a program test included in the Documentation/rtc.txt of the
kernel tree.

The actual priority of the interruption is low but perhaps it might be
changed (Do anyone know how to make it ?) for some usages.

For the kernel releases after 2.5.45, I've seen that the Kconfig will be
modified so that the option will not be available (unless you activate it
manually).

This can be used for example to run scheduler latencies tests (a way of
using amlat) - I've got some more stuff for this, please mail me.

Here is the patch :


********************************************
diff -urN linux-2.5.45/arch/ia64/kernel/ia64_ksyms.c linux-2.5.45-clean/arch/ia64/kernel/ia64_ksyms.c
--- linux-2.5.45/arch/ia64/kernel/ia64_ksyms.c	Thu Oct 31 01:42:54 2002
+++ linux-2.5.45-clean/arch/ia64/kernel/ia64_ksyms.c	Tue Dec 17 15:08:19 2002
@@ -143,3 +143,5 @@
 #endif
 EXPORT_SYMBOL(machvec_noop);

+extern spinlock_t rtc_lock;
+EXPORT_SYMBOL(rtc_lock);
diff -urN linux-2.5.45/arch/ia64/kernel/time.c linux-2.5.45-clean/arch/ia64/kernel/time.c
--- linux-2.5.45/arch/ia64/kernel/time.c	Thu Oct 31 01:42:20 2002
+++ linux-2.5.45-clean/arch/ia64/kernel/time.c	Tue Dec 17 15:08:19 2002
@@ -27,6 +27,7 @@
 extern rwlock_t xtime_lock;
 extern unsigned long wall_jiffies;
 extern unsigned long last_time_offset;
+spinlock_t rtc_lock = SPIN_LOCK_UNLOCKED;

 u64 jiffies_64;

diff -urN linux-2.5.45/include/asm-ia64/mc146818rtc.h linux-2.5.45-clean/include/asm-ia64/mc146818rtc.h
--- linux-2.5.45/include/asm-ia64/mc146818rtc.h	Thu Oct 31 01:43:38 2002
+++ linux-2.5.45-clean/include/asm-ia64/mc146818rtc.h	Tue Dec 17 15:10:12 2002
@@ -1,10 +1,29 @@
+/*
+ * Machine dependent access functions for RTC registers.
+ */
 #ifndef _ASM_IA64_MC146818RTC_H
 #define _ASM_IA64_MC146818RTC_H

+#include <asm/io.h>
+
+#ifndef RTC_PORT
+#define RTC_PORT(x)	(0x70 + (x))
+#define RTC_ALWAYS_BCD	1	/* RTC operates in binary mode */
+#endif
+
 /*
- * Machine dependent access functions for RTC registers.
+ * The yet supported machines all access the RTC index register via
+ * an ISA port access but the way to access the date register differs ...
  */
+#define CMOS_READ(addr) ({ \
+outb_p((addr),RTC_PORT(0)); \
+inb_p(RTC_PORT(1)); \
+})
+#define CMOS_WRITE(val, addr) ({ \
+outb_p((addr),RTC_PORT(0)); \
+outb_p((val),RTC_PORT(1)); \
+})

-/* empty include file to satisfy the include in genrtc.c */
+#define RTC_IRQ 40 /* irq on a i386 + Ox20  */

 #endif /* _ASM_IA64_MC146818RTC_H */
diff -urN linux-2.5.45/include/asm-ia64/rtc.h linux-2.5.45-clean/include/asm-ia64/rtc.h
--- linux-2.5.45/include/asm-ia64/rtc.h	Thu Jan  1 01:00:00 1970
+++ linux-2.5.45-clean/include/asm-ia64/rtc.h	Tue Dec 17 15:09:03 2002
@@ -0,0 +1,10 @@
+#ifndef _IA64_RTC_H
+#define _IA64_RTC_H
+
+/*
+ * ia64 uses the default access methods for the RTC.
+ */
+
+#include <asm-generic/rtc.h>
+
+#endif
**************************************************************


--------------
**  Joel


