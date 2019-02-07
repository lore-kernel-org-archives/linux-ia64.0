From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:05 +0000
Subject: [PATCH-tip 01/22] locking/qspinlock_stat: Introduce a generic lockevent counting APIs
Message-Id: <1549566446-27967-2-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

The percpu event counts used by qspinlock code can be useful for
other locking code as well. So a new set of lockevent_* counting APIs
is introduced with the lock event names extracted out into the new
lock_events_list.h header file for easier addition in the future.

The existing qstat_inc() calls are replaced by either lockevent_inc() or
lockevent_cond_inc() calls.

The qstat_hop() call is renamed to lockevent_pv_hop(). The "reset_counters"
debugfs file is also renamed to ".reset_counts".

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/lock_events.h        |  55 ++++++++++++
 kernel/locking/lock_events_list.h   |  50 +++++++++++
 kernel/locking/qspinlock.c          |   8 +-
 kernel/locking/qspinlock_paravirt.h |  19 +++--
 kernel/locking/qspinlock_stat.h     | 163 ++++++++++++++----------------------
 5 files changed, 181 insertions(+), 114 deletions(-)
 create mode 100644 kernel/locking/lock_events.h
 create mode 100644 kernel/locking/lock_events_list.h

diff --git a/kernel/locking/lock_events.h b/kernel/locking/lock_events.h
new file mode 100644
index 0000000..4009e07
--- /dev/null
+++ b/kernel/locking/lock_events.h
@@ -0,0 +1,55 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: Waiman Long <longman@redhat.com>
+ */
+
+enum lock_events {
+
+#include "lock_events_list.h"
+
+	lockevent_num,	/* Total number of lock event counts */
+	LOCKEVENT_reset_cnts = lockevent_num,
+};
+
+#ifdef CONFIG_QUEUED_LOCK_STAT
+/*
+ * Per-cpu counters
+ */
+DECLARE_PER_CPU(unsigned long, lockevents[lockevent_num]);
+
+/*
+ * Increment the PV qspinlock statistical counters
+ */
+static inline void __lockevent_inc(enum lock_events event, bool cond)
+{
+	if (cond)
+		__this_cpu_inc(lockevents[event]);
+}
+
+#define lockevent_inc(ev)	  __lockevent_inc(LOCKEVENT_ ##ev, true)
+#define lockevent_cond_inc(ev, c) __lockevent_inc(LOCKEVENT_ ##ev, c)
+
+static inline void __lockevent_add(enum lock_events event, int inc)
+{
+	__this_cpu_add(lockevents[event], inc);
+}
+
+#define lockevent_add(ev, c)	__lockevent_add(LOCKEVENT_ ##ev, c)
+
+#else  /* CONFIG_QUEUED_LOCK_STAT */
+
+#define lockevent_inc(ev)
+#define lockevent_add(ev, c)
+#define lockevent_cond_inc(ev, c)
+
+#endif /* CONFIG_QUEUED_LOCK_STAT */
diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
new file mode 100644
index 0000000..8b4d2e1
--- /dev/null
+++ b/kernel/locking/lock_events_list.h
@@ -0,0 +1,50 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors: Waiman Long <longman@redhat.com>
+ */
+
+#ifndef LOCK_EVENT
+#define LOCK_EVENT(name)	LOCKEVENT_ ## name,
+#endif
+
+#ifdef CONFIG_QUEUED_SPINLOCKS
+#ifdef CONFIG_PARAVIRT_SPINLOCKS
+/*
+ * Locking events for PV qspinlock.
+ */
+LOCK_EVENT(pv_hash_hops)	/* Average # of hops per hashing operation */
+LOCK_EVENT(pv_kick_unlock)	/* # of vCPU kicks issued at unlock time   */
+LOCK_EVENT(pv_kick_wake)	/* # of vCPU kicks for pv_latency_wake	   */
+LOCK_EVENT(pv_latency_kick)	/* Average latency (ns) of vCPU kick	   */
+LOCK_EVENT(pv_latency_wake)	/* Average latency (ns) of kick-to-wakeup  */
+LOCK_EVENT(pv_lock_stealing)	/* # of lock stealing operations	   */
+LOCK_EVENT(pv_spurious_wakeup)	/* # of spurious wakeups in non-head vCPUs */
+LOCK_EVENT(pv_wait_again)	/* # of wait's after queue head vCPU kick  */
+LOCK_EVENT(pv_wait_early)	/* # of early vCPU wait's		   */
+LOCK_EVENT(pv_wait_head)	/* # of vCPU wait's at the queue head	   */
+LOCK_EVENT(pv_wait_node)	/* # of vCPU wait's at non-head queue node */
+#endif /* CONFIG_PARAVIRT_SPINLOCKS */
+
+/*
+ * Locking events for qspinlock
+ *
+ * Subtracting lock_use_node[234] from lock_slowpath will give you
+ * lock_use_node1.
+ */
+LOCK_EVENT(lock_pending)	/* # of locking ops via pending code	     */
+LOCK_EVENT(lock_slowpath)	/* # of locking ops via MCS lock queue	     */
+LOCK_EVENT(lock_use_node2)	/* # of locking ops that use 2nd percpu node */
+LOCK_EVENT(lock_use_node3)	/* # of locking ops that use 3rd percpu node */
+LOCK_EVENT(lock_use_node4)	/* # of locking ops that use 4th percpu node */
+LOCK_EVENT(lock_no_node)	/* # of locking ops w/o using percpu node    */
+#endif /* CONFIG_QUEUED_SPINLOCKS */
diff --git a/kernel/locking/qspinlock.c b/kernel/locking/qspinlock.c
index 21ee51b..fe0dc3c 100644
--- a/kernel/locking/qspinlock.c
+++ b/kernel/locking/qspinlock.c
@@ -398,7 +398,7 @@ void queued_spin_lock_slowpath(struct qspinlock *lock, u32 val)
 	 * 0,1,0 -> 0,0,1
 	 */
 	clear_pending_set_locked(lock);
