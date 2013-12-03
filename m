From: David Rientjes <rientjes@google.com>
Date: Tue, 03 Dec 2013 23:41:38 +0000
Subject: Re: [PATCH] mm, show_mem: Remove SHOW_MEM_FILTER_PAGE_COUNT
Message-Id: <alpine.DEB.2.02.1312031541240.5946@chino.kir.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20131016104228.GM11028@suse.de> <alpine.DEB.2.02.1310161809470.12062@chino.kir.corp.google.com> <20131203145721.GQ11295@suse.de>
In-Reply-To: <20131203145721.GQ11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, James Bottomley <jejb@parisc-linux.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 3 Dec 2013, Mel Gorman wrote:

> Commit 4b59e6c4 (mm, show_mem: suppress page counts in non-blockable
> contexts) introduced SHOW_MEM_FILTER_PAGE_COUNT to suppress PFN walks
> on large memory machines. Commit c78e9363 (mm: do not walk all of system
> memory during show_mem) avoided a PFN walk in the generic show_mem helper
> which removes the requirement for SHOW_MEM_FILTER_PAGE_COUNT in that case.
> 
> This patch removes PFN walkers from the arch-specific implementations that
> report on a per-node or per-zone granularity. ARM and unicore32 still do
> a PFN walk as they report memory usage on each bank which is a much finer
> granularity where the debugging information may still be of use. As the
> remaining arches doing PFN walks have relatively small amounts of memory,
> this patch simply removes SHOW_MEM_FILTER_PAGE_COUNT.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!
