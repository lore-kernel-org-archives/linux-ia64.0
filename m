From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 08 Aug 2005 23:18:42 +0000
Subject: RE: [sched, patch] better wake-balancing, #3
Message-Id: <200508082318.j78NIlg21385@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050730071917.GA31822@elte.hu>
References: <20050729162108.GA10243@elte.hu>
In-Reply-To: <20050729162108.GA10243@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, John Hawkes <hawkes@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Paul Jackson <pj@sgi.com>

Ingo Molnar wrote on Saturday, July 30, 2005 12:19 AM
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > > here's an updated patch. It handles one more detail: on SCHED_SMT we 
> > > should check the idleness of siblings too. Benchmark numbers still 
> > > look good.
> > 
> > Maybe. Ken hasn't measured the effect of wake balancing in 2.6.13, 
> > which is quite a lot different to that found in 2.6.12.
> > 
> > I don't really like having a hard cutoff like that -wake balancing can 
> > be important for IO workloads, though I haven't measured for a long 
> > time. [...]
> 
> well, i have measured it, and it was a win for just about everything 
> that is not idle, and even for an IPC (SysV semaphores) half-idle 
> workload i've measured a 3% gain. No performance loss in tbench either, 
> which is clearly the most sensitive to affine/passive balancing. But i'd 
> like to see what Ken's (and others') numbers are.
> 
> the hard cutoff also has the benefit that it allows us to potentially 
> make wakeup migration _more_ agressive in the future. So instead of 
> having to think about weakening it due to the tradeoffs present in e.g.  
> Ken's workload, we can actually make it stronger.


Sorry it took us a while to get the experiment done on our large db setup.
This patch has the same effectiveness compare to turning off both
SD_WAKE_BALANCE and SD_WAKE_AFFINE, (+2.2% on db OLTP workload).  We like
it a lot.

- Ken

