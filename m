From: Jim Garlick <garlick@llnl.gov>
Date: Thu, 29 Jan 2004 15:41:37 +0000
Subject: Re: [patch/rfc] mca ia64_log_print() race
Message-Id: <Pine.LNX.4.30.0401290732170.18764-100000@cleomedes.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.30.0401281942340.18291-100000@cleomedes.llnl.gov>
In-Reply-To: <Pine.LNX.4.30.0401281942340.18291-100000@cleomedes.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Keith, if you look at the IA64_LOG_LOCK macro, it calls spin_lock_irqsave
with 's' as the flags argument.  IA64_LOG_UNLOCK does same for
spin_unlock_irqrestore.

I'll look closer at the error printing code - maybe we can suppress printk
for INIT/MCA and get somewhere with deadlocks (we do see a form of deadlock
when we simulate a muiltibit memory error which comes in as an MCA)

For now, I'd advocate for this patch if it's correct as it appears to
improve reliability for a common innocuous error (CPE's from single
bit memory errors).

Jim

On Thu, 29 Jan 2004, Keith Owens wrote:

> On Wed, 28 Jan 2004 19:58:33 -0800 (PST),
> Jim Garlick <garlick@llnl.gov> wrote:
> >We have been exercising some of the MCA code on the bench with an instrumented
> >DIMM that can generate single and multibit errors and found that fairly
> >frequently the kernel would crash in the process of handling CPE's.
> >
> >The following patch addresses what we think is a race on ia64_state_log
> >that occurs when CPE's occur back to back (as happens with our crude error
> >generator, probably more than in nature), possibly exacerbated by configuring
> >a slow serial console.
> >
> >diff -u -r1.4.2.1.4.10 -r1.4.2.1.4.15
> >--- arch/ia64/kernel/mca.c      26 Jan 2004 21:18:49 -0000      1.4.2.1.4.10
> >+++ arch/ia64/kernel/mca.c      29 Jan 2004 01:37:42 -0000      1.4.2.1.4.15
> >@@ -2397,7 +2451,9 @@
> > ia64_log_print(int sal_info_type, prfunc_t prfunc)
> > {
> >        int platform_err = 0;
> >+       int s;
>
> What is 's' used for?
>
> >
> >+       IA64_LOG_LOCK(sal_info_type);
> >        switch(sal_info_type) {
> >              case SAL_INFO_TYPE_MCA:
> >                prfunc("+CPU %d: SAL log contains MCA error record\n", smp_processor_id());
> >@@ -2421,6 +2477,7 @@
> >                prfunc("+MCA UNKNOWN ERROR LOG (UNIMPLEMENTED)\n");
> >                break;
> >        }
> >+       IA64_LOG_UNLOCK(sal_info_type);
> >        return platform_err;
> > }
>
> That entire chunk of code has always been racy.  It is not safe to call
> prfunc (printk) for any MCA or INIT events, it can deadlock and/or
> break - MCA/INIT is not irq safe.  All the printing in mca.c needs to
> be cleaned up.
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

