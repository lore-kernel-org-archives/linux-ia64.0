From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Wed, 09 Jan 2013 14:48:28 +0000
Subject: [PATCH v2] sysctl: Enable IA64 "ignore-unaligned-usertrap" to be used cross-arch
Message-Id: <1357742188-8941-1-git-send-email-vgupta@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50ED7B4B.7080603@synopsys.com>
In-Reply-To: <50ED7B4B.7080603@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Fenghua Yu <fenghua.yu@intel.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

IA64 defines /proc/sys/kernel/ignore-unaligned-usertrap to control
verbose warnings on unaligned access emulation.

The exact mechanics of what to do with sysctl (ignore/shout) are arch
specific, this change enables the sysctl to be usable cross-arch.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org
---
 arch/ia64/Kconfig |    1 +
 init/Kconfig      |    7 +++++++
 kernel/sysctl.c   |    9 +++++++--
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3279646..5fb1064 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -40,6 +40,7 @@ config IA64
 	select ARCH_THREAD_INFO_ALLOCATOR
 	select ARCH_CLOCKSOURCE_DATA
 	select GENERIC_TIME_VSYSCALL_OLD
+	select SYSCTL_ARCH_UNALIGN_NO_WARN
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	default y
diff --git a/init/Kconfig b/init/Kconfig
index 7d30240..523bee1 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1232,6 +1232,13 @@ config SYSCTL_EXCEPTION_TRACE
 	help
 	  Enable support for /proc/sys/debug/exception-trace.
 
+config SYSCTL_ARCH_UNALIGN_NO_WARN
+	bool
+	help
+	  Enable support for /proc/sys/kernel/ignore-unaligned-usertrap
+	  Allows arch to define/use @no_unaligned_warning to possibly warn
+	  about unaligned access emulation going on under the hood.
+
 config KALLSYMS
 	 bool "Load all symbols for debugging/ksymoops" if EXPERT
 	 default y
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c88878d..840fd5e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -161,10 +161,13 @@ extern int unaligned_enabled;
 #endif
 
 #ifdef CONFIG_IA64
-extern int no_unaligned_warning;
 extern int unaligned_dump_stack;
 #endif
 
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN
+extern int no_unaligned_warning;
+#endif
+
 #ifdef CONFIG_PROC_SYSCTL
 static int proc_do_cad_pid(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -911,7 +914,7 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_doulongvec_minmax,
 	},
 #endif
-#ifdef CONFIG_IA64
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN
 	{
 		.procname	= "ignore-unaligned-usertrap",
 		.data		= &no_unaligned_warning,
@@ -919,6 +922,8 @@ static struct ctl_table kern_table[] = {
 	 	.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#endif
+#ifdef CONFIG_IA64
 	{
 		.procname	= "unaligned-dump-stack",
 		.data		= &unaligned_dump_stack,
-- 
1.7.4.1

