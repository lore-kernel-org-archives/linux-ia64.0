From: Robin Holt <holt@sgi.com>
Date: Thu, 15 Sep 2005 17:14:31 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050915171431.GB10755@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 15, 2005 at 10:10:30AM +1000, Keith Owens wrote:
> On Wed, 14 Sep 2005 17:26:44 -0500, 
> Robin Holt <holt@sgi.com> wrote:
> >
> >On larger systems, ia64_spinlock_contention frequently shows up in
> >pfmon output.  Determining whether it is a frequently contended lock or
> >numerous different locks is very difficult.
> >
> >The following patch attributes the ticks received while in
> >ia64_spinlock_contention to the requestor of the lock.
> >...
> >@@ -165,6 +175,12 @@ default_handler(struct task_struct *task
> > 	 * where did the fault happen (includes slot number)
> > 	 */
> > 	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
> >+#ifdef CONFIG_SMP
> >+	/* Fix up the ip for code in the spinlock contention path. */
> >+	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
> >+	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
> >+		ent->ip = regs->b6;
> >+#endif
> > 
> > 	ent->tstamp    = stamp;
> > 	ent->cpu       = smp_processor_id();
> 
> There is a small window at the start of ia64_spinlock_contention_pre3_4
> where b6 is not defined.  It is only about 2 bundles wide and is only
> executed once when a lock is contended, so you are unlikely to hit it,
> just FYI.

Here is a better version with that taken care of.  Do you see any other
issues?


Index: linux-2.6/arch/ia64/kernel/head.S
=================================--- linux-2.6.orig/arch/ia64/kernel/head.S	2005-09-09 18:06:16.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/head.S	2005-09-15 12:07:30.019498585 -0500
@@ -1071,6 +1071,8 @@ GLOBAL_ENTRY(ia64_spinlock_contention_pr
 	tbit.nz p15,p0=r27,IA64_PSR_I_BIT
 	.restore sp		// pop existing prologue after next insn
 	mov b6 = r28
+	.global ia64_spinlock_contention_pre3_4_beg	// for kernprof
+ia64_spinlock_contention_pre3_4_beg:
 	.prologue
 	.save ar.pfs, r0
 	.altrp b6
@@ -1119,6 +1121,8 @@ GLOBAL_ENTRY(ia64_spinlock_contention)
 (p14)	br.cond.sptk.few .wait
 
 	br.ret.sptk.many b6	// lock is now taken
+	.global ia64_spinlock_contention_end	// for determining if we are in ia64_spinlock_contention code.
+ia64_spinlock_contention_end:
 END(ia64_spinlock_contention)
 
 #endif
Index: linux-2.6/arch/ia64/kernel/ia64_ksyms.c
=================================--- linux-2.6.orig/arch/ia64/kernel/ia64_ksyms.c	2005-09-01 09:30:56.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/ia64_ksyms.c	2005-09-15 12:07:30.019498585 -0500
@@ -109,6 +109,10 @@ EXPORT_SYMBOL(unw_init_running);
  */
 extern char ia64_spinlock_contention_pre3_4;
 EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4);
+extern char ia64_spinlock_contention_pre3_4_beg;
+EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4_beg);
+extern char ia64_spinlock_contention_pre3_4_end;
+EXPORT_SYMBOL(ia64_spinlock_contention_pre3_4_end);
 #  else
 /*
  * This is not a normal routine and we don't want a function descriptor for it, so we use
@@ -116,6 +120,8 @@ EXPORT_SYMBOL(ia64_spinlock_contention_p
  */
 extern char ia64_spinlock_contention;
 EXPORT_SYMBOL(ia64_spinlock_contention);
+extern char ia64_spinlock_contention_end;
+EXPORT_SYMBOL(ia64_spinlock_contention_end);
 #  endif
 # endif
 #endif
Index: linux-2.6/arch/ia64/kernel/perfmon_default_smpl.c
=================================--- linux-2.6.orig/arch/ia64/kernel/perfmon_default_smpl.c	2005-09-01 09:30:56.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/perfmon_default_smpl.c	2005-09-15 12:08:23.772955818 -0500
@@ -99,6 +99,16 @@ default_init(struct task_struct *task, v
 	return 0;
 }
 
+#ifdef CONFIG_SMP
+#if __GNUC__ < 3 || (__GNUC__ = 3 && __GNUC_MINOR__ < 3)
+extern char ia64_spinlock_contention_pre3_4_beg[], ia64_spinlock_contention_pre3_4_end[];
+#define ia64_spinlock_contention		ia64_spinlock_contention_pre3_4_beg
+#define ia64_spinlock_contention_end		ia64_spinlock_contention_pre3_4_end
+#else
+extern char ia64_spinlock_contention[], ia64_spinlock_contention_end[];
+#endif
+#endif
+
 static int
 default_handler(struct task_struct *task, void *buf, pfm_ovfl_arg_t *arg, struct pt_regs *regs, unsigned long stamp)
 {
@@ -165,6 +175,12 @@ default_handler(struct task_struct *task
 	 * where did the fault happen (includes slot number)
 	 */
 	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
+#ifdef CONFIG_SMP
+	/* Fix up the ip for code in the spinlock contention path. */
+	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
+	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
+		ent->ip = regs->b6;
+#endif
 
 	ent->tstamp    = stamp;
 	ent->cpu       = smp_processor_id();
