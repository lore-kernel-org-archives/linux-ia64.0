From: Andi Kleen <ak@suse.de>
Date: Fri, 15 Jul 2005 21:47:01 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-Id: <20050715214700.GJ15783@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com> <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com> <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

> It is very useful to a batch scheduler that can dynamically move memory 
> between nodes. It needs to know exactly where the pages are including the 
> vma information. 

You mean for relative placement in node groups? 
Ray's code was supposed to handle that in the kernel.
You pass an mapping array to the syscall and it does the rest.

We had a big discussion about that some months ago; I suggest
you review it.

So for what does that batch monstrosity need to know 
about the VMAs? 

> It is also of utmost importance to a sysadmin that wants 
> to control the memory placement of an important application to have 
> information about the process and be able to influence future allocations 
> as well as to move existing pages.

I don't believe any admin will mess with virtual addresses.

I added the capability to numactl for shared memory
areas because I first thought it would be useful, but as far
as I know nobody was interested in it. (will probably remove
it again) 

But for "uncooperative" programs working on bigger objects
like threads/files/shm areas/processes makes much more sense. And gives
much cleaner interfaces too.

Now I can see some people being interested in more fine grained
policy, but the only sane way to do that is to change the source
code and use libnuma.

Basically to mess with finegrained virtual addresses you need code access,
and when you have that you can as well do it well and add 
libnuma and recompile.

-Andi
