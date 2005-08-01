From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Mon, 01 Aug 2005 17:13:18 +0000
Subject: Re: [sched, patch] better wake-balancing, #3
Message-Id: <20050801101318.A11610@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42E98DEA.9090606@yahoo.com.au> <200507290627.j6T6Rrg06842@unix-os.sc.intel.com> <20050729114822.GA25249@elte.hu> <20050729141311.GA4154@elte.hu> <20050729150207.GA6332@elte.hu> <20050729162108.GA10243@elte.hu> <42EAC504.3000300@yahoo.com.au> <20050730071917.GA31822@elte.hu> <42EC2624.7030509@yahoo.com.au>
In-Reply-To: <42EC2624.7030509@yahoo.com.au>; from nickpiggin@yahoo.com.au on Sun, Jul 31, 2005 at 11:15:16AM +1000
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, John Hawkes <hawkes@sgi.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Paul Jackson <pj@sgi.com>

On Sun, Jul 31, 2005 at 11:15:16AM +1000, Nick Piggin wrote:
> Ingo Molnar wrote:
> > especially on NUMA, if the migration-target CPU (this_cpu) is not at 
> > least partially idle, i'd be quite uneasy to passive balance from 
> > another node. I suspect this needs numbers from Martin and John?
> 
> Passive balancing cuts in only when an imbalance is becoming apparent.
> If the queue gets more imbalanced, periodic balancing will cut in,
> and that is much worse than wake balancing.

Another point to note about the current wake balance. Imbalance calculation
is not taking the complete load of the sched group into account. I think
there might be scenario's where the current wake balance will actually
result in some imbalances corrected later by periodic balancing.

thanks,
suresh
