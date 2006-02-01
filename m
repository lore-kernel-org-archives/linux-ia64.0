From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Feb 2006 18:17:43 +0000
Subject: RE: [patch 41/44] make thread_info.flags an unsigned long
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0595DB4D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090335.476045000@localhost.localdomain>
In-Reply-To: <20060201090335.476045000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org
Cc: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-ia64@vger.kernel.org, linuxsh-dev@lists.sourceforge.net, Andi Kleen <ak@suse.de>

 
--- 2.6-git.orig/include/asm-ia64/thread_info.h
+++ 2.6-git/include/asm-ia64/thread_info.h
@@ -24,7 +24,7 @@
 struct thread_info {
 	struct task_struct *task;	/* XXX not really needed, except for dup_task_struct() */
 	struct exec_domain *exec_domain;/* execution domain */
-	__u32 flags;			/* thread_info flags (see TIF_*) */
+	unsigned long flags;		/* thread_info flags (see TIF_*) */
 	__u32 cpu;			/* current CPU */
 	mm_segment_t addr_limit;	/* user-level address space limit */
 	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */

This leaves a useless hole in the structure.  Tell me again why
this is a good thing?

-Tony