-	qstat_inc(qstat_lock_pending, true);
+	lockevent_inc(lock_pending);
 	return;
 
 	/*
@@ -406,7 +406,7 @@ void queued_spin_lock_slowpath(struct qspinlock *lock, u32 val)
 	 * queuing.
 	 */
 queue:
-	qstat_inc(qstat_lock_slowpath, true);
+	lockevent_inc(lock_slowpath);
 pv_queue:
 	node = this_cpu_ptr(&qnodes[0].mcs);
 	idx = node->count++;
@@ -422,7 +422,7 @@ void queued_spin_lock_slowpath(struct qspinlock *lock, u32 val)
 	 * simple enough.
 	 */
 	if (unlikely(idx >= MAX_NODES)) {
-		qstat_inc(qstat_lock_no_node, true);
+		lockevent_inc(lock_no_node);
 		while (!queued_spin_trylock(lock))
 			cpu_relax();
 		goto release;
@@ -433,7 +433,7 @@ void queued_spin_lock_slowpath(struct qspinlock *lock, u32 val)
 	/*
 	 * Keep counts of non-zero index values:
 	 */
-	qstat_inc(qstat_lock_use_node2 + idx - 1, idx);
+	lockevent_cond_inc(lock_use_node2 + idx - 1, idx);
 
 	/*
 	 * Ensure that we increment the head node->count before initialising
diff --git a/kernel/locking/qspinlock_paravirt.h b/kernel/locking/qspinlock_paravirt.h
index 8f36c27..89bab07 100644
--- a/kernel/locking/qspinlock_paravirt.h
+++ b/kernel/locking/qspinlock_paravirt.h
@@ -89,7 +89,7 @@ static inline bool pv_hybrid_queued_unfair_trylock(struct qspinlock *lock)
 
 		if (!(val & _Q_LOCKED_PENDING_MASK) &&
 		   (cmpxchg_acquire(&lock->locked, 0, _Q_LOCKED_VAL) = 0)) {
-			qstat_inc(qstat_pv_lock_stealing, true);
+			lockevent_inc(pv_lock_stealing);
 			return true;
 		}
 		if (!(val & _Q_TAIL_MASK) || (val & _Q_PENDING_MASK))
@@ -219,7 +219,7 @@ static struct qspinlock **pv_hash(struct qspinlock *lock, struct pv_node *node)
 		hopcnt++;
 		if (!cmpxchg(&he->lock, NULL, lock)) {
 			WRITE_ONCE(he->node, node);
-			qstat_hop(hopcnt);
+			lockevent_pv_hop(hopcnt);
 			return &he->lock;
 		}
 	}
@@ -320,8 +320,8 @@ static void pv_wait_node(struct mcs_spinlock *node, struct mcs_spinlock *prev)
 		smp_store_mb(pn->state, vcpu_halted);
 
 		if (!READ_ONCE(node->locked)) {
-			qstat_inc(qstat_pv_wait_node, true);
-			qstat_inc(qstat_pv_wait_early, wait_early);
+			lockevent_inc(pv_wait_node);
+			lockevent_cond_inc(pv_wait_early, wait_early);
 			pv_wait(&pn->state, vcpu_halted);
 		}
 
@@ -339,7 +339,8 @@ static void pv_wait_node(struct mcs_spinlock *node, struct mcs_spinlock *prev)
 		 * So it is better to spin for a while in the hope that the
 		 * MCS lock will be released soon.
 		 */
-		qstat_inc(qstat_pv_spurious_wakeup, !READ_ONCE(node->locked));
+		lockevent_cond_inc(pv_spurious_wakeup,
+				  !READ_ONCE(node->locked));
 	}
 
 	/*
@@ -416,7 +417,7 @@ static void pv_kick_node(struct qspinlock *lock, struct mcs_spinlock *node)
 	/*
 	 * Tracking # of slowpath locking operations
 	 */
