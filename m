From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 12 Jul 2004 17:59:24 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200407121059.24067.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, July 8, 2004 11:31 am, Chen, Kenneth W wrote:
> It is something related to stack pointer (r12).  If sp stays in region 7
> (providing there is a corresponding dtr mapping), kernel boots fine.

That's what I'm seeing too, any ideas where to look for the problem?  I'm 
happy to test any patches you might have :)  I'm not really sure what's going 
on, but it looks like it might be:


  _start -> start_kernel -> setup_arch -> ia64_mmu_init -> ptc.e -> page fault 
-> die

which would indicate (given that we know that the ptc.e arguments are valid) 
that we're purging a TC entry that keeps us going up to that point, and that 
we're not using the region 5 mapping like we should.  Does that sound right 
at all?

> David 
> mentioned that MCA code also has tpa thingy in it that needs to be
> converted.

But that's not the cause of the problem we're seeing, right?

> One other thing I'm getting frustrated at is I'm keep on 
> receiving mca while doing a ptc.e (only on sgi altix).  Have no idea why.

You don't think this is a symptom of the region 7 vs. region 5 problem?  It 
looks to me like we're doing the ptc.e with the same arguments in either 
case...

Thanks,
Jesse
