From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Wed, 14 Jan 2004 10:44:43 +0000
Subject: Yet another MCA handler - testing
Message-Id: <40051D9B.869DA5CB@nospam.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------3811A5B55E424FEFD124323F"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------3811A5B55E424FEFD124323F
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Having applied the patch included, you can provoke a single MCA by
setting the variable "test_mca_tr" to non zero.
You can repeat the test by setting this variable again...

Zoltan Menyhart
--------------3811A5B55E424FEFD124323F
Content-Type: text/plain; charset=us-ascii;
 name="mca.test.patch"
Content-Disposition: inline;
 filename="mca.test.patch"
Content-Transfer-Encoding: 7bit

diff -ruN linux-2.6.1/kernel/sched.c linux-2.6.1-jan-14/kernel/sched.c
--- linux-2.6.1/kernel/sched.c	2004-01-13 12:55:50.000000000 +0100
+++ linux-2.6.1-jan-14/kernel/sched.c	2004-01-12 18:46:16.000000000 +0100
@@ -1,3 +1,11 @@
+#define _TEST_
+
+#if defined(_TEST_)
+#include <asm/mca_state.h>
+int test_mca_tr;
+
+#endif
+
 /*
  *  kernel/sched.c
  *
@@ -1467,6 +1475,18 @@
 
 void scheduling_functions_start_here(void) { }
 
+#if defined(_TEST_)
+
+void
+ia64_itr_test(__u64 target_mask, __u64 tr_num, __u64 vmaddr, __u64 pte, __u64 log_page_size){
+	ia64_setreg(_IA64_REG_CR_ITIR, (log_page_size << 2));
+	ia64_setreg(_IA64_REG_CR_IFA, vmaddr);
+	ia64_stop();
+	ia64_itrd(tr_num, pte);
+}
+
+#endif
+
 /*
  * schedule() is the main scheduler function.
  */
@@ -1481,6 +1501,19 @@
 	unsigned long run_time;
 	int idx;
 
+#if defined(_TEST_)
+        if (test_mca_tr != 0){
+		test_mca_tr = 0;
+		printk("Messing up DTR5...\n");
+                __u64 psr = ia64_clear_ic();
+ 		ia64_itr_test(DATA_TRANSLATION,
+				/* DTR5 */ 5,
+				PERCPU_ADDR,
+				pte_val(pfn_pte(ia64_tpa(local_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
+				PERCPU_PAGE_SHIFT);
+		ia64_set_psr(psr);
+        }
+#endif
 	/*
 	 * Test if we are atomic.  Since do_exit() needs to call into
 	 * schedule() atomically, we ignore that path for now.

--------------3811A5B55E424FEFD124323F--

