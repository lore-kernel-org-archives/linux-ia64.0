From: Christoph Lameter <cl@linux.com>
Date: Thu, 30 Jul 2015 17:59:47 +0000
Subject: Re: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
Message-Id: <alpine.DEB.2.11.1507301259230.5521@east.gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz> <1438274071-22551-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438274071-22551-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Thu, 30 Jul 2015, Vlastimil Babka wrote:

> numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
> so it's a more robust fallback than the currently used numa_node_id().
>
> Suggested-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

You can add my ack too if it helps.

Acked-by: Christoph Lameter <cl@linux.com>
