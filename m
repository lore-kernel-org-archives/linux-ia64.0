From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Tue, 05 Apr 2005 17:05:03 +0000
Subject: [Patch] Add config SCHED_SMT
Message-Id: <20050405100503.A17170@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Now that we have MC/MT detection patches in, appended patch allows us to
configure MT scheduler optimizations. For now, we will this option off
by default.

There is some discussion going on lkml about setting up sched-domains 
which are absolutely needed (like for example, we shouldn't setup SMT domain
for non MT processors). Once that patch goes in, we can enable this option by
default.

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>


diff -Nru linux-2.6.12-test/arch/ia64/Kconfig linux-2.6.12-test-mc/arch/ia64/Kconfig
--- linux-2.6.12-test/arch/ia64/Kconfig	2005-03-16 18:15:06.000000000 -0800
+++ linux-2.6.12-test-mc/arch/ia64/Kconfig	2005-04-05 09:52:31.000000000 -0700
@@ -260,6 +260,15 @@
 	  can be controlled through /sys/devices/system/cpu/cpu#.
 	  Say N if you want to disable CPU hotplug.
 
+config SCHED_SMT
+	bool "SMT scheduler support"
+	depends on SMP
+	default off
+	help
+	  Improves the CPU scheduler's decision making when dealing with 
+	  Intel IA64 chips with MultiThreading at a cost of slightly increased 
+	  overhead in some places. If unsure say N here.
+
 config PREEMPT
 	bool "Preemptible Kernel"
         help
