From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 24 Apr 2008 11:19:13 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <20080424111913.GB15640%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 23, 2008 at 04:03:58PM +0200, Jes Sorensen wrote:
> Isaku Yamahata wrote:
> >>I'd rather have PARAVIRT_NR_IRQ set from Kconfig if possible given that
> >>all of these are constants anyway. If we cannot do that, then it would
> >>be better to do the #if FOO_NR_IRQ > PARAVIRT_NR_IRQ in the various
> >>header files for Xen/KVM/lguest so we don't get the clutter in the main
> >>makefile.
> >
> >Unfotunately Kconfig doesn't support arithmetic comparison.
> >So do you want something like the followings?
> 
> IMHO, that would be better.

How about this?
Eventually I found another way which doesn't use #undef trick.
ASM_OFFSET_C is somewhat tricky, but much better, I suppose.

From 8b13a7498112d2f3f1d8eb58543209956ffc5417 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 24 Apr 2008 19:53:50 +0900
Subject: ia64/pv_ops: paravirtualize NR_IRQS

Make NR_IRQ overridable by each pv instances.
Pv instance may need each own number of irqs so that
NR_IRQS should be the maximum number of nr_irqs each
pv instances need.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/asm-offsets.c |   18 ++++++++++++++++++
 include/asm-ia64/hardirq.h     |    4 +++-
 include/asm-ia64/irq.h         |   13 +++++++++++--
 3 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 230a6f9..dff6403 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -10,6 +10,7 @@
 #include <linux/pid.h>
 #include <linux/clocksource.h>
 
+#include <asm-ia64/irq.h>
 #include <asm-ia64/processor.h>
 #include <asm-ia64/ptrace.h>
 #include <asm-ia64/siginfo.h>
@@ -291,4 +292,21 @@ void foo(void)
 		offsetof (struct itc_jitter_data_t, itc_jitter));
 	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
 		offsetof (struct itc_jitter_data_t, itc_lastcycle));
+	BLANK();
+
+	{
+		/*
+		 * calculate
+		 * max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, FOO_NR_IRQS...)
+		 * depending on config.
+		 */
+		union paravirt_nr_irqs_max {
+			char ia64_native_nr_irqs[IA64_NATIVE_NR_IRQS];
+#ifdef CONFIG_XEN
+			char xen_nr_irqs[XEN_NR_IRQS];
+#endif
+		};
+
+		DEFINE(PARAVIRT_NR_IRQS, sizeof (union paravirt_nr_irqs_max));
+	}
 }
diff --git a/include/asm-ia64/hardirq.h b/include/asm-ia64/hardirq.h
index 140e495..7ee7626 100644
--- a/include/asm-ia64/hardirq.h
+++ b/include/asm-ia64/hardirq.h
@@ -8,7 +8,9 @@
 
 
 #include <linux/threads.h>
+#ifndef ASM_OFFSETS_C
 #include <linux/irq.h>
+#endif
 
 #include <asm/processor.h>
 
@@ -26,7 +28,7 @@
  * The hardirq mask has to be large enough to have space for potentially all IRQ sources
  * in the system nesting on a single CPU:
  */
-#if (1 << HARDIRQ_BITS) < NR_IRQS
+#if !defined (ASM_OFFSETS_C) && ((1 << HARDIRQ_BITS) < NR_IRQS)
 # error HARDIRQ_BITS is too low!
 #endif
 
diff --git a/include/asm-ia64/irq.h b/include/asm-ia64/irq.h
index a66d268..5208318 100644
--- a/include/asm-ia64/irq.h
+++ b/include/asm-ia64/irq.h
@@ -17,9 +17,18 @@
 #define NR_VECTORS	256
 
 #if (NR_VECTORS + 32 * NR_CPUS) < 1024
-#define NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
+#define IA64_NATIVE_NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
 #else
-#define NR_IRQS 1024
+#define IA64_NATIVE_NR_IRQS 1024
+#endif
+
+/*
+ * PARAVIRT_NR_IRQS is defined by asm-offsets.c as
+ * max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, ...) depending on config.
+ */
+#ifndef ASM_OFFSETS_C
+#include <asm/asm-offsets.h>
+#define NR_IRQS	PARAVIRT_NR_IRQS
 #endif
 
 static __inline__ int
-- 
1.5.3
