From: Andrew Morton <akpm@osdl.org>
Date: Thu, 25 Mar 2004 23:51:17 +0000
Subject: Re: [PATCH] [0/6] HUGETLB memory commitment
Message-Id: <20040325155117.60dbc0e1.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <18429360.1080233672@42.150.104.212.access.eclipse.net.uk>
	<20040325130433.0a61d7ef.akpm@osdl.org>
	<41997489.1080257240@42.150.104.212.access.eclipse.net.uk>
In-Reply-To: <41997489.1080257240@42.150.104.212.access.eclipse.net.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Whitcroft <apw@shadowen.org>
Cc: anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@aracnet.com

Andy Whitcroft <apw@shadowen.org> wrote:
>
> --On 25 March 2004 13:04 -0800 Andrew Morton <akpm@osdl.org> wrote:
> 
> > Sorry, but I just don't see why we need all this complexity and generality.
> > 
> > If there was any likelihood that there would be additional memory domains
> > in the 2.6 future then OK.  But I don't think there will be.  We simply
> > need some little old patch which fixes this bug.
> > 
> > Such as adding a `vma' arg to vm_enough_memory() and vm_unacct_memory() and
> > doing
> > 
> > 	if (is_vm_hugetlb_page(vma))
> > 		return;
> > 
> > and
> > 
> > -	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
> > +	allowed = (totalram_pages - htlbpagemem << HPAGE_SHIFT) *
> > +			sysctl_overcommit_ratio / 100;
> > 
> > in cap_vm_enough_memory().
> 
> That's pretty much what you get if you only apply the first two patches.  Sadly, you can't just pass a vma as you don't always have one when you are making the decision.  For example when a shm segment is being created you need to commit the memory at that point, but its not been attached at all so there is no vma to check.  That's why I went with an abstract domain.  These patches have been tested in isolation and do seem to work.
> 
> The other patches started out wanting to solve a second issue, the generality seemed to come out naturally.  I am not sure how important it is, but when we create a normal shm domain we commit the memory then.  For an hugetlb one we only commit the memory when the region is attached the first time, ie when the pages are cleared and filled.  Also we have no policy control over them.
> 
> In short I guess if we only are trying to fix the overcommit cross over between the normal and hugetlb, then the first two patches should be basically there.
> 
> Let me know what the decision is and I'll steer the ship in that direction.

I think it's simply:

- Make normal overcommit logic skip hugepages completely

- Teach the overcommit_memory=2 logic that hugepages are basically
  "pinned", so subtract them from the arithmetic.

And that's it.  The hugepages are semantically quite different from normal
memory (prefaulted, preallocated, unswappable) and we've deliberately
avoided pretending otherwise.

As for the shm problem, well, perhaps it's best to leave vm_enough_memory()
as it is and fix it up in the callers.  So most callsites will call:

static inline int vm_anough_memory_vma(struct vm_area_struct *vma,
					unsigned long nr_pages)
{
	if (is_vm_hugetlb_page(vma))
		return 0;
	return vm_enough_memory(nr_pages);
}

and in do_mmap_pgoff() perhaps we can do:

+	if (file && !is_file_hugepages(file)) {
		charged = len >> PAGE_SHIFT;
		if (security_vm_enough_memory(charged))
			return -ENOMEM;
+	}



