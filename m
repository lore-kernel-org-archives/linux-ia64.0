From: Jack Steiner <steiner@sgi.com>
Date: Thu, 29 Jan 2004 22:14:44 +0000
Subject: [PATCH] - Move cpu_vm_mask to be closer to mmu_context_t in struct mm
Message-Id: <20040129221444.GA11032@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org


The cpu_vm_mask use to be close to the mmu_context_t field
in the mm struct. Recently some large members were
added between "cpu_vm_mask" and "context". I suspect that
was an oversight. 

Here is a patch that puts the fields close together. This
makes it likely that both fields are in the same cache line. 
Since both fields are likely to be updated at the same 
time, this may improve performance.




--- linux.base/./include/linux/sched.h	Mon Jan 26 17:06:13 2004
+++ linux/./include/linux/sched.h	Thu Jan 29 13:28:15 2004
@@ -206,7 +206,6 @@
 	unsigned long arg_start, arg_end, env_start, env_end;
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
-	cpumask_t cpu_vm_mask;
 
 	unsigned long saved_auxv[40]; /* for /proc/PID/auxv */
 
@@ -214,6 +213,8 @@
 #ifdef CONFIG_HUGETLB_PAGE
 	int used_hugetlb;
 #endif
+	cpumask_t cpu_vm_mask;
+
 	/* Architecture-specific MM context */
 	mm_context_t context;
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


