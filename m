From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 14 Nov 2002 04:41:38 +0000
Subject: [Linux-ia64] Debugging early ode under the simulator
Message-Id: <marc-linux-ia64-105590709805418@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
	There's no easy way to set breakpoints or watchpoints in the
kernel before the kernel starts running, when running under the SKI
simulator.

One way to fix this is appended.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.814   -> 1.815  
#	arch/ia64/boot/bootloader.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/11/14	peterc@gelato.unsw.edu.au	1.815
# Add a debug breakpoint dummy function.
# 
# When in the simulator, one cannot set a break point or watchpoint 
# before the symbol table for the kernel is in memory, 
# and the kernel has set things up to run in a virtual addrs space.
# 
# Therefore, insert a dummy function here that one can set a breakpoint
# on, then single step a  few dozen times, then set up the 
# breakpoints one really wants.
# --------------------------------------------
#
diff -Nru a/arch/ia64/boot/bootloader.c b/arch/ia64/boot/bootloader.c
--- a/arch/ia64/boot/bootloader.c	Thu Nov 14 15:36:29 2002
+++ b/arch/ia64/boot/bootloader.c	Thu Nov 14 15:36:29 2002
@@ -53,6 +53,14 @@
 
 #include "../kernel/fw-emu.c"
 
+/*
+ * Set a break point on this function so that
+ * symbols are available to set breakpoints in the 
+ * kernel being debugged.
+ */
+void debug_break(void) {
+}
+
 static void
 cons_write (const char *buf)
 {
@@ -187,6 +195,7 @@
 
 	ssc(0, (long) kpath, 0, 0, SSC_LOAD_SYMBOLS);
 
+	debug_break();
 	asm volatile ("mov sp=%2; mov r28=%1; br.sptk.few %0"
 		      :: "b"(e_entry), "r"(bp), "r"(__pa(&stack)));
 


--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

