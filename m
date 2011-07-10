From: Andy Lutomirski <luto@MIT.EDU>
Date: Sun, 10 Jul 2011 03:22:12 +0000
Subject: [PATCH v2 5/8] clocksource: Replace vread with generic arch data
Message-Id: <0146b59882dbfa89f8cd6ef219881f398522b430.1310267866.git.luto@mit.edu>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1310267866.git.luto@mit.edu>
In-Reply-To: <cover.1310267866.git.luto@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, John Stultz <johnstul@us.ibm.com>, Borislav Petkov <bp@amd64.org>, Andy Lutomirski <luto@MIT.EDU>, Clemens Ladisch <clemens@ladisch.de>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>

The vread field was bloating struct clocksource everywhere except
x86_64, and I want to change the way this works on x86_64, so let's
split it out into per-arch data.

Cc: x86@kernel.org
Cc: Clemens Ladisch <clemens@ladisch.de>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andy Lutomirski <luto@mit.edu>
---
 arch/x86/include/asm/clocksource.h |   16 ++++++++++++++++
 arch/x86/kernel/hpet.c             |    2 +-
 arch/x86/kernel/tsc.c              |    2 +-
 arch/x86/kernel/vsyscall_64.c      |    2 +-
 include/asm-generic/clocksource.h  |    4 ++++
 include/linux/clocksource.h        |   10 ++++++++--
 6 files changed, 31 insertions(+), 5 deletions(-)
 create mode 100644 arch/x86/include/asm/clocksource.h
 create mode 100644 include/asm-generic/clocksource.h

diff --git a/arch/x86/include/asm/clocksource.h b/arch/x86/include/asm/clocksource.h
new file mode 100644
index 0000000..a5df33f
--- /dev/null
+++ b/arch/x86/include/asm/clocksource.h
@@ -0,0 +1,16 @@
+/* x86-specific clocksource additions */
+
+#ifndef _ASM_X86_CLOCKSOURCE_H
+#define _ASM_X86_CLOCKSOURCE_H
+
+#ifdef CONFIG_X86_64
+
+#define __ARCH_HAS_CLOCKSOURCE_DATA
+
+struct arch_clocksource_data {
+	cycle_t (*vread)(void);
+};
+
+#endif /* CONFIG_X86_64 */
+
+#endif /* _ASM_X86_CLOCKSOURCE_H */
diff --git a/arch/x86/kernel/hpet.c b/arch/x86/kernel/hpet.c
index e9f5605..0e07257 100644
--- a/arch/x86/kernel/hpet.c
+++ b/arch/x86/kernel/hpet.c
@@ -753,7 +753,7 @@ static struct clocksource clocksource_hpet = {
 	.flags		= CLOCK_SOURCE_IS_CONTINUOUS,
 	.resume		= hpet_resume_counter,
 #ifdef CONFIG_X86_64
-	.vread		= vread_hpet,
+	.archdata	= { .vread = vread_hpet },
 #endif
 };
 
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index 6cc6922..e7a74b8 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -777,7 +777,7 @@ static struct clocksource clocksource_tsc = {
 	.flags                  = CLOCK_SOURCE_IS_CONTINUOUS |
 				  CLOCK_SOURCE_MUST_VERIFY,
 #ifdef CONFIG_X86_64
-	.vread                  = vread_tsc,
+	.archdata               = { .vread = vread_tsc },
 #endif
 };
 
diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index 6d14848..40a379c 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -74,7 +74,7 @@ void update_vsyscall(struct timespec *wall_time, struct timespec *wtm,
 	write_seqlock_irqsave(&vsyscall_gtod_data.lock, flags);
 
 	/* copy vsyscall data */
-	vsyscall_gtod_data.clock.vread		= clock->vread;
+	vsyscall_gtod_data.clock.vread		= clock->archdata.vread;
 	vsyscall_gtod_data.clock.cycle_last	= clock->cycle_last;
 	vsyscall_gtod_data.clock.mask		= clock->mask;
 	vsyscall_gtod_data.clock.mult		= mult;
diff --git a/include/asm-generic/clocksource.h b/include/asm-generic/clocksource.h
new file mode 100644
index 0000000..0a462d3
--- /dev/null
+++ b/include/asm-generic/clocksource.h
@@ -0,0 +1,4 @@
+/*
+ * Architectures should override this file to add private userspace
+ * clock magic if needed.
+ */
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index 18a1baf..9ab6b6a 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -22,6 +22,8 @@
 typedef u64 cycle_t;
 struct clocksource;
 
+#include <asm/clocksource.h>
+
 /**
  * struct cyclecounter - hardware abstraction for a free running counter
  *	Provides completely state-free accessors to the underlying hardware.
@@ -153,7 +155,7 @@ extern u64 timecounter_cyc2time(struct timecounter *tc,
  * @shift:		cycle to nanosecond divisor (power of two)
  * @max_idle_ns:	max idle time permitted by the clocksource (nsecs)
  * @flags:		flags describing special properties
- * @vread:		vsyscall based read
+ * @archdata:		arch-specific data
  * @suspend:		suspend function for the clocksource, if necessary
  * @resume:		resume function for the clocksource, if necessary
  */
@@ -175,10 +177,14 @@ struct clocksource {
 #else
 #define CLKSRC_FSYS_MMIO_SET(mmio, addr)      do { } while (0)
 #endif
+
+#ifdef __ARCH_HAS_CLOCKSOURCE_DATA
+	struct arch_clocksource_data archdata;
+#endif
+
 	const char *name;
 	struct list_head list;
 	int rating;
-	cycle_t (*vread)(void);
 	int (*enable)(struct clocksource *cs);
 	void (*disable)(struct clocksource *cs);
 	unsigned long flags;
-- 
1.7.6

