From: Martin Hicks <mort@bork.org>
Date: Wed, 04 Feb 2004 15:28:41 +0000
Subject: [PATCH] turn off irqdebug by default on Altix
Message-Id: <20040204152841.GB3387@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hello,

A while ago there was a discussion, started by Jack Steiner, about a hot
cache line in the irqdebug code that makes booting on large machines
very slow.  The original thread can be found here:

http://marc.theaimsgroup.com/?l=linux-kernel&m=106858073229831&w=2

The end result was that it was felt that irqdebug sould remain on by
default on small machines, and that large machines should turn it off be
default if it was causing a problem.

Here is a patch that turns it off for sn2.  It applies cleanly against
the linux-2.5 bk tree from this morning.
mh

-- 
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sn2-irqdebug-off.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1597  -> 1.1598 
#	arch/ia64/sn/kernel/setup.c	1.28    -> 1.29   
#	arch/ia64/kernel/irq.c	1.34    -> 1.35   
#	Documentation/kernel-parameters.txt	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/26	mort@tomahawk.engr.sgi.com	1.1598
# Turn off irqdebug by default on sn2.  Add an "irqdebug" command line
# option so it can be turned back on easily if required.
# --------------------------------------------
#
diff -Nru a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
--- a/Documentation/kernel-parameters.txt	Mon Jan 26 11:51:45 2004
+++ b/Documentation/kernel-parameters.txt	Mon Jan 26 11:51:45 2004
@@ -642,8 +642,13 @@
 			instruction doesn't work correctly and not to
 			use it.
 
-	noirqdebug	[IA-32] Disables the code which attempts to detect and
-			disable unhandled interrupt sources.
+	noirqdebug	[IA-32, IA-64] Disables the code which attempts to detect
+			and disable unhandled interrupt sources.  irqdebug is
+			on by default for all except ia64-sn2.
+
+	irqdebug	[IA-64] This turns on the code which attempts to detect
+			and diable unhandled interrupt sources.	 It is required
+			because the ia64-sn2 platform disables irqdebug by default.
 
 	noisapnp	[ISAPNP] Disables ISA PnP code.
 
diff -Nru a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
--- a/arch/ia64/kernel/irq.c	Mon Jan 26 11:51:45 2004
+++ b/arch/ia64/kernel/irq.c	Mon Jan 26 11:51:45 2004
@@ -288,7 +288,7 @@
 	}
 }
 
-static int noirqdebug;
+int noirqdebug;
 
 static int __init noirqdebug_setup(char *str)
 {
@@ -297,7 +297,15 @@
 	return 1;
 }
 
+static int __init irqdebug_setup(char *str)
+{
+	noirqdebug = 0;
+	printk("IRQ lockup detection enabled\n");
+	return 1;
+}
+
 __setup("noirqdebug", noirqdebug_setup);
+__setup("irqdebug", irqdebug_setup);
 
 /*
  * If 99,900 of the previous 100,000 interrupts have not been handled then
diff -Nru a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
--- a/arch/ia64/sn/kernel/setup.c	Mon Jan 26 11:51:45 2004
+++ b/arch/ia64/sn/kernel/setup.c	Mon Jan 26 11:51:45 2004
@@ -61,6 +61,7 @@
 extern void init_platform_hubinfo(nodepda_t **nodepdaindr);
 extern void (*ia64_mark_idle)(int);
 extern void snidle(int);
+extern int noirqdebug;
 
 unsigned long sn_rtc_cycles_per_second;   
 
@@ -265,6 +266,11 @@
 		printk(KERN_DEBUG "sn_setup: setting master_node_bedrock_address to 0x%lx\n",
 		       master_node_bedrock_address);
 	}
+
+	/*
+	 * Turn off irqdebug by default on sn
+	 */
+	noirqdebug = 1;
 
 	/*
 	 * we set the default root device to /dev/hda

--bg08WKrSYDhXBjb5--
