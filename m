From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 14 May 2001 12:52:40 +0000
Subject: Re: [Linux-ia64] Replacements for local_irq_xxx()
Message-Id: <marc-linux-ia64-105590693005571@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005562@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 May 2001 07:26:38 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Thu, 10 May 2001 18:55:13 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> Existing local_irq_xxx() routines clear psr.i which masks all
>  Keith> interrupts, including NMI.  Then the only way to get the
>  Keith> attention of a cpu in a disabled spin loop is via INIT which
>  Keith> is too drastic.  How about these alternatives which set
>  Keith> cr.tpr.mmi instead, masking all external interrupts except
>  Keith> NMI?
>
>I'd rather not do that.  Accessing tpr is slow and requires explicit
>serialization.

I have measured the slowdown and I believe that it is acceptable,
expecially when the benefit is far better debugging and the ability to
use an NMI watchdog.  The module below measures the cost of the
existing method (rsm psr.i) and my replacement method using cr.tpr.mmi.
Using psr.i takes 8 cycles while using cr.tpr.mmi takes 109 cycles to
disable then reenable interrupts.  Typical values on a BigSur dual B3
@ 700MHz, build 99.

psr.i                   8.18
tpr.mmi               109.03
mov from tpr           35.99
mov to tpr              4.06
srlz.d                 32.01

The first two figures are the important ones, the others were for my
curiosity.

That seems to be a large difference but it depends on how often
local_irq_xxx() routines are called so I instrumented local_irq_save()
and local_irq_disable().  Starting from a freshly booted machine, make
oldconfig; make dep; make -j4 vmlinux modules on a dual B3 @ 700MHz
shows approx. 14,000,000 calls to those routines.  14,000,000 calls *
100 extra cycles @ 700MHz is approx. 2 extra seconds over the span of a
15 minute compile.

Using an INIT interrupt goes through PAL and SAL before it gets to the
OS, any side effects of INIT are going to be platform dependent.  It is
bad enough maintaining kdb for multiple architectures, I do not want to
handle multiple platforms as well.  Also INIT is far too expensive to
use as a watchdog.

Note that I only want to replace the code in local_irq_xxx() routines.
Interrupt handlers and switch_to() will still use psr.i, either because
they have to or because those routines very rarely lock up.

David, your choice.

1. Current method.  No debugging of disabled lockups, no NMI watchdog.

2. Use cr.tpr.mmi.  Can debug disabled machines, can use NMI watchdog.
   A kernel compile is 0.001% slower.

3. Use INIT interrupt.  Platform dependent side effects, too expensive
   for a watchdog.

4. Use psr.i for normal kernels, use cr.tpr.mmi for kdb kernels.  This
   has a risk of Heisenbugs, and will not work well for binary only
   kernel modules loaded into a kdb kernel.

5. Any other ideas?


/* Example module to measure extra cost of cr.tpr.mmi */
#include <linux/config.h>
#include <linux/kernel.h>
#include <linux/module.h>

#define TEST_LOOPS 1000

#define timeit(n,code)				\
	__asm__ __volatile__ (			\
	";;"					\
	"mov ar.lc=%2;"				\
	"mov %0=ar.itc;;"			\
	"1:;"					\
	code					\
	"br.cloop.sptk.few 1b;;"		\
	"mov %1=ar.itc;;"			\
	: "=r" (start##n), "=r" (end##n) :	\
	"r" (TEST_LOOPS) :			\
	"r16", "r17" );

#define var(n) long start##n, end##n, cost##n

#define calc_cost(n, expr)			\
	cost##n = expr < 0 ? 0 : expr

#define print_cost(n, text)			\
	printk("%-20.20s %4ld.%02ld\n", text,	\
	(cost##n)/TEST_LOOPS,			\
	(((cost##n)%TEST_LOOPS)*100)/TEST_LOOPS)

int init_module(void)
{
	var(0);
	var(1);
	var(2);
	var(3);
	var(4);
	var(5);

	timeit(0, "");

	timeit(1,
		"rsm psr.i;;"
		"ssm psr.i;; srlz.d;;");

	/* Must wrap tpr timing code in rsm/ssm psr.i to avoid
	 * race with tpr changes in ia64_handle_irq.  Probably not
	 * needed for the final code, after changing ia64_handle_irq.
	 */
	timeit(2,
		"rsm psr.i;;"
		"mov r17=(1 << 16); mov r16=cr.tpr;;"
		"or r17=r17,r16;; mov cr.tpr=r17;; srlz.d;;"
		"mov cr.tpr=r16;; srlz.d;;"
		"ssm psr.i;; srlz.d;;");

	timeit(3, "mov r16=cr.tpr;;");

	timeit(4, "mov r16=cr.tpr;; mov cr.tpr=r16;;");

	timeit(5, "mov r16=cr.tpr;; mov cr.tpr=r16;; srlz.d;;");

	/* These calculations assume no variation in loop timings.
	 * Of course that is not true, interrupts will disturb the
	 * counters so take the results with a big pinch of salt.
	 * Load and unload the module several times and manually
	 * discard values that are "obviously" wrong.  In particular
	 * any zero costs indicate jitter in the results.
	 */

	calc_cost(0, end0-start0);			/* empty loop */
	calc_cost(1, end1-start1-cost0);		/* extra cost for psr.i */
	calc_cost(2, end2-start2-(end1-start1));	/* extra cost for tpr.mmi */
	calc_cost(3, end3-start3-cost0);		/* extra cost for mov r16=cr.tpr */
	calc_cost(4, end4-start4-(end3-start3));	/* extra cost for mov cr.tpr=r16 */
	calc_cost(5, end5-start5-(end4-start4));	/* extra cost for srlz.d */

	print_cost(1, "psr.i");
	print_cost(2, "tpr.mmi");
	print_cost(3, "mov from tpr");
	print_cost(4, "mov to tpr");
	print_cost(5, "srlz.d");

	return 0;
}


