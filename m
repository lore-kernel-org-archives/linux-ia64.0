From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 02 Sep 2004 18:42:43 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902184243.GH5492@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 02, 2004 at 04:05:56PM +0100, Matthew Wilcox wrote:
> Ah, basic lack of understanding of what VIRTUAL_MEM_MAP is used for
> and why it exists.  It should be exclusive with DISCONTIGMEM as they
> both solve the same problem, but in wildly different ways.  At the time
> VIRTUAL_MEM_MAP was put in, the DISCONTIGMEM code was utterly broken
> and nobody was interested in fixing it ("we have a version in the LSE
> patch that doesn't suck as much" doesn't help).
> Both should address the memory map on zx1:
> 0-1 GB
> 257-260GB
> 4-256GB
> (in practice, the maximum memory you can put in any zx1 box at the moment
> is 128GB because 4GB DIMMs aren't supported in the rx5670)
> Without VIRTUAL_MEM_MAP or DISCONTIGMEM, a 2GB zx1 machine would have
> a 13GB mem_map.  So DISCONTIGMEM does away with the global mem_map and
> VIRTUAL_MEM_MAP constructs a mem_map in vmalloc space rather than the
> kernel's fixed mapping.
> If DISCONTIGMEM now works properly, I think VIRTUAL_MEM_MAP can disappear.

My understanding of virtual mem_map was that it was used to remove some
kind of excessive address calculation overhead from CONFIG_DISCONTIGMEM.

This usage is valid too, of course. In this case we either need to adjust
include/asm-ia64/page.h for virtual mem_map or contig_page_data.mem_map
needs to be initialized with the virtual mem_map's base prior to calling
free_area_init_node(), and for that matter, Ian Wienand appears to fall
into the category of systems without a large gap because
find_largest_hole().  is returning something less than LARGE_GAP.

There are a lot of things going wrong at once here.


-- wli
