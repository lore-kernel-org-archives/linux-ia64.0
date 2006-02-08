From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:41:04 +0000
Subject: [PATCH 2.6.16-rc2 2/3] MCA: update MCA comm field for user space tasks
Message-Id: <20060208024104.9264.23245.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Update the comm field on the MCA handler for user tasks as well as for
verified kernel tasks.  This helps to identify the task that was
running when the MCA occurred.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 mca.c |   52 ++++++++++++++++++++++++++++++++--------------------
 1 files changed, 32 insertions(+), 20 deletions(-)

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2006-02-08 11:45:03.892937679 +1100
+++ linux/arch/ia64/kernel/mca.c	2006-02-08 11:54:26.782690102 +1100
@@ -630,6 +630,32 @@ copy_reg(const u64 *fr, u64 fnat, u64 *t
 	*tnat |= (nat << tslot);
 }
 
+/* Change the comm field on the MCA/INT task to include the pid that
+ * was interrupted, it makes for easier debugging.  If that pid was 0
+ * (swapper or nested MCA/INIT) then use the start of the previous comm
+ * field suffixed with its cpu.
+ */
+
+static void
+ia64_mca_modify_comm(const task_t *previous_current)
+{
+	char *p, comm[sizeof(current->comm)];
+	if (previous_current->pid)
+		snprintf(comm, sizeof(comm), "%s %d",
+			current->comm, previous_current->pid);
+	else {
+		int l;
+		if ((p = strchr(previous_current->comm, ' ')))
+			l = p - previous_current->comm;
+		else
+			l = strlen(previous_current->comm);
+		snprintf(comm, sizeof(comm), "%s %*s %d",
+			current->comm, l, previous_current->comm,
+			task_thread_info(previous_current)->cpu);
+	}
+	memcpy(current->comm, comm, sizeof(current->comm));
+}
+
 /* On entry to this routine, we are running on the per cpu stack, see
  * mca_asm.h.  The original stack has not been touched by this event.  Some of
  * the original stack's registers will be in the RBS on this stack.  This stack
@@ -648,7 +674,7 @@ ia64_mca_modify_original_stack(struct pt
 		struct ia64_sal_os_state *sos,
 		const char *type)
 {
-	char *p, comm[sizeof(current->comm)];
+	char *p;
 	ia64_va va;
 	extern char ia64_leave_kernel[];	/* Need asm address, not function descriptor */
 	const pal_min_state_area_t *ms = sos->pal_min_state;
@@ -721,6 +747,10 @@ ia64_mca_modify_original_stack(struct pt
 	/* Verify the previous stack state before we change it */
 	if (user_mode(regs)) {
 		msg = "occurred in user space";
+		/* previous_current is guaranteed to be valid when the task was
+		 * in user space, so ...
+		 */
+		ia64_mca_modify_comm(previous_current);
 		goto no_mod;
 	}
 	if (r13 != sos->prev_IA64_KR_CURRENT) {
@@ -750,25 +780,7 @@ ia64_mca_modify_original_stack(struct pt
 		goto no_mod;
 	}
 
-	/* Change the comm field on the MCA/INT task to include the pid that
-	 * was interrupted, it makes for easier debugging.  If that pid was 0
-	 * (swapper or nested MCA/INIT) then use the start of the previous comm
-	 * field suffixed with its cpu.
-	 */
-	if (previous_current->pid)
-		snprintf(comm, sizeof(comm), "%s %d",
-			current->comm, previous_current->pid);
-	else {
-		int l;
-		if ((p = strchr(previous_current->comm, ' ')))
-			l = p - previous_current->comm;
-		else
-			l = strlen(previous_current->comm);
-		snprintf(comm, sizeof(comm), "%s %*s %d",
-			current->comm, l, previous_current->comm,
-			task_thread_info(previous_current)->cpu);
-	}
-	memcpy(current->comm, comm, sizeof(current->comm));
+	ia64_mca_modify_comm(previous_current);
 
 	/* Make the original task look blocked.  First stack a struct pt_regs,
 	 * describing the state at the time of interrupt.  mca_asm.S built a
