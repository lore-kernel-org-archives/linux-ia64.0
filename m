From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 14 Mar 2003 22:14:58 +0000
Subject: [Linux-ia64] [PATCH] Use PAL_HALT_LIGHT in cpu_idle
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------6053973235ABA58A875CA5E1"
Message-Id: <marc-linux-ia64-105590709806120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------6053973235ABA58A875CA5E1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Here's patches for 2.4 & 2.5 to use PAL_HALT_LIGHT in cpu_idle.
This helps to reduce CPU temp a little on boxes with firmware that
takes advantage of this lower power state.  I've tried this on a
rx2600 (2x900MHz McKinley) and an i2000 (fw 117) and it shows some
benefit.  On McKinley systems, only the very latest PAL from Intel
actually reduces power consumption in the halt_light state.  For
HP rx2600/zx6000/zx2000, this means you need to be running firmware
1.82.

  Rohit Seth, at Intel, has run some benchmarks with this kind of
modification and found the effects of enabling halt_light to fall
within the noise of mosts tests.  I replaced pal_halt(1) in safe_halt
with pal_halt_light() since halt_light is required to be implemented,
but pal_halt(1) is an optional halt state.  I'd be interested to hear
of any measurements anyone does using this, where it works/fails, and
if any benchmarks/applications are impacted.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab
--------------6053973235ABA58A875CA5E1
Content-Type: text/plain; charset=us-ascii;
 name="cpu_idle-2.4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cpu_idle-2.4.diff"

--- linux-2.4.20/Documentation/Configure.help~	Fri Mar 14 09:52:58 2003
+++ linux-2.4.20/Documentation/Configure.help	Fri Mar 14 09:53:50 2003
@@ -25479,6 +25479,14 @@
   Say Y here to enable machine check support for IA-64.  If you're
   unsure, answer Y.
 
+Use PAL_HALT_LIGHT in idle loop
+CONFIG_IA64_PAL_IDLE
+  Say Y here to enable use of PAL_HALT_LIGHT in the cpu_idle loop.
+  This allows the CPU to enter a low power state when idle.  You
+  can enable CONFIG_IA64_PALINFO and check /proc/pal/cpu0/power_info
+  to see the power consumption and latency for this state.  If you're
+  unsure your firmware supports it, answer N.
+
 Disable IA-64 Virtual Hash Page Table
 CONFIG_DISABLE_VHPT
   The Virtual Hash Page Table (VHPT) enhances virtual address
--- linux-2.4.20/arch/ia64/config.in~	Fri Mar 14 09:53:08 2003
+++ linux-2.4.20/arch/ia64/config.in	Fri Mar 14 11:00:36 2003
@@ -86,6 +86,7 @@
 
 define_bool CONFIG_KCORE_ELF y	# On IA-64, we always want an ELF /proc/kcore.
 
+bool 'Use PAL_HALT_LIGHT in idle loop' CONFIG_IA64_PAL_IDLE
 bool 'SMP support' CONFIG_SMP
 tristate 'Support running of Linux/x86 binaries' CONFIG_IA32_SUPPORT
 bool 'Performance monitor support' CONFIG_PERFMON
--- linux-2.4.20/arch/ia64/kernel/process.c~	Fri Mar 14 09:53:16 2003
+++ linux-2.4.20/arch/ia64/kernel/process.c	Fri Mar 14 14:49:02 2003
@@ -122,6 +122,15 @@
 		show_stack(0);
 }
 
+static void
+default_idle(void)
+{
+#ifdef CONFIG_IA64_PAL_IDLE
+	if (!current->need_resched)
+		safe_halt();
+#endif
+}
+
 void __attribute__((noreturn))
 cpu_idle (void *unused)
 {
@@ -132,6 +141,10 @@
 
 
 	while (1) {
+		void (*idle)(void) = pm_idle;
+		if (!idle)
+			idle = default_idle;
+
 #ifdef CONFIG_SMP
 		if (!current->need_resched)
 			min_xtp();
@@ -141,7 +154,7 @@
 #ifdef CONFIG_IA64_SGI_SN
 			snidle();
 #endif
-			continue;
+			idle();
 		}
 
 #ifdef CONFIG_IA64_SGI_SN
@@ -153,8 +166,6 @@
 #endif
 		schedule();
 		check_pgt_cache();
-		if (pm_idle)
-			(*pm_idle)();
 	}
 }
 
--- linux-2.4.20/include/asm-ia64/system.h~	Fri Mar 14 09:55:42 2003
+++ linux-2.4.20/include/asm-ia64/system.h	Fri Mar 14 10:11:01 2003
@@ -104,7 +104,7 @@
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
 #define set_wmb(var, value)	do { (var) = (value); mb(); } while (0)
 
-#define safe_halt()         ia64_pal_halt(1)                /* PAL_HALT */
+#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
 
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure

--------------6053973235ABA58A875CA5E1
Content-Type: text/plain; charset=us-ascii;
 name="cpu_idle-2.5.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cpu_idle-2.5.diff"

--- linux-2.5.64/arch/ia64/Kconfig~	Fri Mar 14 14:18:38 2003
+++ linux-2.5.64/arch/ia64/Kconfig	Fri Mar 14 14:55:58 2003
@@ -405,6 +405,15 @@
 
 endchoice
 
+config IA64_PAL_IDLE
+	bool "Use PAL_HALT_LIGHT in idle loop"
+	---help---
+	  Say Y here to enable use of PAL_HALT_LIGHT in the cpu_idle loop.
+	  This allows the CPU to enter a low power state when idle.  You
+	  can enable CONFIG_IA64_PALINFO and check /proc/pal/cpu0/power_info
+	  to see the power consumption and latency for this state.  If you're
+	  unsure your firmware supports it, answer N.
+
 config SMP
 	bool "SMP support"
 	---help---
--- linux-2.5.64/arch/ia64/kernel/process.c~	Fri Mar 14 14:25:24 2003
+++ linux-2.5.64/arch/ia64/kernel/process.c	Fri Mar 14 14:46:17 2003
@@ -169,7 +169,10 @@
 void
 default_idle (void)
 {
-	/* may want to do PAL_LIGHT_HALT here... */
+#ifdef CONFIG_IA64_PAL_IDLE
+	if (!need_resched())
+		safe_halt();
+#endif
 }
 
 void __attribute__((noreturn))
@@ -177,6 +180,10 @@
 {
 	/* endless idle loop with no priority at all */
 	while (1) {
+		void (*idle)(void) = pm_idle;
+		if (!idle)
+			idle = default_idle;
+
 #ifdef CONFIG_SMP
 		if (!need_resched())
 			min_xtp();
@@ -186,10 +193,7 @@
 #ifdef CONFIG_IA64_SGI_SN
 			snidle();
 #endif
-			if (pm_idle)
-				(*pm_idle)();
-			else
-				default_idle();
+			idle();
 		}
 
 #ifdef CONFIG_IA64_SGI_SN
--- linux-2.5.64/include/asm-ia64/system.h~	Fri Mar 14 10:55:23 2003
+++ linux-2.5.64/include/asm-ia64/system.h	Fri Mar 14 10:55:51 2003
@@ -108,7 +108,7 @@
 #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
 #define set_wmb(var, value)	do { (var) = (value); mb(); } while (0)
 
-#define safe_halt()         ia64_pal_halt(1)                /* PAL_HALT */
+#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
 
 /*
  * The group barrier in front of the rsm & ssm are necessary to ensure

--------------6053973235ABA58A875CA5E1--


