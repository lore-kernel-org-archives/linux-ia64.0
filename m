From: Jack Steiner <steiner@sgi.com>
Date: Mon, 03 May 2004 14:53:06 +0000
Subject: Re: [PATCH] - deleting huge pages
Message-Id: <20040503145306.GA15182@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040502123028.GA13812@sgi.com>
In-Reply-To: <20040502123028.GA13812@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, May 02, 2004 at 11:33:33AM -0700, Chen, Kenneth W wrote:
> >>>> Jack Steiner wrote on Sunday, May 02, 2004 5:30 AM
> > I found this problem in 2.4,21, but AFAICT, the same problem
> > exists in 2.6.5.
> >
> > If you attempt to allocate a LOT more huge pages than are physically
> > available, the kernel may reference invalid PGDs or PMDs.
> >
> > Here is the 2.4 backtrace of a failure. If the mmap fails, do_mmap_pgoff
> > attempts to unmap the vma range it was mapping. Depending on where it failed
> > during the mmap, some of the higher level PGD/PMDs may not have been assigned.
> >
> > The bug (at least in 2.4) exists on all platforms but on our platform
> > attempts to dereference NULL pointers usually cause MCAs. (If a platform
> > has zeros in page 0, you may be lucky & the code would appear to work,
> > but it is still a bug).
> >
> > The MCA was caused by the NULL pmd dereference in huge_pte_offset. The
> > MCA doesnt surface until the bad data is consumed.
> >
> > A patch against 2.6.5:
> 
> Recent work on cleaning up hugepage_vma has at least one hunk covered here.
> http://linux.bkbits.net:8080/linux-2.5/cset@40842336E3nkJ7cWJ0-3zQ7yP4WbHg
> 
> - Ken
> 

Yep... Looks like the same problem has been fixed by David Gibson. 
Ignore my patch.



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


