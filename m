From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 22:00:47 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
 <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> I'd bet resonable sums of money that we are (once again) accessing
> per-cpu variables in code before ia64 has a chance to initialize
> things so that they can actually work. :-(

I tried this simple hack to check ... per-cpu variables are
not usable until cpu_init() sets up the "ar.k3" register on
ia64.  So this hack checks to see if it is set before calling
cpu_clock():

--- a/kernel/printk.c   2008-08-01 10:20:47.000000000 -0700
+++ b/kernel/printk.c   2008-08-04 14:49:18.000000000 -0700
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>

 #include <asm/uaccess.h>
+#include <asm/kregs.h>

 /*
  * Architectures can override it:
@@ -737,7 +738,10 @@
                                unsigned long long t;
                                unsigned long nanosec_rem;

-                               t = cpu_clock(printk_cpu);
+                               if (ia64_get_kr(IA64_KR_PER_CPU_DATA))
+                                       t = cpu_clock(printk_cpu);
+                               else
+                                       t = 0;
                                nanosec_rem = do_div(t, 1000000000);
                                tlen = sprintf(tbuf, "[%5lu.%06lu] ",
                                                (unsigned long) t,

With this hack the kernel boots (with CONFIG_PRINTK_TIME=y).

This is effectively how the code used to operate before the architecture
hooks were cleaned away by:

commit b842271fbb9c8b5fd0e1c3e1895a3b67ba5bcc54
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Jan 25 21:07:59 2008 +0100

    sched: remove printk_clock()

    printk_clock() is obsolete - it has been replaced with cpu_clock().

-Tony
