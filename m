From: David Howells <dhowells@redhat.com>
Date: Wed, 27 Aug 2008 13:45:47 +0000
Subject: [PATCH 01/59] CRED: Wrap task credential accesses in the IA64 arch
Message-Id: <20080827134547.19980.38813.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
In-Reply-To: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-security-module@vger.kernel.org, David Howells <dhowells@redhat.com>, Serge Hallyn <serue@us.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Wrap access to task credentials so that they can be separated more easily from
the task_struct during the introduction of COW creds.

Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().

Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
sense to use RCU directly rather than a convenient wrapper; these will be
addressed by later patches.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: James Morris <jmorris@namei.org>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---

 arch/ia64/kernel/mca_drv.c |    2 +-
 arch/ia64/kernel/perfmon.c |   23 +++++++++++++----------
 arch/ia64/kernel/signal.c  |    4 ++--
 3 files changed, 16 insertions(+), 13 deletions(-)


diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index fab1d21..f94aaa8 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -158,7 +158,7 @@ mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
 	ia64_mlogbuf_dump();
 	printk(KERN_ERR "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
 		"iip: %p, psr: 0x%lx,paddr: 0x%lx](%s) encounters MCA.\n",
-		raw_smp_processor_id(), current->pid, current->uid,
+	       raw_smp_processor_id(), current->pid, current_uid(),
 		iip, ipsr, paddr, current->comm);
 
 	spin_lock(&mca_bh_lock);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index fc8f350..ffe6de0 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -2224,8 +2224,8 @@ pfm_alloc_file(pfm_context_t *ctx)
 	DPRINT(("new inode ino=%ld @%p\n", inode->i_ino, inode));
 
 	inode->i_mode = S_IFCHR|S_IRUGO;
-	inode->i_uid  = current->fsuid;
-	inode->i_gid  = current->fsgid;
+	inode->i_uid  = current_fsuid();
+	inode->i_gid  = current_fsgid();
 
 	sprintf(name, "[%lu]", inode->i_ino);
 	this.name = name;
@@ -2403,22 +2403,25 @@ error_kmem:
 static int
 pfm_bad_permissions(struct task_struct *task)
 {
+	uid_t uid = current_uid();
+	gid_t gid = current_gid();
+
 	/* inspired by ptrace_attach() */
 	DPRINT(("cur: uid=%d gid=%d task: euid=%d suid=%d uid=%d egid=%d sgid=%d\n",
-		current->uid,
-		current->gid,
+		uid,
+		gid,
 		task->euid,
 		task->suid,
 		task->uid,
 		task->egid,
 		task->sgid));
 
-	return ((current->uid != task->euid)
-	    || (current->uid != task->suid)
-	    || (current->uid != task->uid)
-	    || (current->gid != task->egid)
-	    || (current->gid != task->sgid)
-	    || (current->gid != task->gid)) && !capable(CAP_SYS_PTRACE);
+	return (uid != task->euid)
+	    || (uid != task->suid)
+	    || (uid != task->uid)
+	    || (gid != task->egid)
+	    || (gid != task->sgid)
+	    || (gid != task->gid)) && !capable(CAP_SYS_PTRACE);
 }
 
 static int
diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
index 19c5a78..434e93e 100644
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -228,7 +228,7 @@ ia64_rt_sigreturn (struct sigscratch *scr)
 	si.si_errno = 0;
 	si.si_code = SI_KERNEL;
 	si.si_pid = task_pid_vnr(current);
-	si.si_uid = current->uid;
+	si.si_uid = current_uid();
 	si.si_addr = sc;
 	force_sig_info(SIGSEGV, &si, current);
 	return retval;
@@ -325,7 +325,7 @@ force_sigsegv_info (int sig, void __user *addr)
 	si.si_errno = 0;
 	si.si_code = SI_KERNEL;
 	si.si_pid = task_pid_vnr(current);
-	si.si_uid = current->uid;
+	si.si_uid = current_uid();
 	si.si_addr = addr;
 	force_sig_info(SIGSEGV, &si, current);
 	return 0;

