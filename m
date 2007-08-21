From: Peter Chubb <peterc@chubb.wattle.id.au>
Date: Tue, 21 Aug 2007 03:51:45 +0000
Subject: Re: Enable early console for Ski simulator
Message-Id: <87tzqtk0j2.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
In-Reply-To: <87tzr0kr5g.wl%peterc@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch cleans up the `enable early console for SKI' patch, and
1. potentially allows the gensparse_defconfig to work again.
   (there are other problems running a generic kernel on Ski)
2. fixes the `console registered twice' problem. 
3. Cleans up the code by moving the `extern hpsim_cons' declaration to
   a new asm/hpsim.h file.


Thanks to Jes for comments.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

 arch/ia64/hp/sim/hpsim_console.c |   15 ++++++++++++++-
 arch/ia64/hp/sim/hpsim_setup.c   |    9 ++-------
 arch/ia64/kernel/setup.c         |    8 ++------
 include/asm-ia64/hpsim.h         |   10 ++++++++++
 4 files changed, 28 insertions(+), 14 deletions(-)

Index: linux-2.6-git/arch/ia64/hp/sim/hpsim_console.c
=================================--- linux-2.6-git.orig/arch/ia64/hp/sim/hpsim_console.c	2007-08-21 13:04:47.000000000 +1000
+++ linux-2.6-git/arch/ia64/hp/sim/hpsim_console.c	2007-08-21 13:04:52.000000000 +1000
@@ -14,28 +14,29 @@
 #include <linux/tty.h>
 #include <linux/kdev_t.h>
 #include <linux/console.h>
 
 #include <asm/delay.h>
 #include <asm/irq.h>
 #include <asm/pal.h>
 #include <asm/machvec.h>
 #include <asm/pgtable.h>
 #include <asm/sal.h>
+#include <asm/hpsim.h>
 
 #include "hpsim_ssc.h"
 
 static int simcons_init (struct console *, char *);
 static void simcons_write (struct console *, const char *, unsigned);
 static struct tty_driver *simcons_console_device (struct console *, int *);
 
-struct console hpsim_cons = {
+static struct console hpsim_cons = {
 	.name =		"simcons",
 	.write =	simcons_write,
 	.device =	simcons_console_device,
 	.setup =	simcons_init,
 	.flags =	CON_PRINTBUFFER,
 	.index =	-1,
 };
 
 static int
 simcons_init (struct console *cons, char *options)
@@ -55,10 +56,22 @@ simcons_write (struct console *cons, con
 		  ia64_ssc('\r', 0, 0, 0, SSC_PUTCHAR);
 	}
 }
 
 static struct tty_driver *simcons_console_device (struct console *c, int *index)
 {
 	extern struct tty_driver *hp_simserial_driver;
 	*index = c->index;
 	return hp_simserial_driver;
 }
+
+int simcons_register(void)
+{
+	if (!ia64_platform_is("hpsim"))
+		return 1;
+
+	if (hpsim_cons.flags & CON_ENABLED)
+		return 1;
+
+	register_console(&hpsim_cons);
+	return 0;
+}
Index: linux-2.6-git/arch/ia64/hp/sim/hpsim_setup.c
=================================--- linux-2.6-git.orig/arch/ia64/hp/sim/hpsim_setup.c	2007-08-21 13:04:47.000000000 +1000
+++ linux-2.6-git/arch/ia64/hp/sim/hpsim_setup.c	2007-08-21 13:04:52.000000000 +1000
@@ -14,38 +14,33 @@
 #include <linux/root_dev.h>
 #include <linux/string.h>
 #include <linux/types.h>
 
 #include <asm/delay.h>
 #include <asm/irq.h>
 #include <asm/pal.h>
 #include <asm/machvec.h>
 #include <asm/pgtable.h>
 #include <asm/sal.h>
+#include <asm/hpsim.h>
 
 #include "hpsim_ssc.h"
 
 void
 ia64_ssc_connect_irq (long intr, long irq)
 {
 	ia64_ssc(intr, irq, 0, 0, SSC_CONNECT_INTERRUPT);
 }
 
 void
 ia64_ctl_trace (long on)
 {
 	ia64_ssc(on, 0, 0, 0, SSC_CTL_TRACE);
 }
 
 void __init
 hpsim_setup (char **cmdline_p)
 {
 	ROOT_DEV = Root_SDA1;		/* default to first SCSI drive */
 
-#ifdef CONFIG_HP_SIMSERIAL_CONSOLE
-	{
-		extern struct console hpsim_cons;
-		if (ia64_platform_is("hpsim"))
-			register_console(&hpsim_cons);
-	}
-#endif
+	simcons_register();
 }
Index: linux-2.6-git/include/asm-ia64/hpsim.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-git/include/asm-ia64/hpsim.h	2007-08-21 13:04:52.000000000 +1000
@@ -0,0 +1,10 @@
+#ifndef _ASMIA64_HPSIM_H
+#define _ASMIA64_HPSIM_H
+
+#ifndef CONFIG_HP_SIMSERIAL_CONSOLE
+static inline int simcons_register(void) { return 1; }
+#else
+int simcons_register(void);
+#endif
+
+#endif
Index: linux-2.6-git/arch/ia64/kernel/setup.c
=================================--- linux-2.6-git.orig/arch/ia64/kernel/setup.c	2007-08-21 13:13:46.000000000 +1000
+++ linux-2.6-git/arch/ia64/kernel/setup.c	2007-08-21 13:15:19.000000000 +1000
@@ -53,20 +53,21 @@
 #include <asm/page.h>
 #include <asm/patch.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
 #include <asm/setup.h>
 #include <asm/smp.h>
 #include <asm/system.h>
 #include <asm/unistd.h>
+#include <asm/hpsim.h>
 
 #if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
 # error "struct cpuinfo_ia64 too big!"
 #endif
 
 #ifdef CONFIG_SMP
 unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
 
@@ -382,27 +383,22 @@ early_console_setup (char *cmdline)
 	{
 		extern int sn_serial_console_early_setup(void);
 		if (!sn_serial_console_early_setup())
 			earlycons++;
 	}
 #endif
 #ifdef CONFIG_EFI_PCDP
 	if (!efi_setup_pcdp_console(cmdline))
 		earlycons++;
 #endif
-#ifdef CONFIG_HP_SIMSERIAL_CONSOLE
-	{
-		extern struct console hpsim_cons;
-		register_console(&hpsim_cons);
+	if (!simcons_register())
 		earlycons++;
-	}
-#endif
 
 	return (earlycons) ? 0 : -1;
 }
 
 static inline void
 mark_bsp_online (void)
 {
 #ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
 	cpu_set(smp_processor_id(), cpu_online_map);
