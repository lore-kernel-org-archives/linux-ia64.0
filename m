From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 08 Aug 2003 03:04:29 +0000
Subject: hardirq.h should include smp_lock.h when preempt enabled
MIME-Version: 1
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Message-Id: <marc-linux-ia64-106031197330473@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

As in_atomic() uses kernel_locked() which is in smp_lock.h

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hardirq.h.patch"

===== hardirq.h 1.13 vs edited =====
--- 1.13/include/asm-ia64/hardirq.h	Thu Jun 12 12:53:38 2003
+++ edited/hardirq.h	Fri Aug  8 13:00:23 2003
@@ -89,6 +89,7 @@
 #define irq_enter()		(preempt_count() += HARDIRQ_OFFSET)
 
 #ifdef CONFIG_PREEMPT
+# include <linux/smp_lock.h>
 # define in_atomic()		((preempt_count() & ~PREEMPT_ACTIVE) != kernel_locked())
 # define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else

--VbJkn9YxBvnuCH5J--
