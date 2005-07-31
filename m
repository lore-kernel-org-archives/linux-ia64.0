From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 31 Jul 2005 06:29:27 +0000
Subject: Re: [sched, patch] better wake-balancing, #2
Message-Id: <20050731062927.GA472@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507301929_MC3-1-A601-D4C2@compuserve.com>
In-Reply-To: <200507301929_MC3-1-A601-D4C2@compuserve.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chuck Ebbert <76306.1226@compuserve.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>


* Chuck Ebbert <76306.1226@compuserve.com> wrote:

> On Fri, 29 Jul 2005 at 17:02:07 +0200, Ingo Molnar wrote:
> 
> > do wakeup-balancing only if the wakeup-CPU is idle.
> >
> > this prevents excessive wakeup-balancing while the system is highly
> > loaded, but helps spread out the workload on partly idle systems.
> 
> I tested this with Volanomark on dual-processor PII Xeon -- the 
> results were very bad:

which patch have you tested? The mail you replied to above is for patch
#2, while on SMT/HT boxes it's patch #3 that is the correct approach.

furthermore, which base kernel have you applied the patch to? Best would 
be to test the following kernels:

 2.6.13-rc4 + sched-rollup
 2.6.13-rc4 + sched-rollup + better-wake-balance-#3

the sched-rollup and the latest better-wake-balance patches can be found 
at:

  http://redhat.com/~mingo/scheduler-patches/

(sched-rollup is the current scheduler patch-queue in -mm. And if you 
have time, it would also be nice to have a 2.6.13-rc4 baseline for 
VolanoMark, and perhaps a 2.6.12 measurement too, so that we can see how 
things changed.)

	Ingo
