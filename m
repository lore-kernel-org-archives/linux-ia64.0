From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 22 Sep 2003 20:31:15 +0000
Subject: Re: [HELP] latest discontig
Message-Id: <marc-linux-ia64-106426273427285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106305453930076@msgid-missing>
In-Reply-To: <marc-linux-ia64-106305453930076@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 22, 2003 at 12:39:40PM -0700, David Mosberger wrote:
> You know, you'd greatly increase the chance of my applying the patch
> if the patch:
> 
>  - were broken up into reasonably small, self-contained pieces

Um.. I can try to break it up.

>  - doesn't actually BREAK the existing ia64 platforms

Does it?  We've tested it on quite a few...

> I'm sorry, but until some of these criteria are met, there is no way
> I'm going to apply this patch.  As for the breakage: as far as I can
> see, the patch moves the bootmem initialization back to the old place,
> which means that drivers/acpi/tables.c will fail to allocate memory
> for the SDT again.

Len Brown already took the change to fix tables.c.

> Some other comments:
> 
>  - in acpi.c, it looks like there is no reason for min_hole_size anymore,
>    yet the patch doesn't clean up this variable

Ok.

>  - MAX_RSVD_REGIONS et al got moved to pgtable.h; why in the world would
>    that be the right place?  Just because "it compiled"??

I'll have to look at that again.  I think I needed to move some of that
stuff to a header because I created contig.c to seperate things a
little.

>  - why is there both vmem_map and mem_map in the NUMA case?

Because it compiled :/.  I'll try to fix that up too.

Thanks,
Jesse
