From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 May 2001 21:49:47 +0000
Subject: [Linux-ia64] ptrace fix (relative to 2.4.4 + 010508 ia64 patch)
Message-Id: <marc-linux-ia64-105590693005610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a fix for the ptrace() problem that showed with "strace -f".
There was corner case where a POKETEXT or POKEDATA while a system call
was in progress would corrupt the backing store pointer of the target
process.  The patch below fixes this.

	--david

--- ../lia64/arch/ia64/kernel/ptrace.c	Thu Apr 12 19:21:07 2001
+++ arch/ia64/kernel/ptrace.c	Thu May 17 14:26:02 2001
@@ -438,6 +438,25 @@
 }
 
 /*
+ * Simulate user-level "flushrs".  Note: we can't just add pt->loadrs>>16 to
+ * pt->ar_bspstore because the kernel backing store and the user-level backing store may
+ * have different alignments (and therefore a different number of intervening rnat slots).
+ */
+static void
+user_flushrs (struct task_struct *task, struct pt_regs *pt)
+{
+	unsigned long *krbs;
+	long ndirty;
+
+	krbs = (unsigned long *) task + IA64_RBS_OFFSET/8;
+	ndirty = ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
+
+	pt->ar_bspstore = (unsigned long) ia64_rse_skip_regs((unsigned long *) pt->ar_bspstore,
+							     ndirty);
+	pt->loadrs = 0;
+}
+
+/*
  * Synchronize the RSE backing store of CHILD and all tasks that share the address space
  * with it.  CHILD_URBS_END is the address of the end of the register backing store of
  * CHILD.  If MAKE_WRITABLE is set, a user-level "flushrs" is simulated such that the VM
@@ -467,11 +486,8 @@
 		sw = (struct switch_stack *) (child->thread.ksp + 16);
 		pt = ia64_task_regs(child);
 		ia64_sync_user_rbs(child, sw, pt->ar_bspstore, child_urbs_end);
-		if (make_writable) {
-			/* simulate a user-level "flushrs": */
-			pt->loadrs = 0;
-			pt->ar_bspstore = child_urbs_end;
-		}
+		if (make_writable)
+			user_flushrs(child, pt);
 	} else {
 		read_lock(&tasklist_lock);
 		{
@@ -481,11 +497,8 @@
 					pt = ia64_task_regs(p);
 					urbs_end = ia64_get_user_rbs_end(p, pt, NULL);
 					ia64_sync_user_rbs(p, sw, pt->ar_bspstore, urbs_end);
-					if (make_writable) {
-						/* simulate a user-level "flushrs": */
-						pt->loadrs = 0;
-						pt->ar_bspstore = urbs_end;
-					}
+					if (make_writable)
+						user_flushrs(p, pt);
 				}
 			}
 		}

