From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 15 Apr 2004 17:16:45 +0000
Subject: RE: hugetlb demand paging patch part [3/3]
Message-Id: <200404151716.i3FHGjF08464@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040415072535.GF25560@zax>
References: <200404132325.i3DNPXF21289@unix-os.sc.intel.com>
In-Reply-To: <200404132325.i3DNPXF21289@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net, raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, 'Andrew Morton' <akpm@osdl.org>

>>>>> David Gibson wrote on Thursday, April 15, 2004 12:26 AM
>
> > @@ -175,7 +132,6 @@ struct page *follow_huge_addr(struct mm_
> >  		return NULL;
> >  	page = pte_page(*ptep);
> >  	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
> > -	get_page(page);
> >  	return page;
> >  }
>
> As far as I can tell, the removal of these get_page()s is also
> unrelated to the demand paging per se.  But afaict removing them is
> correct - the corresponding logic in follow_page() for normal pages
> doesn't appear to do a get_page(), nor do all archs do a get_page().
>
> Does that sound right to you?

It's a bug in the code that was never exercised with prefaulting.  See
get_user_pages() that short circuits the rest of faulting code with
is_vm_hugetlb_page() test.


> If so, the patch below ought to be safe (and indeed a bugfix) to
> apply now:

Yep, that's correct, I already did x86 and ia64 in one of the three
patches posted. ;-)


