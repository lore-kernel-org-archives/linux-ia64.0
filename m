From: Ray Bryant <raybry@sgi.com>
Date: Mon, 15 Mar 2004 06:45:10 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <405550F6.1070203@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>	<20040313034840.GF4638@wotan.suse.de>	<20040313184547.6e127b51.akpm@osdl.org>	<40541A09.3050600@sgi.com> <20040314005737.7f57b8ad.akpm@osdl.org>
In-Reply-To: <20040314005737.7f57b8ad.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



Andrew Morton wrote:
<unrelated text snipped>
> 
> As for holding mmap_sem for too long, well, that can presumably be worked
> around by not mmapping the whole lot in one hit?
> 

There are a number of places that one could do this (explicitly in user code,
hidden in library level, or in do_mmap2() where the mm->map_sem is taken).
I'm not happy with requiring the user to make a modification to solve this
kernel problem.  Hiding the split has the problem of making sure that if any
of the sub mmap() operations fail then the rest of the mmap() operations have
to be undone, and this all has to happen in a way that makes the mmap() look
like a single system call.

An alternative would be put some info in the mm_struct indicating that a
hugetlb_prefault() is in progress, then drop the mm->mmap_sem while
hugetlb_prefault() is running.  Once it is done, regrab the mm->mmap_sem,
clear the "in progress flag" and finish up processing.  Any other mmap()
that got the mmap_sem and found the "in progress flag" set would have to
fail, perhaps with -EAGAIN (again, an mmap() extension).  One can also
implement more elaborate schemes where there is a list of pending hugetlb
mmaps() with the associated address space ranges being listed; one could
check this list in get_unmapped_area() and return -EAGAIN if there is
a conflict.

I'd still rather see us do the "allocate on fault" approach with prereservation
to maintain the current ENOMEM return code from mmap() for hugepages.  Let me
work on that and get back to y'all with a patch and see where we can go from
there.  I'll start by taking a look at all of the arch dependent hugetlbpage.c's
and see how common they all are and move the common code up to mm/hugetlbpage.c.
(or did WLI's note imply that this is impossible?)

However, is this set of changes something that would still be accepted in 2.6,
or is this now a 2.7 discussion?

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