-	qstat_inc(qstat_lock_slowpath, true);
+	lockevent_inc(lock_slowpath);
 
 	for (;; waitcnt++) {
 		/*
@@ -464,8 +465,8 @@ static void pv_kick_node(struct qspinlock *lock, struct mcs_spinlock *node)
 			}
 		}
 		WRITE_ONCE(pn->state, vcpu_hashed);
-		qstat_inc(qstat_pv_wait_head, true);
-		qstat_inc(qstat_pv_wait_again, waitcnt);
+		lockevent_inc(pv_wait_head);
+		lockevent_cond_inc(pv_wait_again, waitcnt);
 		pv_wait(&lock->locked, _Q_SLOW_VAL);
 
 		/*
@@ -528,7 +529,7 @@ static void pv_kick_node(struct qspinlock *lock, struct mcs_spinlock *node)
 	 * vCPU is harmless other than the additional latency in completing
 	 * the unlock.
 	 */
-	qstat_inc(qstat_pv_kick_unlock, true);
+	lockevent_inc(pv_kick_unlock);
 	pv_kick(node->cpu);
 }
 
diff --git a/kernel/locking/qspinlock_stat.h b/kernel/locking/qspinlock_stat.h
index d73f853..1db5b37 100644
--- a/kernel/locking/qspinlock_stat.h
+++ b/kernel/locking/qspinlock_stat.h
@@ -38,8 +38,8 @@
  * Subtracting lock_use_node[234] from lock_slowpath will give you
  * lock_use_node1.
  *
- * Writing to the "reset_counters" file will reset all the above counter
- * values.
+ * Writing to the special ".reset_counts" file will reset all the above
+ * counter values.
  *
  * These statistical counters are implemented as per-cpu variables which are
  * summed and computed whenever the corresponding debugfs files are read. This
@@ -48,27 +48,7 @@
  *
  * There may be slight difference between pv_kick_wake and pv_kick_unlock.
  */
