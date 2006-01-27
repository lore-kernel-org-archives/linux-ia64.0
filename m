From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 02:09:48 +0000
Subject: [patch] turn on config_smt in defconfig
Message-Id: <200601270209.k0R29ng21629@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that the scheduler domain degeneration patch from
Suresh Siddha was merged in the main line kernel for a
while, it is safe to turn on CONFIG_SMT broadly.  It has
zero run time cost on system that doesn't have SMT because
the SD degenerator will collapse needless domains.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
cc: Suresh Siddha <suresh.b.siddha@intel.com>

--- ./arch/ia64/defconfig.orig	2006-01-26 18:40:54.579699555 -0800
+++ ./arch/ia64/defconfig	2006-01-26 18:46:31.865828235 -0800
@@ -100,7 +100,7 @@ CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
 CONFIG_HOTPLUG_CPU=y
-# CONFIG_SCHED_SMT is not set
+CONFIG_SCHED_SMT=y
 # CONFIG_PREEMPT is not set
 CONFIG_SELECT_MEMORY_MODEL=y
 # CONFIG_FLATMEM_MANUAL is not set
--- ./arch/ia64/Kconfig.orig	2006-01-26 18:41:09.734972806 -0800
+++ ./arch/ia64/Kconfig	2006-01-26 18:43:35.204697587 -0800
@@ -266,7 +266,7 @@ config HOTPLUG_CPU
 config SCHED_SMT
 	bool "SMT scheduler support"
 	depends on SMP
-	default off
+	default y
 	help
 	  Improves the CPU scheduler's decision making when dealing with
 	  Intel IA64 chips with MultiThreading at a cost of slightly increased


