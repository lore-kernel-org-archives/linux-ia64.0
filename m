From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 03 May 2004 17:12:15 +0000
Subject: RE: [PATCH] - deleting huge pages
Message-Id: <200405031712.i43HCDF17683@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040502123028.GA13812@sgi.com>
In-Reply-To: <20040502123028.GA13812@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> Jack Steiner wrote on Monday, May 03, 2004 7:53 AM
> > > I found this problem in 2.4,21, but AFAICT, the same problem
> > > exists in 2.6.5.
> > >
> > > If you attempt to allocate a LOT more huge pages than are physically
> > > available, the kernel may reference invalid PGDs or PMDs.
> > >
> > > Here is the 2.4 backtrace of a failure. If the mmap fails, do_mmap_pgoff
> > > attempts to unmap the vma range it was mapping. Depending on where it failed
> > > during the mmap, some of the higher level PGD/PMDs may not have been assigned.
> > >
> > > The bug (at least in 2.4) exists on all platforms but on our platform
> > > attempts to dereference NULL pointers usually cause MCAs. (If a platform
> > > has zeros in page 0, you may be lucky & the code would appear to work,
> > > but it is still a bug).
> > >
> > > The MCA was caused by the NULL pmd dereference in huge_pte_offset. The
> > > MCA doesnt surface until the bad data is consumed.
> > >
> > > A patch against 2.6.5:
> >
> > Recent work on cleaning up hugepage_vma has at least one hunk covered here.
> > http://linux.bkbits.net:8080/linux-2.5/cset@40842336E3nkJ7cWJ0-3zQ7yP4WbHg
> >
> >
>
> Yep... Looks like the same problem has been fixed by David Gibson.
> Ignore my patch.

Jack, I don't mean to stir up the mud.  The hunk in unmap_hugepage_range() in
your original post is still needed for 2.6 kernel, plus Bjorn definitely need
your fix for 2.4 tree ;-)

And all this just making hugetlb demanding paging patch smaller .... :-)

- Ken


