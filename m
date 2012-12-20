From: <Vineet.Gupta1@synopsys.com>
Date: Thu, 20 Dec 2012 11:23:38 +0000
Subject: [PATCH] sysctl: convert arch specific unaligned access regulators to generic ones
Message-Id: <1356001898-2960-2-git-send-email-vgupta@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50D2B75A.3000208@synopsys.com>
 <1356001898-2960-1-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1356001898-2960-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serge.hallyn@canonical.com>, "David S. Miller" <davem@davemloft.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org

From: Vineet Gupta <vgupta@synopsys.com>

* parisc: /proc/sys/kernel/unaligned-trap => SYSCTL_ARCH_UNALIGN_ALLOW

* ia64: /proc/sys/kernel/ignore-unaligned-usertrap =>
					SYSCTL_ARCH_UNALIGN_NO_WARN

This allows other architectures, specifically ARC to reuse these sysctl
knobs.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/ia64/Kconfig   |    1 +
 arch/parisc/Kconfig |    1 +
 init/Kconfig        |   16 ++++++++++++++++
 kernel/sysctl.c     |   16 +++++++++++++---
 4 files changed, 31 insertions(+), 3 deletions(-)

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
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 11def45..7d9de54 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -20,6 +20,7 @@ config PARISC
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_STRNCPY_FROM_USER
+	select SYSCTL_ARCH_UNALIGN_ALLOW
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 
diff --git a/init/Kconfig b/init/Kconfig
index 6fdd6e3..de4b184 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1169,6 +1169,22 @@ config SYSCTL_EXCEPTION_TRACE
 	help
 	  Enable support for /proc/sys/debug/exception-trace.
 
+config SYSCTL_ARCH_UNALIGN_NO_WARN
+	bool
+	help
+	  Enable support for /proc/sys/kernel/ignore-unaligned-usertrap
+	  Allows arch to define/use @no_unaligned_warning to possbly warn about
+	  unaligned access emulation going on under the hood.
+	  see arch/ia64/kernel/unaligned.c for reference
+
+config SYSCTL_ARCH_UNALIGN_ALLOW
+	bool
+	help
+	  Enable support for /proc/sys/kernel/unaligned-trap
+	  Allows arches to define/use @unaligned_enabled to runtime toggle
+	  the unaligned access emulation.
+	  see arch/parisc/kernel/unaligned.c for reference
+
 config KALLSYMS
 	 bool "Load all symbols for debugging/ksymoops" if EXPERT
 	 default y
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 26f65ea..9c618bf 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -157,14 +157,20 @@ extern int sysctl_tsb_ratio;
 
 #ifdef __hppa__
 extern int pwrsw_enabled;
-extern int unaligned_enabled;
 #endif
 
 #ifdef CONFIG_IA64
-extern int no_unaligned_warning;
 extern int unaligned_dump_stack;
 #endif
 
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_ALLOW
+extern int unaligned_enabled;
+#endif
+
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN
+extern int no_unaligned_warning;
+#endif
+
 #ifdef CONFIG_PROC_SYSCTL
 static int proc_do_cad_pid(struct ctl_table *table, int write,
 		  void __user *buffer, size_t *lenp, loff_t *ppos);
@@ -504,6 +510,8 @@ static struct ctl_table kern_table[] = {
 	 	.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+#endif
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_ALLOW
 	{
 		.procname	= "unaligned-trap",
 		.data		= &unaligned_enabled,
@@ -870,7 +878,7 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= proc_doulongvec_minmax,
 	},
 #endif
-#ifdef CONFIG_IA64
+#ifdef CONFIG_SYSCTL_ARCH_UNALIGN_NO_WARN
 	{
 		.procname	= "ignore-unaligned-usertrap",
 		.data		= &no_unaligned_warning,
@@ -878,6 +886,8 @@ static struct ctl_table kern_table[] = {
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

