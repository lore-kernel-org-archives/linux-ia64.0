From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 24 Jul 2015 14:52:18 +0000
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
Message-Id: <55B25122.5030407@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com>
 <55AF7F64.1040602@suse.cz>
 <alpine.DEB.2.10.1507221445130.21468@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1507230855510.12258@east.gentwo.org>
 <alpine.DEB.2.10.1507231322510.31024@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507231322510.31024@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On 07/23/2015 10:27 PM, David Rientjes wrote:
> On Thu, 23 Jul 2015, Christoph Lameter wrote:
>
>>> The only possible downside would be existing users of
>>> alloc_pages_node() that are calling it with an offline node.  Since it's a
>>> VM_BUG_ON() that would catch that, I think it should be changed to a
>>> VM_WARN_ON() and eventually fixed up because it's nonsensical.
>>> VM_BUG_ON() here should be avoided.
>>
>> The offline node thing could be addresses by using numa_mem_id()?
>>
>
> I was concerned about any callers that were passing an offline node, not
> NUMA_NO_NODE, today.  One of the alloc-node functions has a VM_BUG_ON()
> for it, the other silently calls node_zonelist() on it.
>
> I suppose the final alloc_pages_node() implementation could be
>
>          if (nid = NUMA_NO_NODE || VM_WARN_ON(!node_online(nid)))
>                  nid = numa_mem_id();
>
>          VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
>          return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>
> though.

I've posted v2 based on David's and Christoph's suggestions (thanks) but 
to avoid spamming everyone until we agree on the final interface, it's 
marked as RFC and excludes the arch people from CC:

http://marc.info/?l=linux-kernel&m3774920902608&w=2
