From: Bill Nottingham <notting@redhat.com>
Date: Thu, 29 Mar 2001 02:15:19 +0000
Subject: [Linux-ia64] bad prototype for show_stack (arch/ia64/kernel/irq.c)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Message-Id: <marc-linux-ia64-105590693005366@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

It's never actually called with anything other than NULL,
AFAICT, but it still should probably match.

Bill

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.2-show_stack.patch"

--- linux/arch/ia64/kernel/irq.c.foo	Wed Mar 28 21:08:20 2001
+++ linux/arch/ia64/kernel/irq.c	Wed Mar 28 21:10:59 2001
@@ -185,7 +185,7 @@
 unsigned int global_irq_holder = NO_PROC_ID;
 volatile unsigned long global_irq_lock; /* long for set_bit --RR */
 
-extern void show_stack(unsigned long* esp);
+extern void show_stack(struct task_struct *task);
 
 static void show(char * str)
 {

--UlVJffcvxoiEqYs2--

