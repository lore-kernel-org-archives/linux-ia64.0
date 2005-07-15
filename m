From: Andi Kleen <ak@suse.de>
Date: Fri, 15 Jul 2005 22:37:57 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-Id: <20050715223756.GL15783@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com> <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com> <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Fri, Jul 15, 2005 at 03:30:40PM -0700, Christoph Lameter wrote:
> I cannot imagine that migrate pages make it into the kernel in its 
> current form. It combines multiple functionalities that need to be 
> separate (it does update the memory policy, clears the page cache, deals 
> with memory policy translations and then does heuristics to guess which 
> vma's to transfer) and then provides a complex function moving of pages 
> between groups of nodes.
> 
> Therefore:
> 
> 1. Updating the memory policy is something that can be useful in other 
>    settings as well so it need to be separate. The patch we are discussing

Not for external processes except in the narrow special case
of migrating everything. External processes shouldn' t
know about virtual addresses of other people.


> 3. Memory policy translations better be done in user space. The batch
>    scheduler /sysadmin knows which node has what pages so it can easily 
>    develop page movement scheme that is optimal for the process.

I don't think the existing policies are complex enough to make
this useful. The mapping for page migration for all of 
them is quite straight forward.


-Andi
