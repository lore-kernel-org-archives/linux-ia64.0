From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 06 Aug 2015 07:00:05 +0000
Subject: Re: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
Message-Id: <55C305F5.8050005@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
 <1438274071-22551-3-git-send-email-vbabka@suse.cz>
 <20150730174112.GC15257@cmpxchg.org>
In-Reply-To: <20150730174112.GC15257@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 07/30/2015 07:41 PM, Johannes Weiner wrote:
> On Thu, Jul 30, 2015 at 06:34:31PM +0200, Vlastimil Babka wrote:
>> numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
>> so it's a more robust fallback than the currently used numa_node_id().
>
> Won't it fall through to the next closest memory node in the zonelist
> anyway?

Right, I would expect the zonelist of memoryless node to be the same as 
of the closest node. Documentation/vm/numa seems to agree.

Is this for callers doing NUMA_NO_NODE with __GFP_THISZONE?

I guess that's the only scenario where that matters, yeah. And there 
might well be no such caller now, but maybe some will sneak in without 
the author testing on a system with memoryless node.

Note that with !CONFIG_HAVE_MEMORYLESS_NODES, numa_mem_id() just does 
numa_node_id().

So yeah I think "a more robust fallback" is correct :) But let's put it 
explicitly in changelog then:

----8<----

alloc_pages_node() might fail when called with NUMA_NO_NODE and 
__GFP_THISNODE on a CPU belonging to a memoryless node. To make the 
local-node fallback more robust and prevent such situations, use 
numa_mem_id(), which was introduced for similar scenarios in the slab 
context.
