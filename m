From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 05 Apr 2004 17:01:21 +0000
Subject: RE: [Lse-tech] RE: [PATCH] HUGETLB memory commitment
Message-Id: <200404051701.i35H1LF26985@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <40717AA8.9050900@sgi.com>
References: <40717AA8.9050900@sgi.com>
In-Reply-To: <40717AA8.9050900@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ray Bryant' <raybry@sgi.com>
Cc: 'Andy Whitcroft' <apw@shadowen.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

>>>> Ray Bryant wrote on Mon, April 05, 2004 8:27 AM
> Chen, Kenneth W wrote:
>
> >
> > A simple counter won't work for different file offset mapping.  It has to
> > be some sort of per-inode, per-block reservation tracking.  I think we are
> > steering in the right direction though.
> >
> >
>
> OK, pardon my question about test code, that is trivial enough I guess.
>
> Anyway, the only way I can see to make this work with non-zero offset is to
> hang a list of segment descriptors (offset and size) for each reserved segment
> off of the inode.  Then when a new mapping comes in, we search the segment
> list to see if the new offset and size overlaps with any of the existing
> reserved segments.  If it doesn't, then we make a new reservation (and request
> file system quota) for the current size, and add the current request to the
> reserved segment list.  If it does, and it fits entirely in a previously
> reserved segement, then no change to reservation/quota needs to be made.  If
> it only partially fits, then we need to make a new reservation/quota request
> for the number of new huge pages required and update the overlapping segment's
> length to reflect the new reservation.
>
> Then in truncate_hugepages() we can search the segment list again, discarding
> full or partial segments that occur either entirely or partially beyond
> "lstart", as appropropriate and doing hugetlb_unreserve() and
> hugetlbfs_put_quota() for the appropriate number of pages.
>
> This will be quite a bit of code and complexity.  Do we still think this is
> all worth it to follow Andrew's suggestion of no API changes for "allocate on
> fault" hugetlbpages?  It would be a lot cleaner just to return SIGBUS if we
> run out of hugepages and be done with it, in spite of the API change.
>
> Is there a simpler way to do the correct reservation?  (One could allocate the
> pages at mmap() time, resurrecting hugetlb_prefault(), but zero the pages at
> fault time, this would solve the original problem we ran into at SGI, but
> would not solve Andi's requirement to postpone allocation so NUMA API's can
> control placement.)

I actually started coding yesterday.  It doesn't look too bad (I think).  I will
post it once I finished it up later today or tomorrow.

There are still some oddity in lifetime of the huge page reservation, but that
can be discussed once everyone sees the code.

- Ken


