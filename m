From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 07 Sep 2005 07:22:29 +0000
Subject: [patch] delete sync.i in ia64_switch_to()
Message-Id: <200509070723.j877N9g25144@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The sync.i instruction in ia64_switch_to() context switch code
looks like an old leftover code.  sync.i instruction supposedly
ensures flush cache operation issued by processor become visible
to memory reference.  Everywhere I looked where fc instruction is
used (ia64_fc), a sync.i is always accompanied.  Everywhere in
the vicinity of context switch (save_switch_stack/load_switch_stack)
don't have any fc instruction in there.  I don't see any reason why
we need to issue sync.i in context switch code.  Patch to remove it.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./arch/ia64/kernel/entry.S.orig	2005-09-06 22:36:17.114182129 -0700
+++ ./arch/ia64/kernel/entry.S	2005-09-07 00:20:37.216644505 -0700
@@ -213,10 +213,6 @@ GLOBAL_ENTRY(ia64_switch_to)
 	mov r13=in0			// set "current" pointer
 	;;
 	DO_LOAD_SWITCH_STACK
-
-#ifdef CONFIG_SMP
-	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
-#endif
 	br.ret.sptk.many rp		// boogie on out in new context
 
 .map:


