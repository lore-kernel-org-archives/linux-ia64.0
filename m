From: Jack Steiner <steiner@sgi.com>
Date: Thu, 03 Feb 2005 18:54:06 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050203185406.GC6396@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 03, 2005 at 03:38:45AM -0500, Jes Sorensen wrote:
> >>>>> "Jack" = Jack Steiner <steiner@sgi.com> writes:


sorry - I mised your reply. Apparantly, it looks like SPAM:

>>> Subject: ***** SUSPECTED SPAM ***** Re: [rfc] generic allocator and mspec driver
>>> From: Jes Sorensen <jes@wildopensource.com>
>>> X-Virus-Scanned: by cuda.sgi.com at sgi.com
>>> X-Barracuda-Spam-Score: 0.60
>>> X-Barracuda-Spam-Status: Yes, SCORE=0.60 using per-user scores of TAG_LEVEL=0.2 QUARANTINE_LEVEL=2.3 KILL_LEVEL00.0 tests=FORGED_RCVD_HELO,
>>> MARKETING_SUBJECT
>>> X-Barracuda-Spam-Report: Code version 2.64, rules version 2.1.1028
>>>         Rule breakdown below    pts        rule name                      description
>>>         ---- ---------------------- -------------------------------------------
>>>         0.60 MARKETING_SUBJECT      Subject contains popular marketing words
>>>         0.00 FORGED_RCVD_HELO       Received: contains a forged HELO
>>> X-Priority: 5 (Lowest)

Oh well....

> 
> Jack> On Wed, Feb 02, 2005 at 02:10:32PM -0500, Jes Sorensen wrote:
> Jack> General comment:
> 
> Jack, thanks for the comments, I'll look at it, however I have the
> following comments (which may or may not be correct from my side):
> 
> Jack> 1) I may be paranoid, but I'm nervous about using memory visible
> Jack> to the VM system for fetchops. If ANYTHING in the kernel makes a
> Jack> reference to the memory and causes a TLB dropin to occur, then
> Jack> we are exposed to data corruption. If memory being used for
> Jack> fetchops is loaded into the cache, either directly or by
> Jack> speculation, then data corruption of the uncached fetchop memory
> Jack> can occur.
>   
> Jack>   Am I being overly paranoid? How can we be certain that nothing
> Jack> will ever reference the fetchop memory alocated from the general
> Jack> VM pool. lcrash, for example.
> 
> Once a page is handed out using alloc_pages, the kernel won't touch it
> again unless you explicitly map it etc. or if some process touches
> memory at random, which could also happen with the spill pages.  So I
> don't think the situation is any worse than it is for the spill pages
> in the lower granules.

In theory, you are correct & maybe I'm being overly paranoid. However,
a failure is almost impossible to debug.

Using the UC area in the low granules seems safe but it still took
us a long time to get it right. The kernel is unaware
of the memory & with the exception of the fetchop code, nothing in 
the kernel ever references the spill areas. 

I can't find any specific place that will fail using kernel memory for
mspec but my gut feeling is that we are more exposed to errors using 
memory the kernel knows about than in using the spill areas.
For example, although I don't see any problems here because of it's limited use, 
virt_addr_valid() & pfn_valid() is FALSE for the spill area but TRUE 
for kernel memory.

What prevents lcrash (or /dev/kmem or /proc/kcore) from referencing
special memory being used for fetchops? Granted, this takes 
root privilege but the consequences of a bad reference can
cause silent data corruption that is impossible to debug. 
Should we add code to prohibit these area from referencing 
granules being used for mspec memory?

Forgive the paranoia but several of use spent a long time debugging
some of these issues. Maybe all I'm asking is that everyone spend
a little extra time thinking of ways that the kernel could cause
a TLB entry to be made to a granule being used for mspec memory.


> 
> Jack> 2) Is there a limit on the number of mspec pages that can be
> Jack> allocated?  Is there a shaker that will cause unused mspec
> Jack> granules to be freed?  What prevents a malicious/stupid/buggy
> Jack> user from filling the system with mspec pages?
> 
> Currently there is no limit on this, however it could easily be
> imposed either by having a max number of granules allocated per node
> or system wide.
> 
> I could add code to free granules when it's all released but I believe
> the amount of memory being pulled in for this in real life situations
> is so limited it's not really worth the complexity. Adding a hard
> limit for how much is allowed to be allocated seems simpler.

Seems like some sort of limit is needed. I agree - something simple
is all that is needed.

> 
> Jack> 3) Is an "mspec" address a physical address or an uncached
> Jack> virtual address?  Some places in the code appear
> Jack> inconsistent. For example:
> 
> Jack> 	mspec_free_page(TO_PHYS(maddr)) vs.  maddr; /* phys addr of
> Jack> start of mspecs. */
>  
> Uncached virtual, the comments you point out are leftovers from the
> old version of the driver.
> 
> Jack> A few code specific issues:
> 
> Jack> ...  + printk(KERN_WARNING "smp_call_function failed for " +
> Jack> "mspec_ipi_visibility! (%i)\n", status); + } + +
> Jack> sn_flush_all_caches((unsigned long)tmp, IA64_GRANULE_SIZE);
> 
> Jack> Don't the TLBs need to be flushed before you flush
> Jack> caches. Otherwise, the cpu may reload data via speculation.
> 
> Jack> I dont see any TLB flushing of the kernel TLB entries that map
> Jack> the chunks. That needs to be done.  ...
> 
> I thought about this one a fair bit after reading your comments and I
> don't think it's an issue. The pages in the kernel's cached mapping
> are identity mapped which means we shouldn't see any tlbs for this,
> which leaves us with just tlbs for pages that have explicitly been
> mapped somewhere - user tlbs should be removed when a process is shot
> down or pages unmapped and vfree() calls flush_tlb_all(). Or, am I
> missing something?

Identity mapped memory still requires a TLB entry. Somewhere, these
entries need to be purged before using a newly allocated granule for fetchops
or uncached memory. Also, the TLB entries need to be purged before
the cache is flushed. And the cache flushing can't require a 
cacheable TLB entry to be made.


> 
> Jack> + /* + * The kernel requires a page structure to be returned
> Jack> upon + * success, but there are no page structures for low
> Jack> granule pages.  + * remap_page_range() creates the pte for us
> Jack> and we return a + * bogus page back to the kernel fault handler
> Jack> to keep it happy + * (the page is freed immediately there).  +
> Jack> */
> 
> Jack> Ugly hack. Isn't there a better way? (I know this isn't your
> Jack> code & you probably don't like this either. I had hoped for a
> Jack> cleaner solution in 2.6....)
> 
> It's gross, ugly and I hate it ... not sure if there's a simpler way.
> Maybe we can use the same approach as the fbmem driver and do it all
> in the mmap() function, I will have to investigate that.
> 
> Jack> + /* + * Use the bte to ensure cache lines + * are actually
> Jack> pulled from the + * processor back to the md.  + */ +
> 
> Jack> This doesn't need to be done if the memory was being used for
> Jack> fetchops or uncached memory.
> 
> I'll check.
> 
> Jack> + s <<= 1; + } + a = (unsigned long) h[j].next;
> 
> Jack> It appears that you are keeping a linked list of free memory
> Jack> WITHIN the mspec memory itself. If I'm reading this correctly,
> Jack> all the addresses are uncached virtual addresses so that should
> Jack> be ok. However, it might be good to add debugging code to make
> Jack> sure that you never cause a cachable reference to be made to any
> Jack> of the fetchop memory. The resulting data corruption problems
> Jack> are almost impossible to debug.
> 
> You are correct that I keep the lists in the memory. I may change the
> allocator at a later stage to use descriptors instead, but for now I
> think this should be ok. I'll add a check to make sure we never
> receive a cached address back into mspec_free_page.
> 
> Thanks,
> Jes

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


