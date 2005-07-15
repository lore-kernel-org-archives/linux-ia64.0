From: Andi Kleen <ak@suse.de>
Date: Fri, 15 Jul 2005 21:12:10 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-Id: <20050715211210.GI15783@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com> <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com> <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com>
In-Reply-To: <20050715140437.7399921f.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de

> These questions of interface style (filesys or syscall) probably don't
> matter, however. at least not yet.  First we need to make sense of
> the larger issues that Ken and Andi raise, of whether this is a good
> thing to do.

In my opinion detailed reporting of node affinity to external
processes of specific memory areas is a mistake. It's too finegrained and 
not useful outside the process itself (external users don't or shouldn't
know anything about process virtual addresses). The information
is too volatile and can change every time without nice 
ways to lock (no SIGSTOP is not a acceptable way) 

Some people might find it useful for debugging NUMA kernel code,
but that doesn't mean it has to go into the kernel.

For statistics purposes probably just some counters are enough.
Either generated on demand or counted. On demand would be 
probably slow and counted would bloat mm_struct because
it would need some max_numnodes sized arrays.   Not sure what
is the better tradeoff.

-Andi
