From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Date: Fri, 16 Aug 2002 22:05:01 +0000
Subject: Re: [Linux-ia64] Re: [Discontig-devel] CLUMPS, CHUNKS and GRANULES
Message-Id: <marc-linux-ia64-105590701905946@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905942@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905942@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Discontig is certainly difficult to understand but it is trying
> to provide an abstract framework for describing a very diverse of 
> hardware. The SGI hardware, unfortunately, is likely to be 
> the "worst case" example. :-(

It might help if you didn't try to do everything all at once. If you could
get a subset of the code in and make your patches smaller for you
to maintain ....

>> Therefore a node would have several memory banks which are not
>> necessarily adjacent in the physical memory space. There can be gaps
>> or banks from other nodes interleaved. In the mem_map array there is
>> space reserved for page struct entries of ALL pages of one bank,
>> existent or not. Memory holes between banks don't build holes in the
>> mem_map array.
> 
> If the mem_map has entries for pages that dont exist, how do you handle
> code that scans the mem_map array. How does code recognize  & skip pages
> associated with missing memory?? For examples, see show_mem()
> & get_discontig_info(). (Maybe I misunderstood your proposal here).

show_mem in most architectures is designed for contig mem only.
Pretty much anything that touches mem_map directly is for contig mem
only ... I'm just about done with a patch that wraps the defn of it in
#ifndef CONFIG_DISCONTIGMEM. Will send it out again shortly.

OTOH, I don't think that mem_map having pages for entries that don't exist 
is quite the problem that you think it is - we're only scanning the struct pages,
not the pages themselves.

M.


