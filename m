From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 17 Oct 2003 15:11:15 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106640366517860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 02:17:09PM +0200, Andreas Schwab wrote:
> Christoph Hellwig <hch@infradead.org> writes:
> 
> > On Fri, Oct 17, 2003 at 01:12:07PM +0200, Andreas Schwab wrote:
> >> +EXPORT_SYMBOL(csum_partial);
> >
> > ok.
> >
> >> @@ -61,6 +62,8 @@
> >>  #include <asm/pgtable.h>
> >>  EXPORT_SYMBOL(vmalloc_end);
> >>  EXPORT_SYMBOL(ia64_pfn_valid);
> >> +EXPORT_SYMBOL(max_low_pfn);
> >> +EXPORT_SYMBOL(vmem_map);
> >
> > what needs these?
> 
> Anything that uses virt_addr_valid (net/scpt).

Yep, my fault.  Sorry I forgot to export them.  I've only tested a few
modules so far so I didn't catch the missing symbols.

That said, shouldn't these symols be exported in the files that contain
them?

Jesse