-enum qlock_stats {
-	qstat_pv_hash_hops,
-	qstat_pv_kick_unlock,
-	qstat_pv_kick_wake,
-	qstat_pv_latency_kick,
-	qstat_pv_latency_wake,
-	qstat_pv_lock_stealing,
-	qstat_pv_spurious_wakeup,
-	qstat_pv_wait_again,
-	qstat_pv_wait_early,
-	qstat_pv_wait_head,
-	qstat_pv_wait_node,
-	qstat_lock_pending,
-	qstat_lock_slowpath,
-	qstat_lock_use_node2,
-	qstat_lock_use_node3,
-	qstat_lock_use_node4,
-	qstat_lock_no_node,
-	qstat_num,	/* Total number of statistical counters */
-	qstat_reset_cnts = qstat_num,
-};
+#include "lock_events.h"
 
 #ifdef CONFIG_QUEUED_LOCK_STAT
 /*
@@ -79,99 +59,91 @@ enum qlock_stats {
 #include <linux/sched/clock.h>
 #include <linux/fs.h>
 
-static const char * const qstat_names[qstat_num + 1] = {
-	[qstat_pv_hash_hops]	   = "pv_hash_hops",
-	[qstat_pv_kick_unlock]     = "pv_kick_unlock",
-	[qstat_pv_kick_wake]       = "pv_kick_wake",
-	[qstat_pv_spurious_wakeup] = "pv_spurious_wakeup",
-	[qstat_pv_latency_kick]	   = "pv_latency_kick",
-	[qstat_pv_latency_wake]    = "pv_latency_wake",
-	[qstat_pv_lock_stealing]   = "pv_lock_stealing",
-	[qstat_pv_wait_again]      = "pv_wait_again",
-	[qstat_pv_wait_early]      = "pv_wait_early",
-	[qstat_pv_wait_head]       = "pv_wait_head",
-	[qstat_pv_wait_node]       = "pv_wait_node",
-	[qstat_lock_pending]       = "lock_pending",
-	[qstat_lock_slowpath]      = "lock_slowpath",
-	[qstat_lock_use_node2]	   = "lock_use_node2",
-	[qstat_lock_use_node3]	   = "lock_use_node3",
-	[qstat_lock_use_node4]	   = "lock_use_node4",
-	[qstat_lock_no_node]	   = "lock_no_node",
-	[qstat_reset_cnts]         = "reset_counters",
+#define EVENT_COUNT(ev)	lockevents[LOCKEVENT_ ## ev]
+
+#undef  LOCK_EVENT
+#define LOCK_EVENT(name)	[LOCKEVENT_ ## name] = #name,
+
+static const char * const lockevent_names[lockevent_num + 1] = {
+
+#include "lock_events_list.h"
+
+	[LOCKEVENT_reset_cnts] = ".reset_counts",
 };
 
 /*
  * Per-cpu counters
  */
-static DEFINE_PER_CPU(unsigned long, qstats[qstat_num]);
+DEFINE_PER_CPU(unsigned long, lockevents[lockevent_num]);
 static DEFINE_PER_CPU(u64, pv_kick_time);
 
 /*
  * Function to read and return the qlock statistical counter values
  *
  * The following counters are handled specially:
- * 1. qstat_pv_latency_kick
+ * 1. pv_latency_kick
  *    Average kick latency (ns) = pv_latency_kick/pv_kick_unlock
- * 2. qstat_pv_latency_wake
+ * 2. pv_latency_wake
  *    Average wake latency (ns) = pv_latency_wake/pv_kick_wake
- * 3. qstat_pv_hash_hops
+ * 3. pv_hash_hops
  *    Average hops/hash = pv_hash_hops/pv_kick_unlock
  */
