From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 23 Jun 2003 17:20:44 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105638893811288@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, someone wrote:
>># define pfn_to_page(pfn)	(vmem_map + (pfn))
>># define page_to_pfn(page)	((unsigned long) (page - vmem_map))

On Sat, Jun 21, 2003 at 07:48:08AM -0700, Martin J. Bligh wrote:
> I really don't see how you *can't* do that, and have it still work.
> If the mem_map is placed in node local memory, and not a size that 
> happens to be a complete number of pages, even if you pack it down 
> into a vmem_map, it's still not contiguous. So adding a pfn (physical 
> page frame number) to the base of vmem_map can NOT give you the correct 
> address.
> Presumably this *is* working for you ... but I'm buggered if I know how ;-)
> Maybe I just need more coffee ;-)

It's a sparse array. The interstices between nodes are padded with
empty virtualspace in order to cheapen the indexing operation. i.e. the
nodes' local mem_map's are virtually positioned according to the range
of pfns they span. If 32-bit weren't as pressed for virtualspace it
could do likewise.


-- wli
