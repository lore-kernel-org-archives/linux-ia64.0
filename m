From: Ray Bryant <raybry@sgi.com>
Date: Sun, 14 Mar 2004 08:38:33 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <40541A09.3050600@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>	<20040313034840.GF4638@wotan.suse.de> <20040313184547.6e127b51.akpm@osdl.org>
In-Reply-To: <20040313184547.6e127b51.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Andi Kleen <ak@suse.de>, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



Andrew Morton wrote:

>>
>> One drawback is that the out of memory handling is lot less nicer
>> than it was before - when you run out of hugepages you get SIGBUS
>> now instead of a ENOMEM from mmap. Maybe some prereservation would
>> make sense, but that would be somewhat harder. Alternatively
>> fall back to smaller pages if possible (I was told it isn't easily
>> possible on IA64)
> 
> 
> Demand-paging the hugepages is a decent feature to have, and ISTR resisting
> it before for this reason.
> 
> Even though it's early in the 2.6 series I'd be a bit worried about
> breaking existing hugetlb users in this way.  Yes, the pages are
> preallocated so it is unlikely that a working setup is suddenly going to
> break.  Unless someone is using the return value from mmap to find out how
> many pages they can get.
> 
> So ho-hum.  I think it needs to be back-compatible.  Could we add
> MAP_NO_PREFAULT?
> 
> 
> 

I agree with the compatibility concern, but the other part of the problem
is that while hugetlb_prefault() is running, it holds both the mm->mmap_sem in
write mode and the mm->page_table_lock.  So not only does it take 500 s for
the mmap() to return on our test system, but ps, top, etc all freeze for the
duration.  Very irritating, especially on a 64 or 128 P system.

My preference would be to do away with bugetlb_prefault() altogether.
(If there was a MAP_NO_PREFAULT, we would have to make this the default on
Altix to avoid the freeze problem mentioned above.  Can't have an arbitrary
user locking up the system.)  As Andi pointed out, perhaps we can do some
prereservation of huge pages so that we can return a ENONMEM to the mmap()
if there are not enough huge pages to (lazily) be allocated to satisfy the
request, but then still allocate the pages at fault time.  A simple count
would suffice.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

