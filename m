From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Mon, 15 Mar 2004 23:31:23 +0000
Subject: RE: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <01EF044AAEE12F4BAAD955CB750649430121EFE3@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040313161010.GB15118@wotan.suse.de>
In-Reply-To: <20040313161010.GB15118@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>, Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org



>-----Original Message-----
>From: Ray Bryant
>Andrew Morton wrote:
><unrelated text snipped>
>>
>> As for holding mmap_sem for too long, well, that can presumably be
worked
>> around by not mmapping the whole lot in one hit?
>>
>
>There are a number of places that one could do this (explicitly in user
code,
>hidden in library level, or in do_mmap2() where the mm->map_sem is
taken).
>I'm not happy with requiring the user to make a modification to solve
this
>kernel problem.  Hiding the split has the problem of making sure that
if any
>of the sub mmap() operations fail then the rest of the mmap()
operations have
>to be undone, and this all has to happen in a way that makes the mmap()
look
>like a single system call.
>
>An alternative would be put some info in the mm_struct indicating that
a
>hugetlb_prefault() is in progress, then drop the mm->mmap_sem while
>hugetlb_prefault() is running.  Once it is done, regrab the
mm->mmap_sem,
>clear the "in progress flag" and finish up processing.  Any other
mmap()
>that got the mmap_sem and found the "in progress flag" set would have
to
>fail, perhaps with -EAGAIN (again, an mmap() extension).  One can also
>implement more elaborate schemes where there is a list of pending
hugetlb
>mmaps() with the associated address space ranges being listed; one
could
>check this list in get_unmapped_area() and return -EAGAIN if there is
>a conflict.
>

I think both of above options are bit of stretch.

>I'd still rather see us do the "allocate on fault" approach with
prereservation
>to maintain the current ENOMEM return code from mmap() for hugepages.
Let me
>work on that and get back to y'all with a patch and see where we can go
from
>there.  

I think this allocation on fault behavior will become essential when
Andi's mbind becomes part of the base kernel. And this scheme has an
added advantage of following normal semantics of page allocation (if a
user wants preallocation then MAP_LOCKED can be used).  As Andrew said
earlier in the thread that this though runs the risk of different
behavior with applications that currently assume pre-faulting behavior
in terms of performance (even if you decrement count upfront but do lazy
allocation).  As they will get penalized at fault time.  But this is the
kind of optimization that apps can do when porting to 2.6 based
distributions....

> I'll start by taking a look at all of the arch dependent
hugetlbpage.c's and
>see how common they all are and move the common code up to
mm/hugetlbpage.c.
>(or did WLI's note imply that this is impossible?)
>

You should be able to move prefault code to common tree.

>However, is this set of changes something that would still be accepted
in 2.6,
>or is this now a 2.7 discussion?
>
>--
>Best Regards,
>Ray
>-----------------------------------------------
>                   Ray Bryant
>512-453-9679 (work)         512-507-7807 (cell)
>raybry@sgi.com             raybry@austin.rr.com
>The box said: "Requires Windows 98 or better",
>            so I installed Linux.
>-----------------------------------------------
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