-static ssize_t qstat_read(struct file *file, char __user *user_buf,
-			  size_t count, loff_t *ppos)
+static ssize_t lockevent_read(struct file *file, char __user *user_buf,
+			      size_t count, loff_t *ppos)
 {
 	char buf[64];
-	int cpu, counter, len;
-	u64 stat = 0, kicks = 0;
+	int cpu, id, len;
+	u64 sum = 0, kicks = 0;
 
 	/*
 	 * Get the counter ID stored in file->f_inode->i_private
 	 */
-	counter = (long)file_inode(file)->i_private;
+	id = (long)file_inode(file)->i_private;
 
-	if (counter >= qstat_num)
+	if (id >= lockevent_num)
 		return -EBADF;
 
 	for_each_possible_cpu(cpu) {
-		stat += per_cpu(qstats[counter], cpu);
+		sum += per_cpu(lockevents[id], cpu);
 		/*
-		 * Need to sum additional counter for some of them
+		 * Need to sum additional counters for some of them
 		 */
-		switch (counter) {
+		switch (id) {
 
-		case qstat_pv_latency_kick:
-		case qstat_pv_hash_hops:
-			kicks += per_cpu(qstats[qstat_pv_kick_unlock], cpu);
+		case LOCKEVENT_pv_latency_kick:
+		case LOCKEVENT_pv_hash_hops:
+			kicks += per_cpu(EVENT_COUNT(pv_kick_unlock), cpu);
 			break;
 
-		case qstat_pv_latency_wake:
-			kicks += per_cpu(qstats[qstat_pv_kick_wake], cpu);
+		case LOCKEVENT_pv_latency_wake:
+			kicks += per_cpu(EVENT_COUNT(pv_kick_wake), cpu);
 			break;
 		}
 	}
 
-	if (counter = qstat_pv_hash_hops) {
+	if (id = LOCKEVENT_pv_hash_hops) {
 		u64 frac = 0;
 
 		if (kicks) {
-			frac = 100ULL * do_div(stat, kicks);
+			frac = 100ULL * do_div(sum, kicks);
 			frac = DIV_ROUND_CLOSEST_ULL(frac, kicks);
 		}
 
 		/*
 		 * Return a X.XX decimal number
 		 */
-		len = snprintf(buf, sizeof(buf) - 1, "%llu.%02llu\n", stat, frac);
+		len = snprintf(buf, sizeof(buf) - 1, "%llu.%02llu\n",
+			       sum, frac);
 	} else {
 		/*
 		 * Round to the nearest ns
 		 */
-		if ((counter = qstat_pv_latency_kick) ||
-		    (counter = qstat_pv_latency_wake)) {
+		if ((id = LOCKEVENT_pv_latency_kick) ||
+		    (id = LOCKEVENT_pv_latency_wake)) {
 			if (kicks)
-				stat = DIV_ROUND_CLOSEST_ULL(stat, kicks);
+				sum = DIV_ROUND_CLOSEST_ULL(sum, kicks);
 		}
-		len = snprintf(buf, sizeof(buf) - 1, "%llu\n", stat);
+		len = snprintf(buf, sizeof(buf) - 1, "%llu\n", sum);
 	}
 
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
@@ -180,11 +152,9 @@ static ssize_t qstat_read(struct file *file, char __user *user_buf,
 /*
  * Function to handle write request
  *
- * When counter = reset_cnts, reset all the counter values.
- * Since the counter updates aren't atomic, the resetting is done twice
- * to make sure that the counters are very likely to be all cleared.
+ * When id = .reset_cnts, reset all the counter values.
  */
-static ssize_t qstat_write(struct file *file, const char __user *user_buf,
+static ssize_t lockevent_write(struct file *file, const char __user *user_buf,
 			   size_t count, loff_t *ppos)
 {
 	int cpu;
@@ -192,14 +162,14 @@ static ssize_t qstat_write(struct file *file, const char __user *user_buf,
 	/*
 	 * Get the counter ID stored in file->f_inode->i_private
 	 */
-	if ((long)file_inode(file)->i_private != qstat_reset_cnts)
+	if ((long)file_inode(file)->i_private != LOCKEVENT_reset_cnts)
 		return count;
 
 	for_each_possible_cpu(cpu) {
 		int i;
-		unsigned long *ptr = per_cpu_ptr(qstats, cpu);
+		unsigned long *ptr = per_cpu_ptr(lockevents, cpu);
 
-		for (i = 0 ; i < qstat_num; i++)
+		for (i = 0 ; i < lockevent_num; i++)
 			WRITE_ONCE(ptr[i], 0);
 	}
 	return count;
@@ -208,9 +178,9 @@ static ssize_t qstat_write(struct file *file, const char __user *user_buf,
 /*
  * Debugfs data structures
  */
-static const struct file_operations fops_qstat = {
-	.read = qstat_read,
-	.write = qstat_write,
+static const struct file_operations fops_lockevent = {
+	.read = lockevent_read,
+	.write = lockevent_write,
 	.llseek = default_llseek,
 };
 
@@ -219,10 +189,10 @@ static ssize_t qstat_write(struct file *file, const char __user *user_buf,
  */
 static int __init init_qspinlock_stat(void)
 {
-	struct dentry *d_qstat = debugfs_create_dir("qlockstat", NULL);
+	struct dentry *d_counts = debugfs_create_dir("qlockstat", NULL);
 	int i;
 
-	if (!d_qstat)
+	if (!d_counts)
 		goto out;
 
 	/*
@@ -232,18 +202,19 @@ static int __init init_qspinlock_stat(void)
 	 * root is allowed to do the read/write to limit impact to system
 	 * performance.
 	 */
-	for (i = 0; i < qstat_num; i++)
-		if (!debugfs_create_file(qstat_names[i], 0400, d_qstat,
-					 (void *)(long)i, &fops_qstat))
+	for (i = 0; i < lockevent_num; i++)
+		if (!debugfs_create_file(lockevent_names[i], 0400, d_counts,
+					 (void *)(long)i, &fops_lockevent))
 			goto fail_undo;
 
-	if (!debugfs_create_file(qstat_names[qstat_reset_cnts], 0200, d_qstat,
-				 (void *)(long)qstat_reset_cnts, &fops_qstat))
+	if (!debugfs_create_file(lockevent_names[LOCKEVENT_reset_cnts], 0200,
+				 d_counts, (void *)(long)LOCKEVENT_reset_cnts,
+				 &fops_lockevent))
 		goto fail_undo;
 
 	return 0;
 fail_undo:
-	debugfs_remove_recursive(d_qstat);
+	debugfs_remove_recursive(d_counts);
 out:
 	pr_warn("Could not create 'qlockstat' debugfs entries\n");
 	return -ENOMEM;
@@ -251,20 +222,11 @@ static int __init init_qspinlock_stat(void)
 fs_initcall(init_qspinlock_stat);
 
 /*
- * Increment the PV qspinlock statistical counters
- */
-static inline void qstat_inc(enum qlock_stats stat, bool cond)
-{
-	if (cond)
-		this_cpu_inc(qstats[stat]);
-}
-
-/*
  * PV hash hop count
  */
-static inline void qstat_hop(int hopcnt)
+static inline void lockevent_pv_hop(int hopcnt)
 {
-	this_cpu_add(qstats[qstat_pv_hash_hops], hopcnt);
+	this_cpu_add(EVENT_COUNT(pv_hash_hops), hopcnt);
 }
 
 /*
@@ -276,7 +238,7 @@ static inline void __pv_kick(int cpu)
 
 	per_cpu(pv_kick_time, cpu) = start;
 	pv_kick(cpu);
-	this_cpu_add(qstats[qstat_pv_latency_kick], sched_clock() - start);
+	this_cpu_add(EVENT_COUNT(pv_latency_kick), sched_clock() - start);
 }
 
 /*
@@ -289,9 +251,9 @@ static inline void __pv_wait(u8 *ptr, u8 val)
 	*pkick_time = 0;
 	pv_wait(ptr, val);
 	if (*pkick_time) {
-		this_cpu_add(qstats[qstat_pv_latency_wake],
+		this_cpu_add(EVENT_COUNT(pv_latency_wake),
 			     sched_clock() - *pkick_time);
-		qstat_inc(qstat_pv_kick_wake, true);
+		lockevent_inc(pv_kick_wake);
 	}
 }
 
@@ -300,7 +262,6 @@ static inline void __pv_wait(u8 *ptr, u8 val)
 
 #else /* CONFIG_QUEUED_LOCK_STAT */
 
-static inline void qstat_inc(enum qlock_stats stat, bool cond)	{ }
-static inline void qstat_hop(int hopcnt)			{ }
+static inline void lockevent_pv_hop(int hopcnt)	{ }
 
 #endif /* CONFIG_QUEUED_LOCK_STAT */
-- 
1.8.3.1
