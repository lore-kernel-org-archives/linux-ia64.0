From: Dean Nelson <dcn@sgi.com>
Date: Mon, 27 Aug 2007 15:59:33 +0000
Subject: [PATCH 1/4] export __put_task_struct for XPMEM
Message-Id: <20070827155933.GB25589@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827155622.GA25589@sgi.com>
In-Reply-To: <20070827155622.GA25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com

This patch exports __put_task_struct as it is needed by XPMEM.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

One struct file_operations registered by XPMEM, xpmem_open(), calls
'get_task_struct(current->group_leader)' and another, xpmem_flush(), calls
'put_task_struct(tg->group_leader)'. The reason for this is given in the
comment block that appears in xpmem_open().

	/*
	 * Increment 'usage' and 'mm->mm_users' for the current task's thread
	 * group leader. This ensures that both its task_struct and mm_struct
	 * will still be around when our thread group exits. (The Linux kernel
	 * normally tears down the mm_struct prior to calling a module's
	 * 'flush' function.) Since all XPMEM thread groups must go through
	 * this path, this extra reference to mm_users also allows us to
	 * directly inc/dec mm_users in xpmem_ensure_valid_PFNs() and avoid
	 * mmput() which has a scaling issue with the mmlist_lock.
	 */

Index: linux-2.6/kernel/fork.c
=================================--- linux-2.6.orig/kernel/fork.c	2007-08-09 07:07:55.426611601 -0500
+++ linux-2.6/kernel/fork.c	2007-08-09 07:15:43.246391700 -0500
@@ -127,6 +127,7 @@
 	if (!profile_handoff_task(tsk))
 		free_task(tsk);
 }
+EXPORT_SYMBOL_GPL(__put_task_struct);
 
 void __init fork_init(unsigned long mempages)
 {
