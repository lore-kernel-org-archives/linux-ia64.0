From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 09 Nov 2004 02:40:20 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <41902E14.4080904@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain> <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Mon, 8 Nov 2004, Hugh Dickins wrote:
> 
> 
>>>Maintaining these counters requires locking which interferes with Nick's
>>>and my attempts to parallelize the vm.
>>
>>Aren't you rather overestimating the importance of one single,
>>ideally atomic, increment per page fault?
> 
> 
> We would need to investigate that in detail. What we know is that if
> multiple cpus do atomic increments with an additional spinlock/unlock etc
> as done today then we do have a significant performance impact due to
> exclusive cache lines oscillating between cpus.
> 
> 
>>It's great news if this is really the major scalability issue facing Linux.
> 
> 
> Not sure. This may just be a part of it.
> 

I'm sure it would be a part of it. I think we've basically got 3 things
that share cachelines now, they are the mmap_sem, page_table_lock, and
rss/anon_rss.

After removing the page table lock, it tentatively looks like mmap_sem
is the next largest problem. It may be that the mmap_sem cacheline kind
of serialises threads coming into handle_mm_fault, so the rss doesn't
bounce so much. However I might just try ripping out the rss counters
entirely and just see what happens to performance.


I wonder if a per process flag or something could be used to turn off
the statistics counters? I guess statistics could still be gathered for
that process by using your lazy counting functions, Christoph.
