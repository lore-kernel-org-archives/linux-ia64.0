From: Robin Holt <holt@sgi.com>
Date: Tue, 28 Mar 2006 21:00:16 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060328210016.GD8162@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 28, 2006 at 12:09:00PM -0800, Chen, Kenneth W wrote:
> Can you walk the vmem_map's page table and look for none-zero entry, sort
> of implement something like find_next_valid_pfn? There you can walk at pud,
> pmd's granule step.

Short of breaking up nodes into multiple pgdat structures, I think this
will be the most efficient.  I will try this when I get the time.

Thanks,
Robin
