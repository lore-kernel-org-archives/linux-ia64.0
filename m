From: Robin Holt <holt@sgi.com>
Date: Fri, 13 Oct 2006 09:21:11 +0000
Subject: Re: [RFC] Variable Kernel Page size support
Message-Id: <20061013092111.GB19756@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610121730050.22778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How do you handle speculation issues this raises.  Right now, we can
ensure that speculation only occurs on a granule boundary.  mspec converts
granules to uncached.  With this patch, we would have to allocate a chunk,
determine the size of page table backing that chunk, if it does not span
the entire, free it and ask for a larger chunk.  Alternatively, we would
need to allocate a series of granule size chunks until none were found,
then double that size and repeat.

Have you shown a benefit from this work yet?  In my and IIRC Jack's
experience, nearly every place in the kernel that I have seen operating
on vmem_map and struct page * that is performance critical have adequate
TLB pressure to cause TLB replacement for the vmem_map.  With your patch,
how much extra work is the kernel going to need to do when replacing an
entry which will essentially end up being used once?

Please show a benfit before introducing this patch so we can ensure we
do not introduce silent data corruption problems in the mspec allocations.

If you want vmem_map to have variable page sizes, how about specifying the
min and max at something crazy like base page size for ia64.  Then you
could still make the code generic and get it into the mainline kernel
and not affect ia64.

Thanks,
Robin
