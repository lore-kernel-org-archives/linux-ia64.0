From: Cliff Larsen <clarsen@egenera.com>
Date: Fri, 05 Nov 2004 13:55:43 +0000
Subject: [PATCH] make INIT# handler call panic
Message-Id: <1099662943.913.180.camel@clarsen>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-d3kbhc6daablpGk0QKsr"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-d3kbhc6daablpGk0QKsr
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is a small patch to enable a change of behavior when the INIT#
interrupt is received. By including a command line argument 
'ia64initpanic', the init_handler_platform will call panic. This 
is useful because the system is then connected to a call chain and 
machine restart. The call chain may invoke a netdump or diskdump 
routine. I think this would be useful for 2.6 as well.

Without the cmdline arg, the existing behavior is left unchanged
(printing task backtraces to the console and spinning forever).

The patch is off 2.4.27 
-- 
Cliff Larsen <clarsen@egenera.com>

--=-d3kbhc6daablpGk0QKsr
Content-Disposition: attachment; filename=init_handler_platform-2.4.27.patch
Content-Type: text/plain; name=init_handler_platform-2.4.27.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- linux-2.4.27.orig/Documentation/kernel-parameters.txt	2004-08-07 19:26:04.000000000 -0400
+++ linux-2.4.27/Documentation/kernel-parameters.txt	2004-11-04 15:45:46.000000000 -0500
@@ -251,6 +251,10 @@
 
 	i810=		[HW,DRM]
 
+	ia64initpanic	[IA-64,KNL] Causes INIT# handler to call panic()
+			which connects to a notifier list and
+			machine_restart rather than spinning forever.
+
 	ibmmcascsi=	[HW,MCA,SCSI] IBM MicroChannel SCSI adapter.
 
 	icn=		[HW,ISDN]
--- linux-2.4.27.orig/arch/ia64/kernel/mca.c	2004-04-14 09:05:26.000000000 -0400
+++ linux-2.4.27/arch/ia64/kernel/mca.c	2004-11-04 15:45:46.000000000 -0500
@@ -425,6 +425,15 @@
 	PUT_NAT_BIT(sw->caller_unat, &pt->r30);	PUT_NAT_BIT(sw->caller_unat, &pt->r31);
 }
 
+static int ia64initpanic = 0;
+static int __init ia64initpanic_setup(char *str)
+{
+	printk(KERN_INFO "ia64: panic on INIT# interrupt\n");
+	ia64initpanic = 1;
+	return 1;
+}
+__setup("ia64initpanic", ia64initpanic_setup);
+
 static void
 init_handler_platform (pal_min_state_area_t *ms,
 		       struct pt_regs *pt, struct switch_stack *sw)
@@ -434,6 +443,13 @@
 	/* if a kernel debugger is available call it here else just dump the registers */
 
 	/*
+	 * if ia64initpanic is present on the cmdline,
+	 * panic so that we get to notifier_call_chain and restart
+	 */
+	if (ia64initpanic)
+		panic("INIT# received by processor %d", smp_processor_id());
+
+	/*
 	 * Wait for a bit.  On some machines (e.g., HP's zx2000 and zx6000, INIT can be
 	 * generated via the BMC's command-line interface, but since the console is on the
 	 * same serial line, the user will need some time to switch out of the BMC before

--=-d3kbhc6daablpGk0QKsr--

