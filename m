From: Erich Focht <efocht@ess.nec.de>
Date: Thu, 22 Nov 2001 10:29:05 +0000
Subject: [Linux-ia64] kernel/sched.c -1ULL vs. (cycles_t) -1
Message-Id: <marc-linux-ia64-105590698805541@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

in your ia64 patches you have a small cosmetic change which is (sort of)
making kernel/sched.c platform dependent:

diff -urN linux-2.4.14/kernel/sched.c linux-2.4.14-lia/kernel/sched.c
--- linux-2.4.14/kernel/sched.c Wed Oct 24 10:18:08 2001
+++ linux-2.4.14-lia/kernel/sched.c     Wed Oct 24 10:21:35 2001
@@ -266,7 +266,7 @@
                                target_tsk = tsk;
                        }
                } else {
-                       if (oldest_idle = -1ULL) {
+                       if (oldest_idle = (cycles_t) -1) {
                                int prio = preemption_goodness(tsk, p,
cpu);
 
[ in two places ].
Because of this one needs separate patches for IA-64 and other platforms
when
working on the scheduler. Would you mind taking this out or trying to
get it into
the base-line kernel?

Thanks,
Erich

