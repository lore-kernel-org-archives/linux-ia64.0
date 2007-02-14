From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Feb 2007 07:15:02 +0000
Subject: [PATCH] [IA64] kexec: grammatical fixes for crash.c
Message-Id: <20070214071502.GA16615@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grammatical fixes for crash.c

Signed-off-by: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/crash.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

Index: linux-2.6/arch/ia64/kernel/crash.c
=================================--- linux-2.6.orig/arch/ia64/kernel/crash.c	2006-12-20 11:03:10.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/crash.c	2006-12-21 10:07:54.000000000 +0900
@@ -21,9 +21,9 @@
 #include <asm/mca.h>
 
 int kdump_status[NR_CPUS];
-atomic_t kdump_cpu_freezed;
+static atomic_t kdump_cpu_frozen;
 atomic_t kdump_in_progress;
-int kdump_on_init = 1;
+static int kdump_on_init = 1;
 
 static inline Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
@@ -85,7 +85,7 @@
 	int cpu_num = num_online_cpus() - 1;
 	int timeout = 1000;
 	while(timeout-- > 0) {
-		if (atomic_read(&kdump_cpu_freezed) = cpu_num)
+		if (atomic_read(&kdump_cpu_frozen) = cpu_num)
 			return 0;
 		udelay(1000);
 	}
@@ -106,10 +106,9 @@
 	kexec_disable_iosapic();
 #ifdef CONFIG_SMP
 	kdump_smp_send_stop();
-	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
-		//not all cpu response to IPI, send INIT to freeze them
+	/* Not all CPUs respond to IPI, so use INIT to freeze them */
+	if (kdump_wait_cpu_freeze() && kdump_on_init)
 		kdump_smp_send_init();
-	}
 #endif
 }
 
@@ -129,7 +128,7 @@
 	cpuid = smp_processor_id();
 	crash_save_this_cpu();
 	current->thread.ksp = (__u64)info->sw - 16;
-	atomic_inc(&kdump_cpu_freezed);
+	atomic_inc(&kdump_cpu_frozen);
 	kdump_status[cpuid] = 1;
 	mb();
 	if (cpuid = 0) {
