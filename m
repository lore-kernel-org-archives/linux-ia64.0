From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 06 Aug 2004 20:51:47 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040806205147.GS17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, Josh Aas wrote:
>> My bad for not explaining that. In my limited testing of this particular 
>> number it seemed to be the sweet spot for prefetching. I think it is a 
>> good number for all architectures because 32 bit architectures won't 
>> need the speed boost as much as 64 bit architectures. They are not 
>> likely to have > 4GB memory,, in which case this function's time is 
>> probably less than 1 second anyway.

On Fri, Aug 06, 2004 at 01:09:34PM -0700, Luck, Tony wrote:
> There are quite a few x86 boxes running with 16GB ... but the max
> is 64GB, which is still below the pain threshold for seeing an
> unreasonable delay during this routine ... so I agree that perfect
> tuning is irrelevent for 32-bit machines here.  You should include
> your explanatory paragraph when you post to LKML.

The 32-bit situation is even more unusual than that. Bootmem is only
used for ZONE_NORMAL, the region of physical memory usually mapped
into the majority of kernel virtualspace. So even while physical
memory may span 64GB, no more than 896MB or so are ever tracked by
the bootmem allocator. ->zone_mem_map for highmem zones is set up
later by hand.

-- wli
