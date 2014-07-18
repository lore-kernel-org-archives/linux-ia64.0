From: Tejun Heo <tj@kernel.org>
Date: Fri, 18 Jul 2014 11:20:39 +0000
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-Id: <20140718112039.GA8383@htj.dyndns.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
In-Reply-To: <20140717230923.GA32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Thu, Jul 17, 2014 at 04:09:23PM -0700, Nishanth Aravamudan wrote:
> [Apologies for the large Cc list, but I believe we have the following
> interested parties:
> 
> x86 (recently posted memoryless node support)
> ia64 (existing memoryless node support)
> ppc (existing memoryless node support)
> previous discussion of how to solve Anton's issue with slab usage
> workqueue contributors/maintainers]

Well, you forgot to cc me.

...
> It turns out we see this large slab usage due to using the wrong NUMA
> information when creating kthreads.
>     
> Two changes are required, one of which is in the workqueue code and one
> of which is in the powerpc initialization. Note that ia64 may want to
> consider something similar.

Wasn't there a thread on this exact subject a few weeks ago?  Was that
someone else?  Memory-less node detail leaking out of allocator proper
isn't a good idea.  Please allow allocator users to specify the nodes
they're on and let the allocator layer deal with mapping that to
whatever is appropriate.  Please don't push that to everybody.

Thanks.

-- 
tejun
