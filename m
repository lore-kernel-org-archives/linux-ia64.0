From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:32 +0000
Subject: [PATCH 13/35] cpumask: use setup_nr_cpu_ids() instead of direct assignment.
Message-Id: <20081020170321.397462000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

nr_cpu_ids is going to become a constant under some configs, so don't
assign it.  Currently only x86 seems to anyway.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/smpboot.c |    4 ++--
 include/linux/cpumask.h   |    4 ++++
 init/main.c               |    4 ++--
 3 files changed, 8 insertions(+), 4 deletions(-)

--- linux-2.6.28.orig/arch/x86/kernel/smpboot.c
+++ linux-2.6.28/arch/x86/kernel/smpboot.c
@@ -1079,7 +1079,7 @@ static int __init smp_sanity_check(unsig
 			nr++;
 		}
 
-		nr_cpu_ids = 8;
+		setup_nr_cpu_ids();
 	}
 #endif
 
@@ -1296,7 +1296,7 @@ __init void prefill_possible_map(void)
 	for (i = 0; i < possible; i++)
 		cpu_set(i, cpu_possible_map);
 
-	nr_cpu_ids = possible;
+	setup_nr_cpu_ids();
 }
 
 #ifdef CONFIG_HOTPLUG_CPU
--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -144,6 +144,7 @@
 #include <linux/kernel.h>
 #include <linux/threads.h>
 #include <linux/bitmap.h>
+#include <linux/init.h>
 
 struct cpumask
 {
@@ -636,4 +637,7 @@ extern cpumask_t cpu_active_map;
 #define for_each_online_cpu(cpu)   for_each_cpu_mask_nr((cpu), cpu_online_map)
 #define for_each_present_cpu(cpu)  for_each_cpu_mask_nr((cpu), cpu_present_map)
 
+/* Arch-specific code may call this to initialize nr_cpu_ids based on
+ * the cpu_possible_map. */
+void __init setup_nr_cpu_ids(void);
 #endif /* __LINUX_CPUMASK_H */
--- linux-2.6.28.orig/init/main.c
+++ linux-2.6.28/init/main.c
@@ -362,7 +362,7 @@ static void __init smp_init(void)
 #endif
 
 static inline void setup_per_cpu_areas(void) { }
-static inline void setup_nr_cpu_ids(void) { }
+void __init setup_nr_cpu_ids(void) { }
 static inline void smp_prepare_cpus(unsigned int maxcpus) { }
 
 #else
@@ -377,7 +377,7 @@ int nr_cpu_ids __read_mostly = NR_CPUS;
 EXPORT_SYMBOL(nr_cpu_ids);
 
 /* An arch may set nr_cpu_ids earlier if needed, so this would be redundant */
-static void __init setup_nr_cpu_ids(void)
+void __init setup_nr_cpu_ids(void)
 {
 	int cpu, highest_cpu = 0;
 

-- 
