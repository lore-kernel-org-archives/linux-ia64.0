From: Jeremy Higdon <jeremy@sgi.com>
Date: Fri, 19 Mar 2004 01:46:50 +0000
Subject: [PATCH] make level sensitive interrupt emulation default on SN2
Message-Id: <20040319014650.GA659788@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To simulate level-triggered interrupts on SN2, we need the
forced interrupt to be on by default.  Most PCI cards don't
need this, but the sata_vsc driver does.

thanks

jeremy

--- 2.6-devel/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-03-17 20:32:07.000000000 -0800
+++ linux-2.6.4/arch/ia64/sn/kernel/sn2/sn_proc_fs.c	2004-03-17 19:13:51.000000000 -0800
@@ -73,8 +73,13 @@
 	}
 }
 
-// Disable forced interrupts, but leave the code in, just in case.
-int sn_force_interrupt_flag = 0;
+/*
+ * Enable forced interrupt by default.
+ * When set, the sn interrupt handler writes the force interrupt register on
+ * the bridge chip.  The hardware will then send an interrupt message if the
+ * interrupt line is active.  This mimics a level sensitive interrupt.
+ */
+int sn_force_interrupt_flag = 1;
 
 static int
 sn_force_interrupt_read_proc(char *page, char **start, off_t off,
