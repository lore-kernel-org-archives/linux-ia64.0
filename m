From: Keith Owens <kaos@sgi.com>
Date: Thu, 15 Sep 2005 00:10:30 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <15385.1126743030@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 14 Sep 2005 17:26:44 -0500, 
Robin Holt <holt@sgi.com> wrote:
>
>On larger systems, ia64_spinlock_contention frequently shows up in
>pfmon output.  Determining whether it is a frequently contended lock or
>numerous different locks is very difficult.
>
>The following patch attributes the ticks received while in
>ia64_spinlock_contention to the requestor of the lock.
>...
>@@ -165,6 +175,12 @@ default_handler(struct task_struct *task
> 	 * where did the fault happen (includes slot number)
> 	 */
> 	ent->ip = regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3);
>+#ifdef CONFIG_SMP
>+	/* Fix up the ip for code in the spinlock contention path. */
>+	if ((ent->ip >= (unsigned long)ia64_spinlock_contention) &&
>+	    (ent->ip < (unsigned long)ia64_spinlock_contention_end))
>+		ent->ip = regs->b6;
>+#endif
> 
> 	ent->tstamp    = stamp;
> 	ent->cpu       = smp_processor_id();

There is a small window at the start of ia64_spinlock_contention_pre3_4
where b6 is not defined.  It is only about 2 bundles wide and is only
executed once when a lock is contended, so you are unlikely to hit it,
just FYI.

