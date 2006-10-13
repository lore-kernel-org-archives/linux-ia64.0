From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 01:13:53 +0000
Subject: Re: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <Pine.LNX.4.64.0610121812320.23030@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 13 Oct 2006, KAMEZAWA Hiroyuki wrote:

> 
> > +#define VIRTUAL_MEM_MAP_SIZE   (1UL << (IA64_MAX_PHYS_BITS - PAGE_SHIFT +\
> > +					STRUCT_PAGE_ORDER))
> 
> I'm not sure but Is this size of virtual-memory able to be mapped by any configs ?

I was going for the maximum physical memory supported.

> > +#define VMALLOC_START  (VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
> > +#define VMALLOC_END    (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
> > +
> And, (1UL << (4*PAGE_SHIFT-9)) - VIRTUAL_MEM_MAP_SIZE is real VMALLOC size. 
> I think.

Correct.


